<?php
class MySQLii extends mysqli
{
    public function __construct(
        $host,
        $user,
        $password,
        $database,
        $port = 3306,
        $caCert = '/certs/ca.pem'
    ) {
        parent::__construct();

        // Optional: Extra options
        $this->options(MYSQLI_OPT_CONNECT_TIMEOUT, 5);

        // Set SSL
        $this->ssl_set(NULL, NULL, $caCert, NULL, NULL);

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

        echo "✅ Successfully connected via SSL\n";
    }
}

$db = new MySQLii('mysql', 'root', 'rootpass', 'testdb');
$result = $db->query("SELECT id, name, email FROM users");

echo "👤 Users in database:\n";
while ($row = $result->fetch_assoc()) {
    echo "- {$row['id']}: {$row['name']} ({$row['email']})\n";
}

$result->free();
$db->close();
