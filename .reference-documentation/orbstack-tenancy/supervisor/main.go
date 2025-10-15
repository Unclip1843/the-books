
package main

import (
    "context"
    "crypto/hmac"
    "crypto/sha256"
    "database/sql"
    "encoding/hex"
    "encoding/json"
    "errors"
    "fmt"
    "io"
    "log"
    "net"
    "net/http"
    "net/http/httputil"
    "os"
    "os/signal"
    "strconv"
    "strings"
    "sync"
    "syscall"
    "time"

    "github.com/docker/docker/api/types"
    "github.com/docker/docker/api/types/container"
    "github.com/docker/docker/api/types/filters"
    "github.com/docker/docker/api/types/network"
    "github.com/docker/docker/api/types/volume"
    "github.com/docker/docker/client"
    "github.com/docker/go-connections/nat"
    "github.com/gofiber/fiber/v2"
    "github.com/valyala/fasthttp/fasthttpadaptor"
    "github.com/golang-jwt/jwt/v5"
    "github.com/google/uuid"
    "github.com/redis/go-redis/v9"
    _ "modernc.org/sqlite"
)

type Config struct {
    PublicBaseURL string
    CookieName    string
    CookieSecret  []byte
    CookieDomain  string
    CookieTTLMin  int
    SlidingWinMin int

    RedisURL string
    CentralDBPath string

    IdleMinutes int
    WarmupTimeoutSec int

    TenantImage string
    TenantExposePort string
    TenantCPU int
    TenantRAMGB int
    TenantPIDs int
    TenantNSKey []byte

    AnthropicKey string
    OpenAIKey string
}

func mustEnv(k, def string) string {
    v := strings.TrimSpace(os.Getenv(k))
    if v == "" {
        if def == "" { log.Fatalf("missing env %s", k) }
        return def
    }
    return v
}
func atoiEnv(k string, def int) int {
    v := strings.TrimSpace(os.Getenv(k))
    if v == "" { return def }
    i, err := strconv.Atoi(v); if err != nil { return def }
    return i
}

func loadConfig() Config {
    return Config{
        PublicBaseURL: mustEnv("PUBLIC_BASE_URL","https://backend.xavior.ai"),
        CookieName: mustEnv("COOKIE_NAME","session"),
        CookieSecret: []byte(mustEnv("COOKIE_JWT_SECRET","change-me-32-bytes-min")),
        CookieDomain: mustEnv("COOKIE_DOMAIN","backend.xavior.ai"),
        CookieTTLMin: atoiEnv("COOKIE_TTL_MINUTES",30),
        SlidingWinMin: atoiEnv("SLIDING_REFRESH_WINDOW_MINUTES",10),
        RedisURL: mustEnv("REDIS_URL","redis://default:pass@redis:6379/0"),
        CentralDBPath: mustEnv("CENTRAL_DB_PATH","/var/lib/supervisor/central.db"),
        IdleMinutes: atoiEnv("IDLE_MINUTES",20),
        WarmupTimeoutSec: atoiEnv("WARMUP_HEALTH_TIMEOUT_SECONDS",45),
        TenantImage: mustEnv("TENANT_IMAGE","tenant-base:latest"),
        TenantExposePort: mustEnv("TENANT_EXPOSE_PORT","8080"),
        TenantCPU: atoiEnv("TENANT_CPU",2),
        TenantRAMGB: atoiEnv("TENANT_RAM_GB",4),
        TenantPIDs: atoiEnv("TENANT_PIDS",512),
        TenantNSKey: []byte(mustEnv("TENANT_NAMESPACE_KEY","rotate-this-32-byte-key")),
        AnthropicKey: mustEnv("ANTHROPIC_API_KEY",""),
        OpenAIKey: mustEnv("OPENAI_API_KEY",""),
    }
}

type Supervisor struct{
    cfg Config
    cli *client.Client
    rdb *redis.Client
    db *sql.DB

    lastSeen sync.Map // tenant -> time.Time
    proxies sync.Map // tenant -> *httputil.ReverseProxy
}

