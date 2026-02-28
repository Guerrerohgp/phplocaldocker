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
        # Export each line in .env, ignoring comments and handling quotes
        while IFS='=' read -r key value || [[ -n "$key" ]]; do
            if [[ -n "$key" && ! "$key" =~ ^# ]]; then
                # Remove possible carriage returns and quotes
                value=$(echo "$value" | tr -d '\r' | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
                export "$key=$value"
            fi
        done < .env
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

if [ $# -gt 0 ]; then
    case "$1" in
        "up")
            $DOCKER_COMPOSE up -d
            ;;
        "down")
            $DOCKER_COMPOSE down
            ;;
        "build")
            export WWWGROUP="${WWWGROUP:-1000}"
            export PHP_POST_MAX_SIZE="${PHP_POST_MAX_SIZE:-100M}"
            export PHP_UPLOAD_MAX_FILESIZE="${PHP_UPLOAD_MAX_FILESIZE:-100M}"
            export PHP_MAX_EXECUTION_TIME="${PHP_MAX_EXECUTION_TIME:-300}"
            export PHP_SHORT_OPEN_TAG="${PHP_SHORT_OPEN_TAG:-On}"
            $DOCKER_COMPOSE build --build-arg WWWGROUP=$WWWGROUP --build-arg PHP_POST_MAX_SIZE=$PHP_POST_MAX_SIZE --build-arg PHP_UPLOAD_MAX_FILESIZE=$PHP_UPLOAD_MAX_FILESIZE --build-arg PHP_MAX_EXECUTION_TIME=$PHP_MAX_EXECUTION_TIME --build-arg PHP_SHORT_OPEN_TAG=$PHP_SHORT_OPEN_TAG
            ;;
        "ps")
            $DOCKER_COMPOSE ps
            ;;
        "shell"|"bash")
            $DOCKER_COMPOSE exec app bash
            ;;
        "logs")
            $DOCKER_COMPOSE logs -f
            ;;
        "wp")
            shift
            $DOCKER_COMPOSE exec app wp "$@"
            ;;
        "composer")
            shift
            $DOCKER_COMPOSE exec app composer "$@"
            ;;
        "artisan")
            shift
            $DOCKER_COMPOSE exec app php artisan "$@"
            ;;
        "php")
            shift
            $DOCKER_COMPOSE exec app php "$@"
            ;;
        "mysql")
            $DOCKER_COMPOSE exec mysql mysql -u"${DB_USERNAME}" -p"${DB_PASSWORD}" "${DB_DATABASE}"
            ;;
        "psql")
            $DOCKER_COMPOSE exec postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"
            ;;
        "redis")
            $DOCKER_COMPOSE exec redis redis-cli
            ;;
        "mailpit")
            $DOCKER_COMPOSE logs -f mailpit
            ;;
        "stop")
            $DOCKER_COMPOSE stop
            ;;
        "restart")
            $DOCKER_COMPOSE restart
            ;;
        "ssl")
            bash docker/ssl/generate-certs.sh
            ;;
        "backup")
            bash docker/scripts/backup.sh
            ;;
        "restore")
            shift
            bash docker/scripts/restore.sh "$@"
            ;;
        "help"|"--help"|"-h")
            display_help
            ;;
        *)
            echo "Unknown command: $1"
            display_help
            exit 1
            ;;
    esac
else
    display_help
fi
