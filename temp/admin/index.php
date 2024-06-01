<?php

require_once "rc-interface.php";
require_once "conn.php";
require_once "functions.php";

if (!isset($_SESSION))
    session_start();

?>

<!DOCTYPE HTML>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Panel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
</head>

<body>
    <header class="navbar navbar-expand-lg bg-dark border-bottom border-body sticky-top" data-bs-theme="dark">
        <div class="container">
            <a class="navbar-brand" href="/admin">Admin Panel</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav-menu" aria-controls="nav-menu" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="nav-menu">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                    <?php if (isset($_SESSION["admin"])) : ?>
                        <li class="nav-item"><a class="nav-link" href="#users">Users</a></li>
                        <li class="nav-item"><a class="nav-link" href="#spam">Spam</a></li>
                    <?php endif; ?>
                </ul>
                <div class="d-flex">
                    <?php if (!isset($_SESSION["admin"])) : ?>
                        <a class="btn btn-outline-light" href="/admin">Sign in</a>
                    <?php else : ?>
                        <a class="btn btn-outline-light" href="actions/signout.php">Sign out</a>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </header>

    <div id="content" class="container mt-3">
        <?php if (!isset($_SESSION["admin"])) : ?>
            <h1 class="pt-2 pb-3">Sign in</h1>
            <?php echo print_error(); ?>
            <form class="py-1" method="post" action="actions/signin.php">
                <div class="mb-3">
                    <label for="username" class="form-label">Username</label>
                    <input type="text" class="form-control" id="username" name="username">
                </div>
                <div class="mb-3">
                    <label for="password" class="form-label">Password</label>
                    <input type="password" class="form-control" id="password" name="password">
                </div>
                <button type="submit" class="btn btn-primary">Proceed</button>
            </form>
        <?php else : ?>
            <h1 class="pt-2 pb-3">Dashboard</h1>
            <section id="users" class="mb-5" style="scroll-margin-top: 64px;">
                <header class="d-flex mb-3 justify-content-between align-items-center">
                    <h2 class="m-0">Users</h2>
                </header>
                <table class="table align-middle">
                    <thead class="table-light">
                        <th scope="col">#</th>
                        <th scope="col">Username</th>
                        <th scope="col">Activated</th>
                        <th scope="col">Identities</th>
                    </thead>
                    <tbody>
                        <?php
                        $users = explode(",", shell_exec("getent group mail | awk -F: '{print $4}'"));
                        $users = array_filter($users, fn ($value) => !is_null($value) && !empty(trim($value)));
                        $users = array_map('rci_usermap', $users);
                        foreach ($users as $key => $user) :
                        ?>
                            <tr>
                                <th scope="row"><?= $key + 1 ?></th>
                                <td><?= htmlspecialchars($user["username"]) ?></td>
                                <td><?= $user["activated"] ? 'Yes' : 'No' ?></td>
                                <td>
                                    <?php foreach ($user["identities"] as $identity) : ?>
                                        <span class="d-block">
                                            <?= htmlspecialchars($identity["name"]) ?>
                                            <?= htmlspecialchars("<" . $identity["mail"] . ">") ?>
                                            <?= $identity["default"] ? "&nbsp;<span class=\"badge text-bg-secondary\" style=\"transform: translateY(-1px)\">Default</span>" : "" ?>
                                        </span>
                                    <?php endforeach ?>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <p>
                    <span>To create a new user, use the <code>useradd -m -G mail USERNAME</code> command.</span><br>
                    <span>To change the password for a user, use the <code>passwd USERNAME</code> command.</span>
                </p>
            </section>
            <section id="spam" class="mb-5" style="scroll-margin-top: 64px;">
                <header class="d-flex mb-3 justify-content-between align-items-center">
                    <h2 class="m-0">Spam Backups</h2>
                </header>
                <table class="table align-middle">
                    <thead class="table-light">
                        <th scope="col">#</th>
                        <th scope="col">User</th>
                        <th scope="col">Sender</th>
                        <th scope="col">Subject</th>
                        <th scope="col">Datetime</th>
                        <th scope="col">Status</th>
                        <th scope="col">Action</th>
                    </thead>
                    <tbody>
                        <?php
                        $backup_sql = "SELECT * FROM `backups`";
                        $backup_result = mysqli_query($conn, $backup_sql);
                        if (mysqli_num_rows($backup_result) !== 0) :
                            while ($backup = mysqli_fetch_assoc($backup_result)) :
                        ?>
                                <tr>
                                    <th scope="row"><?= $backup["id"] ?></th>
                                    <td><?= htmlspecialchars($backup["receiver"]) ?></td>
                                    <td><?= htmlspecialchars($backup["sender"]) ?></td>
                                    <td><?= htmlspecialchars($backup["subject"]) ?></td>
                                    <td><?= htmlspecialchars($backup["datetime"]) ?></td>
                                    <td><?= htmlspecialchars($backup["report"]) ?></td>
                                    <td><a class="btn btn-small btn-primary" href="actions/getfile.php?token=<?= htmlspecialchars($backup["filename"]) ?>" target="_blank">View</a></td>
                                </tr>
                        <?php
                            endwhile;
                        endif;
                        ?>
                    </tbody>
                </table>
            </section>
        <?php endif; ?>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>

</html>