# Security Policy

## Development Environment Only

**This project is designed exclusively for local development purposes.** It is NOT intended for production use.

### Why This Should NOT Be Used in Production

1. **Weak Default Credentials** - Default passwords are intentionally simple for development convenience
2. **No SSL/TLS in Production Mode** - Uses self-signed certificates only
3. **Exposed Database Ports** - All database ports are exposed to localhost
4. **No Rate Limiting** - No request throttling implemented
5. **Debug Features Enabled** - Xdebug and other debugging tools are available
6. **Root User in Containers** - Some services run as root for simplicity

## Security Best Practices

### Before Starting

1. **Never commit `.env` file** - It's in `.gitignore` for a reason
2. **Change default passwords** - Update all passwords in `.env` before use
3. **Use strong passwords** - Generate secure passwords for all services

### Credentials to Change

| Service | Variable | Default |
|---------|----------|---------|
| MySQL | `DB_PASSWORD` | `secret` |
| MySQL Root | `DB_ROOT_PASSWORD` | `root` |
| PostgreSQL | `POSTGRES_PASSWORD` | `secret` |

### SSL Certificates

- Generated certificates are **self-signed** and for development only
- Certificate files are ignored by git (`.gitignore`)
- Never use these certificates in production

### Network Security

By default, these ports are exposed to your local machine:
- HTTP: 80
- HTTPS: 443
- MySQL: 3306
- PostgreSQL: 5432
- Redis: 6379
- Mailpit: 1025, 8025

**Recommendation:** Change ports in `.env` if you have conflicts or security concerns.

## Security Headers Implemented

The following security headers are configured in nginx:

- `X-Frame-Options: SAMEORIGIN`
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection: 1; mode=block`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Strict-Transport-Security` (HTTPS only)
