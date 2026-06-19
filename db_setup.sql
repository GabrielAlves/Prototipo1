DROP USER IF EXISTS 'admin'@'localhost';

CREATE USER 'admin'@'localhost'
IDENTIFIED WITH mysql_native_password BY 'admin';

GRANT ALL PRIVILEGES ON db.* TO 'admin'@'localhost';

FLUSH PRIVILEGES;