# PHP + MySQL SSL Docker POC

This project demonstrates a PHP script that securely connects to MySQL over SSL, queries data, prints it, and exits. It's ideal for secure local development, testing SSL setups, and migrating to Amazon RDS with `require_secure_transport=ON`.

✅ Built for:
- PHP using `mysqli` over a **secure SSL connection**
- MySQL (in Docker) with `require_secure_transport=ON`
- Self-signed certificates for local testing
- Easy migration to **AWS RDS** using `global-bundle.pem`

---

## ✅ Quick Start: Local SSL Setup

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

2. Build and Run the Containers Locally

```bash
docker-compose down -v
docker-compose up --build
```

Expected output:

```bash
✅ Successfully connected via SSL
👤 Users in database:
- 1: Alice (alice@example.com)
- 2: Bob (bob@example.com)
```
## Connect to AWS RDS with SSL

To migrate this setup to Amazon RDS:

1. Download Amazon RDS CA Bundle

```bash
wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem -O client-cert/global-bundle.pem
```

2. Update PHP Code

Replace index.php with:

```php
<?php
class MySQLii extends mysqli
{
    public function __construct(
        $host,
        $user,
        $password,
        $database,
        $port = 3306,
        $caCert = '/certs/global-bundle.pem'  // Amazon RDS CA
    ) {
        parent::__construct();

        $this->ssl_set(NULL, NULL, $caCert, NULL, NULL);  // Only the CA for RDS

        if (!$this->real_connect(
            $host,
            $user,
            $password,
            $database,
            $port,
            NULL,
            MYSQLI_CLIENT_SSL
        )) {
            die('Connect Error (' . mysqli_connect_errno() . '): ' . mysqli_connect_error());
        }

        echo "✅ Connected to AWS RDS over SSL\n";
    }
}

// Usage with RDS:
$db = new MySQLii('your-db.xxxxxx.rds.amazonaws.com', 'your_user', 'your_pass', 'your_db_name');

$result = $db->query("SELECT id, name, email FROM users");

echo "👤 Users in database:\n";
while ($row = $result->fetch_assoc()) {
    echo "- {$row['id']}: {$row['name']} ({$row['email']})\n";
}

$result->free();
$db->close();
```

3. Modify Docker Compose for AWS RDS

You don’t need the local MySQL container anymore.

- Comment out or remove the mysql service:

```bash
# mysql:
#   build: ./mysql
#   container_name: mysql
#   environment:
#     MYSQL_ROOT_PASSWORD: rootpass
#     MYSQL_DATABASE: testdb
#   volumes:
#     - ./mysql/init:/docker-entrypoint-initdb.d
#   ports:
#     - "3306:3306"
```

- Also remove or comment depends_on: [mysql] in the PHP service.

- Modify the PHP service:

```yml
php:
  build: ./php
  container_name: php
  volumes:
    - ./client-cert:/certs
  entrypoint: ["php", "/var/www/html/index.php"]  # ✅ Skip wait script, connect to RDS
```
- 

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

Tips
-	When switching from local to RDS, make sure:
-	MySQL container is disabled.
-	PHP uses RDS hostname and the Amazon CA.
-	Consider using docker-compose.override.yml or --profile for smoother switching.
-	wait-for-mysql.sh is only useful for local Docker-based MySQL, not RDS.
