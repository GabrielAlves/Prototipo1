CREATE DATABASE IF NOT EXISTS db;

CREATE USER 'admin'@'localhost'
IDENTIFIED WITH mysql_native_password BY 'admin';

GRANT ALL PRIVILEGES ON db.* TO 'admin'@'localhost';

FLUSH PRIVILEGES;