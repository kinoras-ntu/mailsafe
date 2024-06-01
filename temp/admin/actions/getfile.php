<?php

if (!isset($_SESSION))
    session_start();

if (!isset($_SESSION["admin"])) {
    header("HTTP/1.0 403 Forbidden");
    echo "Error: Access Denied";
    exit;
}

if (!isset($_GET['token'])) {
    header("HTTP/1.0 400 Bad Request");
    echo "Error: 'token' parameter is required.";
    exit;
}

$token = $_GET['token'];

if (!is_string($token) || (preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/', $token) !== 1)) {
    header("HTTP/1.0 400 Bad Request");
    echo "Error: Invalid token.";
    exit;
}

$path = "/etc/postfix/lab/backup/$token";

if (!file_exists($path) || !is_readable($path)) {
    header("HTTP/1.0 404 Not Found");
    echo "Error: File not found or not readable";
    exit;
}

header('Content-Type: text/plain');
readfile($path);
