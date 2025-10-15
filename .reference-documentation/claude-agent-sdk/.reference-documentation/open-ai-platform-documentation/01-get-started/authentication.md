# OpenAI Platform - Authentication

**Source:** https://platform.openai.com/docs/guides/authentication
**Fetched:** 2025-10-11

## Overview

The OpenAI API uses API keys for authentication. This guide covers how to securely create, manage, and use API keys to access OpenAI services.

**Key Concepts:**
- API keys authenticate your requests
- Keys are associated with organizations and projects
- Proper key management is critical for security
- Best practices prevent unauthorized access and cost overruns

---

## Creating API Keys

### Generate Your First Key

1. **Sign in to Platform**
   ```
   https://platform.openai.com
   ```

2. **Navigate to API Keys**
   ```
   Click your profile → "API keys"
   Or visit: https://platform.openai.com/api-keys
   ```

3. **Create New Key**
   ```
   Click "Create new secret key"
   ```

4. **Configure Key**
   ```
   Name: Development, Production, CI/CD, etc.
   Project: Select or create project
   Permissions: Full access or restricted
   ```

5. **Save Key Securely**
   ```
   Key format: sk-proj-...

   IMPORTANT: Copy immediately!
   You cannot view the key again after creation.
   ```

### Key Types

**Project Keys** (Recommended)
```
Format: sk-proj-abc123...
Scope: Single project
Use: Production applications
```

**Service Account Keys**
```
Format: sk-svcacct-abc123...
Scope: Organization-wide
Use: Automation, CI/CD
```

**User Keys** (Legacy)
```
Format: sk-abc123...
Scope: User account
Use: Personal development (deprecated)
```

---

## Using API Keys

### Environment Variables (Recommended)

**Linux / macOS:**

```bash
# Temporary (current session only)
export OPENAI_API_KEY='sk-proj-...'

# Permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export OPENAI_API_KEY="sk-proj-..."' >> ~/.bashrc
source ~/.bashrc
```

**Windows:**

```cmd
# PowerShell
$env:OPENAI_API_KEY = "sk-proj-..."

# Command Prompt
setx OPENAI_API_KEY "sk-proj-..."
```

### .env Files

Create a `.env` file in your project root:

```bash
# .env
OPENAI_API_KEY=sk-proj-abc123...
OPENAI_ORGANIZATION=org-xyz789...
```

**Python with python-dotenv:**

```python
from dotenv import load_dotenv
import os

# Load environment variables from .env
load_dotenv()

from openai import OpenAI

# Client automatically reads OPENAI_API_KEY
client = OpenAI()
```

**TypeScript with dotenv:**

```typescript
import 'dotenv/config';
import OpenAI from 'openai';

// Client automatically reads OPENAI_API_KEY
const client = new OpenAI();
```

**IMPORTANT:** Add `.env` to `.gitignore`!

```bash
# .gitignore
.env
.env.local
.env.*.local
```

### Explicit Key Passing

**Python:**

```python
from openai import OpenAI

# Pass key explicitly (NOT recommended for production)
client = OpenAI(api_key="sk-proj-...")

# Better: read from environment
import os
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
```

**TypeScript:**

```typescript
import OpenAI from 'openai';

// Pass key explicitly (NOT recommended for production)
const client = new OpenAI({ apiKey: 'sk-proj-...' });

// Better: read from environment
const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
```

### Organization and Project IDs

**Set Organization:**

```python
from openai import OpenAI

client = OpenAI(
    api_key=os.environ.get("OPENAI_API_KEY"),
    organization="org-xyz789..."  # Optional
)
```

**Set Project (via headers):**

```python
import httpx
from openai import OpenAI

client = OpenAI(
    api_key=os.environ.get("OPENAI_API_KEY"),
    default_headers={
        "OpenAI-Project": "proj-abc123..."
    }
)
```

---

## Security Best Practices

