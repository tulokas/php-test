<?php
$mysqli = mysqli_init();

$mysqli->ssl_set(
    '/certs/client-key.pem',
    '/certs/client-cert.pem',
    '/certs/ca.pem',
    NULL,
    NULL
);

if (!$mysqli->real_connect('mysql', 'root', 'rootpass', 'testdb', 3306, NULL, MYSQLI_CLIENT_SSL)) {
    die('Connect Error (' . mysqli_connect_errno() . ') ' . mysqli_connect_error());
}

echo "✅ Connected successfully with SSL!\n";

// Query the users table
$result = $mysqli->query("SELECT id, name, email FROM users");

echo "👤 Users in database:\n";
while ($row = $result->fetch_assoc()) {
    echo "- {$row['id']}: {$row['name']} ({$row['email']})\n";
}

$result->free();
$mysqli->close();
