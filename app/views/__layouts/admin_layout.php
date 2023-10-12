<!DOCTYPE html>
<html lang="en">

<?php

if (isset($_SESSION['user'])) {
    $user = unserialize($_SESSION['user']);
    if ($user->role != 1) {
        header('Location: '. _WEB_ROOT.'/admin/login');
        exit;
    }
} else {
    header('Location: '. _WEB_ROOT.'/admin/login');
    exit;
}
$this->render('__Layouts/blocks/head');
$this->render('__Layouts/blocks/footer');




?>

<body>
    <!-- Main Wrapper -->
    <div class="main-wrapper">

        <?php
        $this->render('__Layouts/blocks/header');
        $this->render('__Layouts/blocks/sidebar');
        ?>
        <!-- Page Wrapper -->
        <div class="page-wrapper">
            <!-- Page Content -->
            <div class="content container-fluid pb-0">

                <!-- Page Header -->
                <div class="row">
                    <div class="col-md-12">
                        <div class="page-head-box">
                            <h3>
                                <?php
                                echo (!empty($title) ? $title : 'Welcome Admin!');
                                ?>
                            </h3>
                            <nav aria-label="breadcrumb">
                                <ol class="breadcrumb">
                                    <li class="breadcrumb-item"><a href="admin-dashboard.html">Dashboard</a></li>
                                    <li class="breadcrumb-item active" aria-current="page">Job Dashboard</li>
                                </ol>
                            </nav>
                        </div>
                    </div>
                </div>
                <!-- /Page Header -->

                <?php $this->render($content, $sub_content); ?>

            </div>
            <!-- /Page Content -->

        </div>
        <!-- /Page Wrapper -->

    </div>
    <!-- /Main Wrapper -->
</body>

</html>