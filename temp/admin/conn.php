<?php

date_default_timezone_set('Asia/Macau');

$server_servername = "localhost";
$server_username = "roundcube";
$server_password = "password";
$server_dbname = "junox";

$conn = mysqli_connect($server_servername, $server_username, $server_password, $server_dbname);

if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}
