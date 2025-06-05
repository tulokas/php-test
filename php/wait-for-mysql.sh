#!/bin/bash
set -e

host="mysql"
user="root"
password="rootpass"
database="testdb"
port="3306"

timeout=30
count=0

echo "$(date -u +"%Y-%m-%d %H:%M:%S") ⏳ Waiting for MySQL to become ready (with SSL)..."

while true; do
  php -r "
    error_reporting(E_ALL);
    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
    try {
      \$mysqli = mysqli_init();
      \$mysqli->ssl_set('/certs/client-key.pem', '/certs/client-cert.pem', '/certs/ca.pem', NULL, NULL);
      \$mysqli->real_connect('$host', '$user', '$password', '$database', $port, NULL, MYSQLI_CLIENT_SSL);
      exit(0);
    } catch (Exception \$e) {
      exit(1);
    }
  " && break

  count=$((count+1))
  if [ "$count" -ge "$timeout" ]; then
    echo "$(date -u +"%Y-%m-%d %H:%M:%S") ❌ Timed out waiting for MySQL to become ready"
    exit 1
  fi

  sleep 1
done

echo "$(date -u +"%Y-%m-%d %H:%M:%S") ✅ MySQL is ready with SSL!"
exec php /var/www/html/index.php