func openRedis(url string) *redis.Client {
    opt, err := redis.ParseURL(url)
    if err != nil { log.Fatalf("redis parse: %v", err) }
    r := redis.NewClient(opt)
    ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second); defer cancel()
    if err := r.Ping(ctx).Err(); err != nil { log.Fatalf("redis ping: %v", err) }
    return r
}

func openCentralDB(path string) *sql.DB {
    db, err := sql.Open("sqlite", path+"?_pragma=journal_mode(WAL)&_pragma=synchronous(NORMAL)")
    if err != nil { log.Fatalf("sqlite open: %v", err) }
    _, err = db.Exec(`CREATE TABLE IF NOT EXISTS admin_conversations(
        user_id TEXT NOT NULL,
        conversation_id TEXT NOT NULL,
        started_at TEXT NOT NULL,
        ended_at TEXT NOT NULL,
        tokens_in INTEGER NOT NULL,
        tokens_out INTEGER NOT NULL,
        cost_usd REAL NOT NULL,
        model TEXT NOT NULL,
        provider TEXT NOT NULL,
        message_count INTEGER NOT NULL,
        last_active_at TEXT NOT NULL,
        feedback_count INTEGER DEFAULT 0,
        error_count INTEGER DEFAULT 0,
        flags_json TEXT,
        PRIMARY KEY(user_id, conversation_id)
    );`)
    if err != nil { log.Fatalf("sqlite schema: %v", err) }
    return db
}

func newSupervisor() *Supervisor {
    cfg := loadConfig()
    cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
    if err != nil { log.Fatalf("docker: %v", err) }
    rdb := openRedis(cfg.RedisURL)
    db := openCentralDB(cfg.CentralDBPath)
    return &Supervisor{cfg: cfg, cli: cli, rdb: rdb, db: db}
}

func (s *Supervisor) userToTenant(userID string) string {
    h := hmac.New(sha256.New, s.cfg.TenantNSKey)
    h.Write([]byte(strings.ToLower(userID)))
    id := hex.EncodeToString(h.Sum(nil))[:12]
    return "app__" + id
}

func (s *Supervisor) issueJWT(userID, email, plan string, onboardingCompleted bool) (string, string, time.Time, error) {
    now := time.Now().UTC()
    exp := now.Add(time.Duration(s.cfg.CookieTTLMin) * time.Minute)
    jti := uuid.NewString()
    claims := jwt.MapClaims{
        "sub": userID,
        "email": email,
        "plan": plan,
        "onboarding_completed": onboardingCompleted,
        "jti": jti,
        "iat": now.Unix(),
        "exp": exp.Unix(),
    }
    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    ss, err := token.SignedString(s.cfg.CookieSecret)
    return ss, jti, exp, err
}

func (s *Supervisor) verifyJWT(ss string) (jwt.MapClaims, error) {
    token, err := jwt.Parse(ss, func(t *jwt.Token) (interface{}, error) {
        if t.Method.Alg() != jwt.SigningMethodHS256.Alg() { return nil, fmt.Errorf("bad alg") }
        return s.cfg.CookieSecret, nil
    })
    if err != nil || !token.Valid { return nil, errors.New("invalid token") }
    claims, ok := token.Claims.(jwt.MapClaims)
    if !ok { return nil, errors.New("bad claims") }
    // revocation
    jti, _ := claims["jti"].(string)
    if jti != "" {
        ctx, cancel := context.WithTimeout(context.Background(), 300*time.Millisecond); defer cancel()
        if val, err := s.rdb.Get(ctx, "jwt:revoked:"+jti).Result(); err == nil && val == "1" {
            return nil, errors.New("revoked")
        }
    }
    return claims, nil
}

func (s *Supervisor) setJWTCookie(c *fiber.Ctx, ss string, exp time.Time) {
    c.Cookie(&fiber.Cookie{
        Name: s.cfg.CookieName, Value: ss, Expires: exp,
        HTTPOnly: true, Secure: true, SameSite: "Strict",
        Domain: s.cfg.CookieDomain, Path: "/",
    })
}

