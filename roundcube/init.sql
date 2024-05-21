CREATE DATABASE roundcube DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER roundcube@localhost IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO roundcube@localhost;
flush privileges;
quit;
