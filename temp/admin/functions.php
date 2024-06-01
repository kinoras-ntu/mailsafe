<?php

const err_messages = [
    "login" => [
        "1" => "Already signed in.",
        "2" => "Please fill in your username and password.",
        "3" => "Username or password incorrect."
    ]
];

function check($data): string
{
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data);
    return $data;
}

function exist($data): bool
{
    if (!isset($data) || empty($data))
        return false;
    if (check($data) == "")
        return false;
    return true;
}

function print_error(): string
{
    if (
        isset($_GET["err"]) &&
        isset($_GET["type"]) &&
        isset(err_messages[$_GET["err"]]) &&
        isset(err_messages[$_GET["err"]][strval($_GET["type"])])
    ) {
        return '<div class="alert alert-danger" role="alert">'
            . err_messages[$_GET["err"]][strval($_GET["type"])]
            . '</div>';
    }
    return "";
}