### 1. Never Expose Keys

**❌ DON'T: Hardcode in Source Code**

```python
# NEVER DO THIS!
client = OpenAI(api_key="sk-proj-abc123...")

# NEVER DO THIS!
API_KEY = "sk-proj-abc123..."
```

**❌ DON'T: Expose in Client-Side Code**

```javascript
// NEVER expose in browser JavaScript!
const apiKey = "sk-proj-abc123...";
fetch('https://api.openai.com/v1/chat/completions', {
    headers: { 'Authorization': `Bearer ${apiKey}` }
});
```

**✅ DO: Use Backend Proxy**

```javascript
// Frontend: Call your backend
fetch('/api/chat', {
    method: 'POST',
    body: JSON.stringify({ message: 'Hello' })
});

// Backend: API key stays on server
app.post('/api/chat', async (req, res) => {
    const response = await openai.chat.completions.create({
        model: 'gpt-4o',
        messages: [{ role: 'user', content: req.body.message }]
    });
    res.json(response);
});
```

### 2. Use Environment Variables

**✅ DO:**

```python
import os
from openai import OpenAI

# Read from environment
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

# Or let SDK auto-detect
client = OpenAI()  # Reads OPENAI_API_KEY automatically
```

### 3. Add .env to .gitignore

**✅ DO:**

```bash
# .gitignore
.env
.env.local
.env.production
.env.*.local
secrets.json
config/secrets.yaml
```

**Check Before Committing:**

```bash
# Search for potential secrets
git grep -i "sk-proj"
git grep -i "api_key"

# Use git-secrets to prevent commits
git secrets --install
git secrets --register-aws
```

### 4. Rotate Keys Regularly

**Best Practice: Rotate every 90 days**

```bash
# 1. Create new key
# 2. Update production environment
# 3. Deploy with new key
# 4. Monitor for 24 hours
# 5. Delete old key
```

**Automated Rotation (Python):**

```python
from openai import OpenAI
import os
from datetime import datetime, timedelta

def rotate_api_key_if_needed():
    """Check if API key needs rotation."""
    key_created_date = os.environ.get("API_KEY_CREATED_DATE")

    if key_created_date:
        created = datetime.fromisoformat(key_created_date)
        age = datetime.now() - created

        if age > timedelta(days=90):
            print("⚠️  API key is over 90 days old. Consider rotating.")
            return True

    return False

# Check on application start
if rotate_api_key_if_needed():
    # Send alert to ops team
    send_alert("API key rotation needed")
```

### 5. Use Secret Management Tools

**AWS Secrets Manager:**

```python
import boto3
import json
from openai import OpenAI

def get_secret():
    """Retrieve API key from AWS Secrets Manager."""
    client = boto3.client('secretsmanager', region_name='us-east-1')
    response = client.get_secret_value(SecretId='openai/api-key')
    secret = json.loads(response['SecretString'])
    return secret['OPENAI_API_KEY']

# Use in application
openai_client = OpenAI(api_key=get_secret())
```

**HashiCorp Vault:**

```python
import hvac
from openai import OpenAI

def get_secret_from_vault():
    """Retrieve API key from Vault."""
    client = hvac.Client(url='http://vault:8200')
    client.auth.approle.login(
        role_id='role-id',
        secret_id='secret-id'
    )

    secret = client.secrets.kv.v2.read_secret_version(
        path='openai/api-key'
    )
    return secret['data']['data']['key']

openai_client = OpenAI(api_key=get_secret_from_vault())
```

**GCP Secret Manager:**

```python
from google.cloud import secretmanager
from openai import OpenAI

def get_secret():
    """Retrieve API key from GCP Secret Manager."""
    client = secretmanager.SecretManagerServiceClient()
    name = "projects/PROJECT_ID/secrets/openai-api-key/versions/latest"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode('UTF-8')

openai_client = OpenAI(api_key=get_secret())
```