func natPortSet(p string) nat.PortSet {
    ps := nat.PortSet{}
    ps[nat.Port(fmt.Sprintf("%s/tcp", p))] = struct{}{}
    return ps
}
func natPortMap(p string) nat.PortMap {
    m := nat.PortMap{}
    m[nat.Port(fmt.Sprintf("%s/tcp", p))] = []nat.PortBinding{{HostIP: "0.0.0.0", HostPort: ""}}
    return m
}

func (s *Supervisor) ensureNetwork(ctx context.Context, name string) error {
    nl, err := s.cli.NetworkList(ctx, types.NetworkListOptions{Filters: filters.NewArgs(filters.Arg("name", name))})
    if err != nil { return err }
    if len(nl) > 0 { return nil }
    _, err = s.cli.NetworkCreate(ctx, name, types.NetworkCreate{
        Driver: "bridge",
        Internal: false,
        Attachable: true,
    })
    return err
}

func (s *Supervisor) ensureVolume(ctx context.Context, name string) error {
    vl, err := s.cli.VolumeList(ctx, volume.ListOptions{Filters: filters.NewArgs(filters.Arg("name", name))})
    if err != nil { return err }
    if len(vl.Volumes) > 0 { return nil }
    _, err = s.cli.VolumeCreate(ctx, volume.CreateOptions{Name:name, Driver:"local"})
    return err
}

func (s *Supervisor) containerByName(ctx context.Context, name string) (*types.Container, error) {
    list, err := s.cli.ContainerList(ctx, container.ListOptions{All:true})
    if err != nil { return nil, err }
    for _, c := range list {
        for _, n := range c.Names {
            if strings.TrimPrefix(n,"/")==name { return &c, nil }
        }
    }
    return nil, errors.New("not found")
}

func (s *Supervisor) ensureTenant(ctx context.Context, userID string) (string, error) {
    tenant := s.userToTenant(userID)
    netName := "net__" + tenant
    if err := s.ensureNetwork(ctx, netName); err != nil { return "", err }
    filesVol := "vol__" + tenant + "__files"
    histVol := "vol__" + tenant + "__history"
    if err := s.ensureVolume(ctx, filesVol); err != nil { return "", err }
    if err := s.ensureVolume(ctx, histVol); err != nil { return "", err }

    cont, _ := s.containerByName(ctx, tenant)
    expose := s.cfg.TenantExposePort
    if cont == nil {
        resp, err := s.cli.ContainerCreate(ctx, &container.Config{
            Image: s.cfg.TenantImage,
            User: "0:0",
            Env: []string{
                "NODE_ENV=production",
                "XAV_USER_ID="+userID,
                "ANTHROPIC_API_KEY="+s.cfg.AnthropicKey,
                "OPENAI_API_KEY="+s.cfg.OpenAIKey,
                "PUBLIC_BASE_URL="+s.cfg.PublicBaseURL,
            },
            ExposedPorts: natPortSet(expose),
            Healthcheck: &container.HealthConfig{
                Test: []string{"CMD-SHELL", fmt.Sprintf("wget -qO- http://127.0.0.1:%s/health || exit 1", expose)},
                Interval: 2*time.Second, Timeout: 1*time.Second, Retries: 15,
            },
            Labels: map[string]string{"tenant": tenant},
        }, &container.HostConfig{
            CapDrop: []string{"ALL"},
            Resources: container.Resources{
                Memory: int64(s.cfg.TenantRAMGB)*1024*1024*1024,
                NanoCPUs: int64(s.cfg.TenantCPU)*1_000_000_000,
                PidsLimit: func() *int64 { v := int64(512); return &v }(),
            },
            Binds: []string{
                fmt.Sprintf("%s:/app/data/users/%s/files", filesVol, userID),
                fmt.Sprintf("%s:/app/data/db", histVol),
            },
            PortBindings: natPortMap(expose),
        }, &network.NetworkingConfig{
            EndpointsConfig: map[string]*network.EndpointSettings{ netName: {} },
        }, nil, tenant)
        if err != nil { return "", err }
        if err := s.cli.ContainerStart(ctx, resp.ID, container.StartOptions{}); err != nil { return "", err }
    } else {
        _ = s.cli.NetworkConnect(ctx, netName, cont.ID, nil)
        _ = s.cli.ContainerStart(ctx, cont.ID, container.StartOptions{})
    }

    deadline := time.Now().Add(time.Duration(s.cfg.WarmupTimeoutSec)*time.Second)
    for time.Now().Before(deadline) {
        ci, _ := s.inspectByName(ctx, tenant)
        if ci.State != nil && ci.State.Health != nil && ci.State.Health.Status == "healthy" {
            for n, ep := range ci.NetworkSettings.Networks {
                if strings.HasPrefix(n,"net__") { return ep.IPAddress, nil }
            }
            break
        }
        time.Sleep(500*time.Millisecond)
    }
    return "", errors.New("tenant failed to become healthy")
}

