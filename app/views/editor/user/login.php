<!DOCTYPE html>
<html lang="en">
<?php $this->render('__Layouts/blocks/head'); ?>
<link rel="stylesheet" href="<?php echo _WEB_ROOT; ?>/public/assets/plugins/toast/jquery.toast.min.css">
<link rel="stylesheet" href="<?php echo _WEB_ROOT; ?>/public/assets/plugins/sweetalert2/sweetalert2.min.css">

<body class="account-page">

    <!-- Main Wrapper -->
    <div class="main-wrapper">
        <div class="account-content">

            <div class="container">

                <div class="account-box">
                    <div class="account-wrapper">
                        <h3 class="account-title">Login</h3>
                        <p class="account-subtitle">Access as an Editor</p>

                        <!-- Account Form -->
                        <div>
                            <div class="input-block mb-3">
                                <label class="col-form-label">Email Address</label>
                                <input class="form-control" type="text" placeholder="Enter your email address"
                                    id="txtEmail">
                            </div>
                            <div class="input-block mb-3">
                                <div class="row align-items-center">
                                    <div class="col">
                                        <label class="col-form-label">Password</label>
                                    </div>
                                    <div class="col-auto">
                                        <a class="text-muted" href="forgot-password.html">
                                            Forgot password?
                                        </a>
                                    </div>
                                </div>
                                <div class="position-relative">
                                    <input class="form-control" type="password" placeholder="Your password"
                                        id="txtPassword">
                                    <span class="fa fa-eye-slash" id="toggle-password"></span>
                                </div>
                            </div>
                            <div class="input-block mb-3 text-center">
                                <button class="btn btn-primary account-btn" type="submit" id="btnLogin">
                                    Login as Editor</button>
                            </div>
                        </div>
                        <!-- /Account Form -->

                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- /Main Wrapper -->

    <!-- jQuery -->
    <script src="<?php echo _WEB_ROOT; ?>/public/assets/js/jquery-3.7.0.min.js"></script>

    <!-- Bootstrap Core JS -->
    <script src="<?php echo _WEB_ROOT; ?>/public/assets/js/bootstrap.bundle.min.js"></script>

    <script src="<?php echo _WEB_ROOT; ?>/public/assets/js/app.js"></script>

    <!-- Custom JS -->
    <script src="<?php echo _WEB_ROOT; ?>/public/assets/plugins/toast/jquery.toast.min.js"></script>
    <script src="<?php echo _WEB_ROOT; ?>/public/assets/plugins/sweetalert2/sweetalert2.min.js"></script>
    <script src="<?php echo _WEB_ROOT; ?>/public/assets/js/custom/editor/auth/auth.js"></script>

</body>

</html>