**Azure Key Vault:**

```python
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from openai import OpenAI

def get_secret():
    """Retrieve API key from Azure Key Vault."""
    credential = DefaultAzureCredential()
    vault_url = "https://your-vault.vault.azure.net/"
    client = SecretClient(vault_url=vault_url, credential=credential)
    secret = client.get_secret("openai-api-key")
    return secret.value

openai_client = OpenAI(api_key=get_secret())
```

### 6. Implement Rate Limiting

**Backend Rate Limiting:**

```python
from flask import Flask, request, jsonify
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

app = Flask(__name__)
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["100 per day", "10 per hour"]
)

@app.route('/api/chat', methods=['POST'])
@limiter.limit("5 per minute")  # Per-endpoint limit
def chat():
    # Your OpenAI API call here
    pass
```

### 7. Monitor Usage

**Set Spending Limits:**

```
Platform → Settings → Billing → Usage limits

Soft limit: $10/month (notification)
Hard limit: $50/month (stop billing)
```

**Track Usage in Code:**

```python
from openai import OpenAI
import logging

client = OpenAI()
usage_logger = logging.getLogger('openai_usage')

def track_api_call(response):
    """Log usage for monitoring."""
    usage = response.usage
    usage_logger.info({
        'model': response.model,
        'prompt_tokens': usage.prompt_tokens,
        'completion_tokens': usage.completion_tokens,
        'total_tokens': usage.total_tokens,
        'timestamp': datetime.now().isoformat()
    })

response = client.chat.completions.create(...)
track_api_call(response)
```

### 8. Scan for Leaked Keys

**GitHub Secret Scanning:**

OpenAI actively scans GitHub for leaked API keys and may automatically disable them.

**Use git-secrets:**

```bash
# Install git-secrets
git clone https://github.com/awslabs/git-secrets.git
cd git-secrets
make install

# Configure for your repo
cd /path/to/your/repo
git secrets --install
git secrets --add 'sk-proj-[A-Za-z0-9]+'
git secrets --add 'sk-[A-Za-z0-9]+'

# Scan history
git secrets --scan-history
```

**Use truffleHog:**

```bash
# Install
pip install truffleHog

# Scan repo
truffleHog --regex --entropy=True .
```

---

## Advanced Authentication

### OAuth 2.1 (Enterprise)

For enterprise applications, consider OAuth 2.1 for more secure, token-based authentication.

```python
# OAuth flow (simplified)
from authlib.integrations.flask_client import OAuth

oauth = OAuth(app)
oauth.register(
    'openai',
    client_id='your-client-id',
    client_secret='your-client-secret',
    authorize_url='https://platform.openai.com/oauth/authorize',
    access_token_url='https://platform.openai.com/oauth/token',
    api_base_url='https://api.openai.com/v1/'
)

# Get access token
token = oauth.openai.authorize_access_token()

# Use token
client = OpenAI(api_key=token['access_token'])
```

### Service Accounts

For automation and CI/CD, use service account keys with limited permissions.

```python
# Service account key
client = OpenAI(
    api_key=os.environ.get("OPENAI_SERVICE_ACCOUNT_KEY")
)

# Limit permissions at organization level
# Platform → Settings → Service accounts → Create
# Select minimal required permissions
```

### IP Whitelisting

Restrict API access to specific IP addresses (available for enterprise plans).

```
Platform → Settings → Security → IP Whitelist
Add allowed IPs: 203.0.113.0/24
```

---

## Key Management Workflow

### Development Environment

```bash
# .env.development
OPENAI_API_KEY=sk-proj-dev-...
OPENAI_ORGANIZATION=org-dev...
```

### Staging Environment

```bash
# .env.staging
OPENAI_API_KEY=sk-proj-staging-...
OPENAI_ORGANIZATION=org-staging...
```

### Production Environment

