# PHP + MySQL SSL Docker POC

This project demonstrates a PHP script that securely connects to MySQL over SSL, queries data, prints it, and exits. Ideal for secure testing, local development, or migration to AWS RDS.

- PHP using `mysqli` over a **secure SSL connection**
- MySQL (in Docker) with `require_secure_transport=ON`
- Self-signed certificates for local testing
- Easy migration to **AWS RDS** using `global-bundle.pem`

---

## Quick Start (Local SSL Setup)

### 1. Generate Self-Signed Certificates

Use the included script:

```bash
./generate-certs.sh
```

This creates:
- Server-side certs in mysql/certs/
- Client-side certs in client-cert/

Generated files:
```bash
mysql/certs/
├── ca.pem
├── server-cert.pem
├── server-key.pem

client-cert/
├── ca.pem
├── client-cert.pem
├── client-key.pem
```
2. Build and Run the Containers
```bash
docker-compose down -v
docker-compose up --build
```
Expected output:
```bash
Connected successfully with SSL!
👤 Users in database:
- 1: Alice (alice@example.com)
- 2: Bob (bob@example.com)
```
## AWS RDS SSL Support

To migrate this setup to Amazon RDS:

1. Download RDS CA Bundle
```bash
wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem -O client-cert/global-bundle.pem
```
2. Update PHP Code

Modify php/index.php:

```php
$mysqli = mysqli_init();

$mysqli->ssl_set(
    NULL, NULL,
    '/certs/global-bundle.pem',  // Use Amazon's CA
    NULL, NULL
);

$mysqli->real_connect(
    'your-db.xxxxxx.rds.amazonaws.com',
    'your_username',
    'your_password',
    'your_db_name',
    3306,
    NULL,
    MYSQLI_CLIENT_SSL
);
```

3. Update docker-compose.yml for RDS

Modify the PHP service:

```yml
php:
  build: ./php
  container_name: php
  volumes:
    - ./client-cert:/certs
  entrypoint: ["php", "/var/www/html/index.php"]  # ✅ Skip wait script, connect to RDS
```
You can now run SSL connections to AWS RDS.
```bash
php-test/
├── .gitignore
├── README.md
├── docker-compose.yml
├── generate-certs.sh
├── php/
│   ├── Dockerfile
│   ├── index.php
│   └── wait-for-mysql.sh
├── mysql/
│   ├── Dockerfile
│   ├── my.cnf
│   ├── init/
│   │   └── init.sql
│   └── certs/
│       ├── ca.pem
│       ├── server-cert.pem
│       └── server-key.pem
├── client-cert/
│   ├── ca.pem
│   ├── client-cert.pem
│   └── client-key.pem
```

- Cleanup
```
docker-compose down -v
```
- Credit

Built for secure local testing and migration to AWS RDS.
Tested with Docker, MySQL 8, and PHP 8.