func (s *Supervisor) inspectByName(ctx context.Context, name string) (types.ContainerJSON, error) {
    c, err := s.containerByName(ctx, name)
    if err != nil { return types.ContainerJSON{}, err }
    return s.cli.ContainerInspect(ctx, c.ID)
}

func (s *Supervisor) isRunning(ctx context.Context, tenant string) bool {
    c, err := s.containerByName(ctx, tenant)
    if err != nil { return false }
    return c.State == "running"
}

func (s *Supervisor) stopTenant(ctx context.Context, tenant string) error {
    c, err := s.containerByName(ctx, tenant)
    if err != nil { return nil }
    timeout := 10 * time.Second
    secs := int(timeout.Seconds())
    return s.cli.ContainerStop(ctx, c.ID, container.StopOptions{Timeout: &secs})
}

func (s *Supervisor) proxyToTenant(c *fiber.Ctx, userID string) error {
    tenant := s.userToTenant(userID)
    if !s.isRunning(c.Context(), tenant) {
        c.Set("X-Wake-Required","1")
        return c.Status(401).JSON(fiber.Map{"error":"sleeping"})
    }
    var rp *httputil.ReverseProxy
    if v, ok := s.proxies.Load(tenant); ok {
        rp = v.(*httputil.ReverseProxy)
    } else {
        ci, err := s.inspectByName(c.Context(), tenant)
        if err != nil { return c.Status(502).JSON(fiber.Map{"error":"inspect_failed"}) }
        ip := ""
        for n, ep := range ci.NetworkSettings.Networks {
            if strings.HasPrefix(n,"net__") { ip = ep.IPAddress; break }
        }
        if ip == "" { return c.Status(502).JSON(fiber.Map{"error":"no_ip"}) }
        targetHost := fmt.Sprintf("%s:%s", ip, s.cfg.TenantExposePort)
        director := func(r *http.Request) {
            originalHost := r.Host
            r.URL.Scheme = "http"
            r.URL.Host = targetHost
            r.Host = targetHost
            if originalHost != "" {
                r.Header.Set("X-Forwarded-Host", originalHost)
            }
            if host, _, err := net.SplitHostPort(r.RemoteAddr); err == nil {
                r.Header.Set("X-Forwarded-For", host)
            }
            r.Header.Set("X-Forwarded-Proto", "https")
            r.Header.Set("X-User-ID", userID)
        }
        rp = &httputil.ReverseProxy{
            Director: director,
            Transport: &http.Transport{
                DialContext: (&net.Dialer{Timeout: 5*time.Second}).DialContext,
                MaxIdleConns: 100,
                IdleConnTimeout: 90*time.Second,
            },
        }
        s.proxies.Store(tenant, rp)
    }
    s.lastSeen.Store(tenant, time.Now())

    handler := fasthttpadaptor.NewFastHTTPHandler(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        rp.ServeHTTP(w, r)
    }))
    handler(c.Context())
    return nil
}

func (s *Supervisor) handleHealth(c *fiber.Ctx) error {
    ctx, cancel := context.WithTimeout(context.Background(), 300*time.Millisecond); defer cancel()
    rOK := s.rdb.Ping(ctx).Err()==nil
    dbOK := s.db.PingContext(ctx)==nil
    return c.JSON(fiber.Map{"status":"ok","time":time.Now().UTC(),"redis_ok":rOK,"central_db_ok":dbOK})
}