```bash
# .env.production (stored in secrets manager)
OPENAI_API_KEY=sk-proj-prod-...
OPENAI_ORGANIZATION=org-prod...
```

### Deployment Script

```bash
#!/bin/bash
# deploy.sh

# Get environment
ENV=${1:-production}

# Load secrets from vault
export OPENAI_API_KEY=$(vault kv get -field=key secret/openai/$ENV)

# Deploy application
./deploy-app.sh
```

---

## Common Issues

### Issue: API Key Not Found

```python
openai.OpenAIError: API key not provided
```

**Solutions:**

```bash
# Check environment variable
echo $OPENAI_API_KEY

# Set if missing
export OPENAI_API_KEY='sk-proj-...'

# Or pass explicitly
client = OpenAI(api_key='sk-proj-...')
```

### Issue: Authentication Failed

```python
openai.AuthenticationError: Incorrect API key provided
```

**Solutions:**

1. **Verify key format:**
   ```
   Should start with: sk-proj-...
   No extra spaces or quotes
   ```

2. **Check key is active:**
   ```
   Platform → API keys → Verify status
   ```

3. **Regenerate key:**
   ```
   Delete old key
   Create new key
   Update environment
   ```

### Issue: Organization Access Denied

```python
openai.AuthenticationError: You do not have access to this organization
```

**Solutions:**

```python
# Check organization ID
client = OpenAI(
    api_key=os.environ.get("OPENAI_API_KEY"),
    organization="org-correct-id..."  # Verify this
)

# Or remove organization parameter
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
```

### Issue: Key Revoked

```python
openai.AuthenticationError: Your API key has been revoked
```

**Reason:** OpenAI detected key in public repository or suspicious activity

**Solution:**

1. Create new key immediately
2. Update all environments
3. Audit code for hardcoded keys
4. Set up secret scanning

---

## Security Checklist

Before deploying to production:

- [ ] API keys stored in environment variables or secrets manager
- [ ] `.env` added to `.gitignore`
- [ ] No hardcoded keys in source code
- [ ] Backend proxy for client-side applications
- [ ] Rate limiting implemented
- [ ] Usage monitoring enabled
- [ ] Spending limits configured
- [ ] Key rotation schedule established
- [ ] Secret scanning tools configured
- [ ] IP whitelisting enabled (if available)
- [ ] Service accounts for automation
- [ ] Audit logs enabled
- [ ] Incident response plan documented

---

## Best Practices Summary

| Practice | Priority | Description |
|----------|----------|-------------|
| Environment Variables | **Critical** | Never hardcode keys |
| Backend Proxy | **Critical** | Never expose keys client-side |
| .gitignore | **Critical** | Prevent accidental commits |
| Secrets Manager | **High** | Use Vault, AWS, GCP, Azure |
| Key Rotation | **High** | Rotate every 90 days |
| Rate Limiting | **High** | Prevent abuse |
| Usage Monitoring | **High** | Track costs and usage |
| Secret Scanning | **Medium** | Scan for leaks |
| IP Whitelisting | **Medium** | Restrict access |
| OAuth 2.1 | **Low** | Enterprise only |

---

## Next Steps

1. **[Models →](./models.md)** - Choose the right model for your use case
2. **[Pricing →](./pricing.md)** - Understand token costs
3. **[Core Concepts →](../02-core-concepts/text-generation.md)** - Start building
4. **[Production Best Practices →](../09-going-live/production-best-practices.md)** - Deploy securely

---

## Additional Resources

- **API Key Safety**: https://help.openai.com/en/articles/5112595-best-practices-for-api-key-safety
- **Production Best Practices**: https://platform.openai.com/docs/guides/production-best-practices
- **Security FAQ**: https://help.openai.com/en/collections/3675944-security-and-api-key-safety
- **Usage Dashboard**: https://platform.openai.com/usage
- **Organization Settings**: https://platform.openai.com/account/organization

---

**Next**: [Models →](./models.md)
