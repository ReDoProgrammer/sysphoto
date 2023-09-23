<!DOCTYPE html>
<html lang="en">

<?php
$this->render('__Layouts/blocks/head');
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
                            <h3>Welcome Admin!</h3>
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

    <!-- jQuery -->
    <script src="<?php echo _WEB_ROOT; ?>/public/assets/js/jquery-3.7.0.min.js"></script>

    <!-- Bootstrap Core JS -->
    <script src="<?php echo _WEB_ROOT; ?>/public/assets/js/bootstrap.bundle.min.js"></script>

    <!-- Slimscroll JS -->
    <script src="<?php echo _WEB_ROOT; ?>/public/assets/js/jquery.slimscroll.min.js"></script>

    <!-- Chart JS -->
    <script src="<?php echo _WEB_ROOT; ?>/public/assets/plugins/morris/morris.min.js"></script>
    <script src="<?php echo _WEB_ROOT; ?>/public/assets/plugins/raphael/raphael.min.js"></script>
    <script src="<?php echo _WEB_ROOT; ?>/public/assets/js/chart.js"></script>

    <!-- Apex Charts -->
    <script src="<?php echo _WEB_ROOT; ?>/public/assets/plugins/apexcharts/apexcharts.min.js"></script>

    <!-- Custom JS -->
    <script src="<?php echo _WEB_ROOT; ?>/public/assets/js/app.js"></script>

</body>

</html>