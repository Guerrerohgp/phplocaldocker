# PHP Docker Development Environment

A generic, configurable Docker development environment for PHP projects. Supports multiple PHP versions, databases (MySQL & PostgreSQL), and works across macOS, Linux, and Windows.

## Features

- **Multiple PHP Versions**: 7.4, 8.0, 8.1, 8.2, 8.3
- **Dual Database Support**: MySQL 8.0 and PostgreSQL 16 running simultaneously
- **Built-in Services**: Redis, Mailpit (email testing), SSL proxy
- **Cross-Platform**: Works on macOS, Linux, and Windows
- **Framework Agnostic**: Laravel, WordPress, Zend, generic PHP
- **WP-CLI & Composer**: Pre-installed in container
- **Xdebug Ready**: Pre-configured for debugging

## Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (macOS/Windows) or Docker Engine (Linux)
- Docker Compose v2.0+
- Ports 80, 443, 3306, 5432, 6379, 8025 available

## Quick Start

```bash
# 1. Clone or copy this project
git clone https://github.com/Guerrerohgp/phplocaldocker.git my-project
cd my-project

# 2. Create environment file
cp .env.example .env

# 3. Build and start containers
./sail build
./sail up

# 4. Open in browser
open http://localhost
```

**Windows (CMD):**
```cmd
copy .env.example .env
sail.bat build
sail.bat up
```

## Configuration

Edit the `.env` file to customize your setup:

### Project Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `PROJECT_NAME` | `myapp` | Project identifier |
| `PROJECT_DOMAIN` | `myapp.test` | Domain for SSL certificate |

### PHP Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_VERSION` | `8.2` | PHP version (7.4, 8.0, 8.1, 8.2, 8.3) |
| `NODE_VERSION` | `20` | Node.js version |

### Database Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `MYSQL_VERSION` | `8.0` | MySQL version |
| `DB_DATABASE` | `myapp` | MySQL database name |
| `DB_USERNAME` | `myapp` | MySQL username |
| `DB_PASSWORD` | `secret` | MySQL password |
| `POSTGRES_VERSION` | `16` | PostgreSQL version |
| `POSTGRES_DB` | `myapp` | PostgreSQL database name |
| `POSTGRES_USER` | `myapp` | PostgreSQL username |
| `POSTGRES_PASSWORD` | `secret` | PostgreSQL password |

### Port Mappings

| Service | Default Port | Env Variable |
|---------|-------------|--------------|
| HTTP | 80 | `APP_PORT` |
| HTTPS | 443 | (fixed) |
| MySQL | 3306 | `FORWARD_DB_PORT` |
| PostgreSQL | 5432 | `FORWARD_POSTGRES_PORT` |
| Redis | 6379 | `FORWARD_REDIS_PORT` |
| Mailpit SMTP | 1025 | `FORWARD_MAILPIT_PORT` |
| Mailpit Web | 8025 | `FORWARD_MAILPIT_DASHBOARD_PORT` |

## Commands

### Container Management

```bash
./sail up          # Start containers
./sail down        # Stop containers
./sail build       # Build containers
./sail ps          # List running containers
./sail logs        # View container logs
./sail stop        # Stop containers
./sail restart     # Restart containers
```

### Development

```bash
./sail shell       # Open bash shell in app container
./sail php -v      # Run PHP commands
./sail composer install    # Run Composer
./sail artisan migrate     # Run Laravel Artisan
./sail wp plugin list      # Run WP-CLI
```

### Database

```bash
./sail mysql       # Open MySQL CLI
./sail psql        # Open PostgreSQL CLI
./sail redis       # Open Redis CLI
```

### Utilities

```bash
./sail ssl         # Generate SSL certificates
./sail mailpit     # View Mailpit logs
./sail help        # Show all commands
```

## Services

### PHP Application (`app`)

- Nginx web server
- PHP-FPM
- Composer
- WP-CLI
- Node.js & npm

### MySQL (`mysql`)

