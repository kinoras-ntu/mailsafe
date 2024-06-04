<?php

date_default_timezone_set('Asia/Macau');

$server_servername = "localhost";
$server_username = "#_MYSQL:USERNAME_#";
$server_password = "#_MYSQL:PASSWORD_#";
$server_dbname = "junox";

$conn = mysqli_connect($server_servername, $server_username, $server_password, $server_dbname);

if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}
