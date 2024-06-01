<?php

$rci_conn = mysqli_connect("localhost", "roundcube", "password", "roundcube");

if (!$rci_conn) {
    die("Connection failed: " . mysqli_connect_error());
}

function rci_usermap($username)
{
    global $rci_conn;
    $username = trim($username);
    $user_result = mysqli_query($rci_conn, "SELECT * FROM `users` WHERE `username` = '$username'");
    if (mysqli_num_rows($user_result) !== 1) {
        return [
            "username" => $username,
            "activated" => false,
            "identities" => []
        ];
    }
    $user_id = mysqli_fetch_assoc($user_result)["user_id"];
    $identity_result = mysqli_query($rci_conn, "SELECT * FROM `identities` WHERE `user_id` = '$user_id'");
    if (mysqli_num_rows($identity_result) === 0) {
        return [
            "username" => $username,
            "activated" => true,
            "identities" => []
        ];
    }
    $identites = [];
    while ($identity_row = mysqli_fetch_assoc($identity_result)) {
        array_push($identites, [
            "name" => $identity_row["name"],
            "mail" => $identity_row["email"],
            "default" => ($identity_row["standard"] == 1)
        ]);
    }
    return [
        "username" => $username,
        "activated" => true,
        "identities" => $identites
    ];
}
