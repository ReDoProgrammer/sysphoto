<!-- Header -->
<div class="header">

    <!-- Logo -->
    <div class="header-left">
        <a href="<?php echo _WEB_ROOT?>/editor/home" class="logo">
            <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/logo.png" alt="Logo">
        </a>
    </div>
    <!-- /Logo -->

    <div class="header-center">
        <h1>TASK mngr</h1>
    </div>

    <a id="toggle_btn" href="javascript:void(0);">
        <span class="bar-icon">
            <span></span>
            <span></span>
            <span></span>
        </span>
    </a>

    <ul class="header-new-menu">
        <li>
            <a href="#" data-bs-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Projects</a>
            <div class="dropdown-menu">
                <a class="dropdown-item" href="<?php echo _WEB_ROOT?>/css/project">List</a>
                <a class="dropdown-item" href="<?php echo _WEB_ROOT?>/css/task">Tasks</a>
                <a class="dropdown-item" href="<?php echo _WEB_ROOT?>/css/task/owntask">Your tasks</a>
            </div>
        </li>       
    </ul>

    <a id="mobile_btn" class="mobile_btn" href="#sidebar"><i class="fa fa-bars"></i></a>

    <!-- Header Menu -->
    <ul class="nav user-menu">

        <li>
            <a href="#" class="report-btn">
                <span class="material-icons-outlined">
                    text_snippet
                </span>
            </a>
        </li>

        <li>
            <!-- Header Search -->
            <div class="page-title-box">
                <div class="top-nav-search">
                    <a href="javascript:void(0);" class="responsive-search">
                        <i class="fa fa-search"></i>
                    </a>
                    <form action="search.html">

                        <div class="input-group mb-3">
                            <input type="text" class="form-control" placeholder="Search">
                            <button class="btn btn-outline-secondary" type="button">
                                <span class="material-icons-outlined">
                                    search
                                </span>
                            </button>
                        </div>
                    </form>
                </div>
            </div>
            <!-- /Header Search -->
        </li>

        <!-- Notifications -->
        <li class="nav-item dropdown">
            <a href="#" class="dropdown-toggle nav-link" data-bs-toggle="dropdown">
                <i class="far fa-bell"></i> <span class="badge rounded-pill">3</span>
            </a>
            <div class="dropdown-menu notifications">
                <div class="topnav-dropdown-header">
                    <span class="notification-title">Notifications</span>
                    <a href="javascript:void(0)" class="clear-noti"> Clear All </a>
                </div>
                <div class="noti-content">
                    <ul class="notification-list">
                        <li class="notification-message">
                            <a href="activities.html">
                                <div class="media d-flex">
                                    <span class="avatar flex-shrink-0">
                                        <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-02.jpg"
                                            alt="User Image">
                                    </span>
                                    <div class="media-body flex-grow-1">
                                        <p class="noti-details"><span class="noti-title">John Doe</span> added
                                            new task <span class="noti-title">Patient appointment booking</span>
                                        </p>
                                        <p class="noti-time"><span class="notification-time">4 mins ago</span>
                                        </p>
                                    </div>
                                </div>
                            </a>
                        </li>
                        <li class="notification-message">
                            <a href="activities.html">
                                <div class="media d-flex">
                                    <span class="avatar flex-shrink-0">
                                        <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-03.jpg"
                                            alt="User Image">
                                    </span>
                                    <div class="media-body flex-grow-1">
                                        <p class="noti-details"><span class="noti-title">Tarah Shropshire</span>
                                            changed the task name <span class="noti-title">Appointment booking
                                                with payment gateway</span></p>
                                        <p class="noti-time"><span class="notification-time">6 mins ago</span>
                                        </p>
                                    </div>
                                </div>
                            </a>
                        </li>
                        <li class="notification-message">
                            <a href="activities.html">
                                <div class="media d-flex">
                                    <span class="avatar flex-shrink-0">
                                        <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-06.jpg"
                                            alt="User Image">
                                    </span>
                                    <div class="media-body flex-grow-1">
                                        <p class="noti-details"><span class="noti-title">Misty Tison</span>
                                            added <span class="noti-title">Domenic Houston</span> and <span
                                                class="noti-title">Claire Mapes</span> to project <span
                                                class="noti-title">Doctor available module</span></p>
                                        <p class="noti-time"><span class="notification-time">8 mins ago</span>
                                        </p>
                                    </div>
                                </div>
                            </a>
                        </li>
                        <li class="notification-message">
                            <a href="activities.html">
                                <div class="media d-flex">
                                    <span class="avatar flex-shrink-0">
                                        <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-17.jpg"
                                            alt="User Image">
                                    </span>
                                    <div class="media-body flex-grow-1">
                                        <p class="noti-details"><span class="noti-title">Rolland Webber</span>
                                            completed task <span class="noti-title">Patient and Doctor video
                                                conferencing</span></p>
                                        <p class="noti-time"><span class="notification-time">12 mins ago</span>
                                        </p>
                                    </div>
                                </div>
                            </a>
                        </li>
                        <li class="notification-message">
                            <a href="activities.html">
                                <div class="media d-flex">
                                    <span class="avatar flex-shrink-0">
                                        <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-13.jpg"
                                            alt="User Image">
                                    </span>
                                    <div class="media-body flex-grow-1">
                                        <p class="noti-details"><span class="noti-title">Bernardo Galaviz</span>
                                            added new task <span class="noti-title">Private chat module</span>
                                        </p>
                                        <p class="noti-time"><span class="notification-time">2 days ago</span>
                                        </p>
                                    </div>
                                </div>
                            </a>
                        </li>
                    </ul>
                </div>
                <div class="topnav-dropdown-footer">
                    <a href="activities.html">View all Notifications</a>
                </div>
            </div>
        </li>
        <!-- /Notifications -->

        <li class="nav-item dropdown has-arrow main-drop">
            <a href="#" class="dropdown-toggle nav-link" data-bs-toggle="dropdown">
                <span class="user-img"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-21.jpg"
                        alt="User Image"></span>
                <span>
                    <?php
                        if (isset($_SESSION['user'])) {
                            $user = unserialize($_SESSION['user']);                             
                            echo '<span class="fw-bold text-info">'.$user->role_name.'</span> '.$user->fullname;
                        }else{
                            echo 'Hello World';
                        }
                    ?>
                </span>
            </a>
            <div class="dropdown-menu">
                <a class="dropdown-item" href="employee/profile">My Profile</a>
                <a class="dropdown-item" href="settings.html">Settings</a>
                <a class="dropdown-item" href="index.html">Logout</a>
            </div>
        </li>
    </ul>
    <!-- /Header Menu -->

    <!-- Mobile Menu -->
    <div class="dropdown mobile-user-menu">
        <a href="#" class="nav-link dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false"><i
                class="fa fa-ellipsis-v"></i></a>
        <div class="dropdown-menu dropdown-menu-right">
            <a class="dropdown-item" href="profile.html">My Profile</a>
            <a class="dropdown-item" href="settings.html">Settings</a>
            <a class="dropdown-item" href="index.html">Logout</a>
        </div>
    </div>
    <!-- /Mobile Menu -->

</div>
<!-- /Header -->

