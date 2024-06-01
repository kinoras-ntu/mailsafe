<?php

require_once "../conn.php";
require_once "../functions.php";

if (!isset($_SESSION))
    session_start();

if (isset($_SESSION["admin"])) {
    header("Location: ../index.php?err=login&type=1");
    exit;
}

# Empty username and/or password
if (!exist($_POST["username"]) || !exist($_POST["password"])) {
    header("Location: ../index.php?err=login&type=2");
    exit;
}

$username = check($_POST["username"]);
$password = hash('sha256', check($_POST["password"]));

$sql = "SELECT * FROM `administrators` WHERE `username` = '$username'";
$result = mysqli_query($conn, $sql);

# No such admin
if (mysqli_num_rows($result) !== 1) {
    header("Location: ../index.php?err=login&type=3");
    exit;
}

$row = mysqli_fetch_assoc($result);

# Incorrect password
if ($row["password"] !== $password) {
    header("Location: ../index.php?err=login&type=3");
    exit;
}

$_SESSION["admin"] = $username;
header("Location: ../index.php");
exit;
