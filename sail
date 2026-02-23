#!/usr/bin/env bash

set -e

DOCKER_COMPOSE="docker-compose"

if ! command -v docker-compose &> /dev/null; then
    if command -v docker &> /dev/null && docker compose version &> /dev/null; then
        DOCKER_COMPOSE="docker compose"
    else
        echo "docker-compose is not installed."
        exit 1
    fi
fi

detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        CYGWIN*|MINGW*|MSYS*)    echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

load_env() {
    if [ -f .env ]; then
        while IFS='=' read -r key value; do
            if [[ -n "$key" && ! "$key" =~ ^# ]]; then
                value="${value%\"}"
                value="${value#\"}"
                value="${value%\'}"
                value="${value#\'}"
                export "$key=$value"
            fi
        done < <(grep -v '^#' .env)
    fi
}

display_help() {
    echo "Sail - Docker management for PHP projects"
    echo ""
    echo "Usage: ./sail [command]"
    echo ""
    echo "Commands:"
    echo "  up          Start the containers"
    echo "  down        Stop the containers"
    echo "  build       Build the containers"
    echo "  ps          List running containers"
    echo "  shell       Open a bash shell in the app container"
    echo "  logs        Show container logs"
    echo "  wp          Run WP-CLI commands"
    echo "  composer    Run Composer commands"
    echo "  artisan     Run artisan commands (Laravel)"
    echo "  php         Run PHP commands"
    echo "  mysql       Open MySQL CLI"
    echo "  psql        Open PostgreSQL CLI"
    echo "  redis       Open Redis CLI"
    echo "  mailpit     Show Mailpit logs"
    echo "  stop        Stop the containers"
    echo "  restart     Restart the containers"
    echo "  ssl         Generate SSL certificates"
    echo "  backup      Backup all databases"
    echo "  restore     Restore databases (./sail restore --help)"
    echo "  help        Show this help message"
}

load_env

PROJECT_NAME="${PROJECT_NAME:-myapp}"
PROJECT_DOMAIN="${PROJECT_DOMAIN:-myapp.test}"

case "$1" in
    up)
        $DOCKER_COMPOSE up -d
        ;;
    down)
        $DOCKER_COMPOSE down
        ;;
    build)
        $DOCKER_COMPOSE build \
            --build-arg WWWGROUP="${WWWGROUP:-1000}" \
            --build-arg PHP_POST_MAX_SIZE="${PHP_POST_MAX_SIZE:-100M}" \
            --build-arg PHP_UPLOAD_MAX_FILESIZE="${PHP_UPLOAD_MAX_FILESIZE:-100M}" \
            --build-arg PHP_MAX_EXECUTION_TIME="${PHP_MAX_EXECUTION_TIME:-300}" \
            --build-arg PHP_SHORT_OPEN_TAG="${PHP_SHORT_OPEN_TAG:-On}"
        ;;
    ps)
        $DOCKER_COMPOSE ps
        ;;
    shell|bash)
        $DOCKER_COMPOSE exec app bash 2>/dev/null || $DOCKER_COMPOSE exec app sh
        ;;
    logs)
        $DOCKER_COMPOSE logs -f
        ;;
    wp)
        shift
        $DOCKER_COMPOSE exec app wp "$@"
        ;;
    composer)
        shift
        $DOCKER_COMPOSE exec app composer "$@"
        ;;
    artisan)
        shift
        $DOCKER_COMPOSE exec app php artisan "$@"
        ;;
    php)
        shift
        $DOCKER_COMPOSE exec app php "$@"
        ;;
    mysql)
        $DOCKER_COMPOSE exec mysql mysql -u"${DB_USERNAME:-myapp}" -p"${DB_PASSWORD:-secret}" "${DB_DATABASE:-myapp}"
        ;;
    psql)
        $DOCKER_COMPOSE exec postgres psql -U "${POSTGRES_USER:-myapp}" -d "${POSTGRES_DB:-myapp}"
        ;;
    redis)
        $DOCKER_COMPOSE exec redis redis-cli
        ;;
    mailpit)
        $DOCKER_COMPOSE logs -f mailpit
        ;;
    stop)
        $DOCKER_COMPOSE stop
        ;;
    restart)
        $DOCKER_COMPOSE restart
        ;;
    ssl)
        ./docker/ssl/generate-certs.sh
        ;;
    backup)
        ./docker/scripts/backup.sh
        ;;
    restore)
        shift
        if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
            echo "Restore databases from backup"
            echo ""
            echo "Usage:"
            echo "  ./sail restore                      List available backups"
            echo "  ./sail restore <mysql> <postgres>   Restore both databases"
            echo "  ./sail restore --mysql <file>       Restore MySQL only"
            echo "  ./sail restore --postgres <file>    Restore PostgreSQL only"
            echo "  ./sail restore --list               List all backups"
        else
            ./docker/scripts/restore.sh "$@"
        fi
        ;;
    help|--help|-h|"")
        display_help
        ;;
    *)
        echo "Unknown command: $1"
        echo "Run './sail help' for available commands."
        exit 1
        ;;
esac