Default connection:
```
Host: mysql
Port: 3306
Database: myapp
Username: myapp
Password: secret
```

Testing database: `testing` (auto-created)

### PostgreSQL (`postgres`)

Default connection:
```
Host: postgres
Port: 5432
Database: myapp
Username: myapp
Password: secret
```

Testing database: `testing` (auto-created)

### Redis (`redis`)

```
Host: redis
Port: 6379
```

### Mailpit (`mailpit`)

Email testing tool with web UI at http://localhost:8025

- SMTP: localhost:1025
- Web UI: http://localhost:8025

### SSL Proxy (`ssl-proxy`)

HTTPS termination at port 443, proxies to app container.

## SSL Certificates

Generate self-signed SSL certificates:

```bash
./sail ssl
```

Then trust the certificate on your system:

**macOS:**
```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain docker/ssl/certs/myapp.test.crt
```

**Linux (Debian/Ubuntu):**
```bash
sudo cp docker/ssl/certs/myapp.test.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

**Windows (PowerShell as Admin):**
```powershell
Import-Certificate -FilePath "docker\ssl\certs\myapp.test.crt" -CertStoreLocation Cert:\LocalMachine\Root
```

## Framework Setup

### Laravel

1. Create new project:
```bash
./sail composer create-project laravel/laravel .
```

2. Configure `.env`:
```env
DB_CONNECTION=mysql
DB_HOST=mysql
DB_DATABASE=myapp
DB_USERNAME=myapp
DB_PASSWORD=secret

CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
REDIS_HOST=redis

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
```

### WordPress

1. Download WordPress:
```bash
./sail wp core download
```

2. Configure `wp-config.php`:
```php
define('DB_NAME', 'myapp');
define('DB_USER', 'myapp');
define('DB_PASSWORD', 'secret');
define('DB_HOST', 'mysql');
```

### Zend / Laminas

```bash
./sail composer create-project laminas/laminas-mvc-skeleton .
```

## Platform-Specific Notes

### macOS

- Requires Docker Desktop
- File system performance is optimized by default
- Use `./sail` for all commands

### Linux

- Requires Docker 20.10+ (for `host.docker.internal` support)
- May need `sudo` or add user to docker group:
```bash
sudo usermod -aG docker $USER
```

### Windows

- Requires Docker Desktop with WSL2 backend
- Use `sail.bat` in CMD
- Or use `./sail` in PowerShell/WSL

## Troubleshooting

### Port Already in Use

If port 80 is already in use:

```bash
# Check what's using port 80
lsof -i :80

# Change port in .env
APP_PORT=8080
```

### MySQL Access Denied

Reset MySQL data:

```bash
./sail down
docker volume rm phplocaldocker_sail-mysql
./sail up
```

### PHP-FPM Not Starting

Check container logs:

```bash
docker exec phplocaldocker-app-1 php-fpm${PHP_VERSION} -t
```

### Clear All Docker Data

```bash
./sail down -v  # Remove containers and volumes
docker system prune -a  # Clean all unused Docker resources
```

## File Structure

```
.
├── .env                    # Environment configuration
├── .env.example            # Configuration template
├── .gitattributes          # Cross-platform line endings
├── docker-compose.yml      # Docker services definition
├── sail                    # CLI tool (macOS/Linux)
├── sail.bat                # CLI tool (Windows)
├── public/                 # Web root
│   └── index.php
└── docker/
    ├── mysql/
    │   └── create-testing-database.sh
    ├── php/
    │   ├── Dockerfile
    │   ├── php.ini
    │   ├── xdebug.ini
    │   ├── supervisord.conf
    │   ├── nginx-default
    │   ├── fpm-env.conf
    │   └── start-container
    ├── postgres/
    │   └── create-testing-database.sh
    └── ssl/
        ├── nginx.conf
        ├── generate-certs.sh
        ├── generate-certs.bat
        └── certs/
```

## License

MIT License
