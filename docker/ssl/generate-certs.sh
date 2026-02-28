#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTS_DIR="$SCRIPT_DIR/certs"

if [ -f "$SCRIPT_DIR/../../.env" ]; then
    # Export each line in .env, ignoring comments and handling quotes and carriage returns
    while IFS='=' read -r key value || [[ -n "$key" ]]; do
        if [[ -n "$key" && ! "$key" =~ ^# ]]; then
            # Remove possible carriage returns and quotes
            value=$(echo "$value" | tr -d '\r' | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
            export "$key=$value"
        fi
    done < "$SCRIPT_DIR/../../.env"
fi

PROJECT_DOMAIN="${PROJECT_DOMAIN:-myapp.test}"

mkdir -p "$CERTS_DIR"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$CERTS_DIR/${PROJECT_DOMAIN}.key" \
    -out "$CERTS_DIR/${PROJECT_DOMAIN}.crt" \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=${PROJECT_DOMAIN}"

cp "$CERTS_DIR/${PROJECT_DOMAIN}.crt" "$CERTS_DIR/server.crt"
cp "$CERTS_DIR/${PROJECT_DOMAIN}.key" "$CERTS_DIR/server.key"

echo ""
echo "SSL certificates generated in $CERTS_DIR"
echo "  - ${PROJECT_DOMAIN}.crt"
echo "  - ${PROJECT_DOMAIN}.key"
echo ""

detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        CYGWIN*|MINGW*|MSYS*)    echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

OS=$(detect_os)

case "$OS" in
    macos)
        echo "To trust the certificate on macOS, run:"
        echo "sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $CERTS_DIR/${PROJECT_DOMAIN}.crt"
        ;;
    linux)
        if command -v update-ca-certificates &> /dev/null; then
            echo "To trust the certificate on Linux (Debian/Ubuntu), run:"
            echo "sudo cp $CERTS_DIR/${PROJECT_DOMAIN}.crt /usr/local/share/ca-certificates/${PROJECT_DOMAIN}.crt"
            echo "sudo update-ca-certificates"
        elif command -v trust &> /dev/null; then
            echo "To trust the certificate on Linux (Fedora/RHEL), run:"
            echo "sudo trust anchor $CERTS_DIR/${PROJECT_DOMAIN}.crt"
        else
            echo "To trust the certificate, add $CERTS_DIR/${PROJECT_DOMAIN}.crt to your system's trust store."
        fi
        ;;
    windows)
        echo "To trust the certificate on Windows, run PowerShell as Administrator:"
        echo "Import-Certificate -FilePath '$CERTS_DIR\\${PROJECT_DOMAIN}.crt' -CertStoreLocation Cert:\\LocalMachine\\Root"
        ;;
    *)
        echo "Add $CERTS_DIR/${PROJECT_DOMAIN}.crt to your system's trust store."
        ;;
esac