func (s *Supervisor) handleLogin(c *fiber.Ctx) error {
    var body struct{ UserID, Email, Plan string; OnboardingCompleted bool }
    if err := c.BodyParser(&body); err != nil || body.UserID=="" || body.Email=="" {
        return c.Status(400).JSON(fiber.Map{"error":"user_id and email required"})
    }
    if strings.TrimSpace(body.Plan)=="" { body.Plan="free" }
    tok, _, exp, err := s.issueJWT(body.UserID, body.Email, body.Plan, body.OnboardingCompleted)
    if err != nil { return c.Status(500).JSON(fiber.Map{"error":"jwt_issue"}) }
    s.setJWTCookie(c, tok, exp)
    return c.JSON(fiber.Map{"userId":body.UserID,"email":body.Email,"plan":body.Plan,"onboarding_completed":body.OnboardingCompleted})
}


func (s *Supervisor) handleLogout(c *fiber.Ctx) error {
    ss := c.Cookies(s.cfg.CookieName)
    if ss != "" {
        token, _ := jwt.Parse(ss, func(t *jwt.Token)(interface{},error){ return s.cfg.CookieSecret, nil })
        if token != nil && token.Valid {
            if claims, ok := token.Claims.(jwt.MapClaims); ok {
                if jti, _ := claims["jti"].(string); jti != "" {
                    expUnix, _ := claims["exp"].(float64)
                    ttl := time.Until(time.Unix(int64(expUnix),0))
                    ctx, cancel := context.WithTimeout(context.Background(), 500*time.Millisecond); defer cancel()
                    _ = s.rdb.Set(ctx, "jwt:revoked:"+jti, "1", ttl).Err()
                }
            }
        }
    }
    c.Cookie(&fiber.Cookie{Name:s.cfg.CookieName, Value:"", Expires: time.Now().Add(-time.Hour), HTTPOnly:true, Secure:true, SameSite:"Strict", Domain:s.cfg.CookieDomain, Path:"/"})
    return c.SendStatus(204)
}

func (s *Supervisor) handleSessionStatus(c *fiber.Ctx) error {
    ss := c.Cookies(s.cfg.CookieName)
    if ss == "" { return c.JSON(fiber.Map{"valid":false}) }
    claims, err := s.verifyJWT(ss)
    if err != nil { return c.JSON(fiber.Map{"valid":false}) }
    expUnix, _ := claims["exp"].(float64)
    exp := time.Unix(int64(expUnix),0)
    if time.Until(exp) <= time.Duration(s.cfg.SlidingWinMin)*time.Minute {
        tok, _, newExp, err := s.issueJWT(
            fmt.Sprint(claims["sub"]), fmt.Sprint(claims["email"]), fmt.Sprint(claims["plan"]), claims["onboarding_completed"] == true)
        if err == nil { s.setJWTCookie(c, tok, newExp) }
    }
    return c.JSON(fiber.Map{
        "valid": true,
        "userId": fmt.Sprint(claims["sub"]),
        "email": fmt.Sprint(claims["email"]),
        "plan": fmt.Sprint(claims["plan"]),
        "onboarding_completed": claims["onboarding_completed"] == true,
    })
}

func (s *Supervisor) handleWarmup(c *fiber.Ctx) error {
    var body struct{ UserID string `json:"user_id"` }
    if err := c.BodyParser(&body); err != nil || strings.TrimSpace(body.UserID)=="" {
        return c.Status(400).JSON(fiber.Map{"error":"user_id required"})
    }
    ip, err := s.ensureTenant(c.Context(), body.UserID)
    if err != nil {
        log.Printf(`{"level":"error","evt":"warmup_error","user_id":"%s","err":%q}`, body.UserID, err.Error())
        return c.Status(503).JSON(fiber.Map{"error":"warmup_failed"})
    }
    log.Printf(`{"level":"info","evt":"warmup_success","user_id":"%s","ip":"%s"}`, body.UserID, ip)
    return c.JSON(fiber.Map{"tenant": s.userToTenant(body.UserID), "state":"running"})
}

