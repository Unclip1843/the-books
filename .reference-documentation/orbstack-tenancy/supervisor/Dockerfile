# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM golang:alpine AS build
ARG TARGETOS=linux
ARG TARGETARCH

WORKDIR /app
RUN apk add --no-cache ca-certificates build-base git

COPY go.mod go.sum ./
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    go mod download

COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH:-$(go env GOARCH)} go build -o /out/supervisor ./main.go

FROM gcr.io/distroless/base-debian12
WORKDIR /srv
COPY --from=build /out/supervisor /usr/local/bin/supervisor
# Run as root for local dev (volume permissions)
# USER 65532:65532
EXPOSE 4010
ENTRYPOINT ["/usr/local/bin/supervisor"]