func (s *Supervisor) handleStatus(c *fiber.Ctx) error {
    userID := c.Query("user_id")
    if strings.TrimSpace(userID)=="" { return c.Status(400).JSON(fiber.Map{"error":"user_id required"}) }
    tenant := s.userToTenant(userID)
    running := s.isRunning(c.Context(), tenant)
    return c.JSON(fiber.Map{"tenant":tenant,"running":running})
}

func (s *Supervisor) handleAuthz(c *fiber.Ctx) error {
    ss := c.Cookies(s.cfg.CookieName)
    if ss == "" { return c.Status(401).SendString("unauthorized") }
    claims, err := s.verifyJWT(ss)
    if err != nil { return c.Status(401).SendString("unauthorized") }
    userID := fmt.Sprint(claims["sub"])
    tenant := s.userToTenant(userID)
    if !s.isRunning(c.Context(), tenant) {
        c.Set("X-Wake-Required","1")
        return c.Status(401).SendString("sleeping")
    }
    c.Set("X-User-ID", userID)
    c.Set("X-User-Container", tenant)
    return c.SendStatus(200)
}

func (s *Supervisor) handleAdminTenants(c *fiber.Ctx) error {
    list, err := s.cli.ContainerList(c.Context(), container.ListOptions{All:true})
    if err != nil { return c.Status(500).JSON(fiber.Map{"error":"docker_list"}) }
    type row struct { Container, State, LastSeen string }
    var out []row
    for _, ct := range list {
        tlabel := ct.Labels["tenant"]; if tlabel=="" { continue }
        last := ""
        if v, ok := s.lastSeen.Load(tlabel); ok { last = v.(time.Time).UTC().Format(time.RFC3339) }
        out = append(out, row{Container:tlabel, State:ct.State, LastSeen:last})
    }
    return c.JSON(out)
}

func (s *Supervisor) handleAdminLogs(c *fiber.Ctx) error {
    userID := c.Params("id")
    tenant := s.userToTenant(userID)
    cont, err := s.containerByName(c.Context(), tenant)
    if err != nil { return c.Status(404).SendString("not found") }
    r, err := s.cli.ContainerLogs(c.Context(), cont.ID, container.LogsOptions{ShowStdout:true, ShowStderr:true, Tail:"1000"})
    if err != nil { return c.Status(500).SendString("log error") }
    defer r.Close()
    b, _ := io.ReadAll(r)
    c.Set("Content-Type","text/plain; charset=utf-8")
    _, _ = c.WriteString(stripANSI(string(b)))
    return nil
}

func stripANSI(s string) string {
    // remove most ANSI escape codes
    out := make([]rune, 0, len(s))
    skip := false
    for _, r := range s {
        if r == 0x1b { skip = true; continue }
        if skip {
            if (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') { skip = false }
            continue
        }
        out = append(out, r)
    }
    return string(out)
}

func (s *Supervisor) handleAdminStop(c *fiber.Ctx) error {
    userID := c.Params("id")
    tenant := s.userToTenant(userID)
    if err := s.stopTenant(c.Context(), tenant); err != nil {
        return c.Status(500).JSON(fiber.Map{"error":"stop_failed"})
    }
    return c.JSON(fiber.Map{"tenant":tenant,"state":"stopped"})
}

func (s *Supervisor) handleIngestSummary(c *fiber.Ctx) error {
    var body struct {
        UserID string `json:"user_id"`
        ConversationID string `json:"conversation_id"`
        StartedAt string `json:"started_at"`
        EndedAt string `json:"ended_at"`
        TokensIn int `json:"tokens_in"`
        TokensOut int `json:"tokens_out"`
        CostUSD float64 `json:"cost_usd"`
        Model string `json:"model"`
        Provider string `json:"provider"`
        MessageCount int `json:"message_count"`
        LastActiveAt string `json:"last_active_at"`
        FeedbackCount int `json:"feedback_count"`
        ErrorCount int `json:"error_count"`
        Flags map[string]any `json:"flags"`
    }
    if err := c.BodyParser(&body); err != nil {
        return c.Status(400).JSON(fiber.Map{"error":"bad_json"})
    }
    flagsJSON, _ := json.Marshal(body.Flags)
    _, err := s.db.ExecContext(c.Context(), `INSERT INTO admin_conversations
        (user_id, conversation_id, started_at, ended_at, tokens_in, tokens_out, cost_usd, model, provider, message_count, last_active_at, feedback_count, error_count, flags_json)
        VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        ON CONFLICT(user_id, conversation_id) DO UPDATE SET
          started_at=excluded.started_at, ended_at=excluded.ended_at,
          tokens_in=excluded.tokens_in, tokens_out=excluded.tokens_out,
          cost_usd=excluded.cost_usd, model=excluded.model, provider=excluded.provider,
          message_count=excluded.message_count, last_active_at=excluded.last_active_at,
          feedback_count=excluded.feedback_count, error_count=excluded.error_count,
          flags_json=excluded.flags_json
    `, body.UserID, body.ConversationID, body.StartedAt, body.EndedAt,
       body.TokensIn, body.TokensOut, body.CostUSD, body.Model, body.Provider,
       body.MessageCount, body.LastActiveAt, body.FeedbackCount, body.ErrorCount, string(flagsJSON))
    if err != nil {
        return c.Status(500).JSON(fiber.Map{"error":"db_upsert_failed"})
    }
    return c.SendStatus(204)
}

func (s *Supervisor) reaper() {
    tick := time.NewTicker(1 * time.Minute); defer tick.Stop()
    for range tick.C {
        now := time.Now()
        idle := time.Duration(s.cfg.IdleMinutes) * time.Minute
        s.lastSeen.Range(func(key, value any) bool {
            tenant := key.(string)
            last := value.(time.Time)
            if now.Sub(last) > idle {
                ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
                _ = s.stopTenant(ctx, tenant)
                cancel()
                s.lastSeen.Delete(tenant)
                log.Printf(`{"level":"info","evt":"idle_stop","tenant":"%s"}`, tenant)
            }
            return true
        })
    }
}

func main() {
    sup := newSupervisor()
    app := fiber.New(fiber.Config{
        ReadTimeout: 30*time.Second,
        WriteTimeout: 60*time.Second,
        BodyLimit: 10*1024*1024,
    })

    app.Get("/health", sup.handleHealth)
    app.Get("/ready", sup.handleHealth)

    app.Post("/auth/login", sup.handleLogin)
    app.Post("/auth/logout", sup.handleLogout)
    app.Get("/session/status", sup.handleSessionStatus)

    app.Post("/warmup", sup.handleWarmup)
    app.Get("/status", sup.handleStatus)
    app.Post("/admin/ingest-summary", sup.handleIngestSummary)
    app.Post("/internal/summary", sup.handleIngestSummary)

    app.Get("/tenants", sup.handleAdminTenants)
    app.Get("/tenants/:id/logs", sup.handleAdminLogs)
    app.Post("/tenants/:id/stop", sup.handleAdminStop)

    app.All("/*", func(c *fiber.Ctx) error {
        ss := c.Cookies(sup.cfg.CookieName)
        if ss == "" { return c.Status(401).JSON(fiber.Map{"valid":false}) }
        claims, err := sup.verifyJWT(ss)
        if err != nil { return c.Status(401).JSON(fiber.Map{"valid":false}) }
        expUnix, _ := claims["exp"].(float64)
        exp := time.Unix(int64(expUnix),0)
        if time.Until(exp) <= time.Duration(sup.cfg.SlidingWinMin)*time.Minute {
            tok, _, newExp, err := sup.issueJWT(
                fmt.Sprint(claims["sub"]), fmt.Sprint(claims["email"]), fmt.Sprint(claims["plan"]), claims["onboarding_completed"] == true)
            if err == nil { sup.setJWTCookie(c, tok, newExp) }
        }
        userID := fmt.Sprint(claims["sub"])
        return sup.proxyToTenant(c, userID)
    })

    go sup.reaper()

    go func(){
        if err := app.Listen(":4010"); err != nil {
            log.Println("fiber stopped:", err)
        }
    }()
    log.Println("supervisor listening on :4010")

    sig := make(chan os.Signal, 1)
    signal.Notify(sig, syscall.SIGINT, syscall.SIGTERM)
    <-sig
    _ = sup.db.Close()
}
