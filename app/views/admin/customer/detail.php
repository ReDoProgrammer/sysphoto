<?php if (!empty($customer)) { ?>
    <div class="card mb-0">
        <div class="card-body">
            <div class="row">
                <div class="col-md-12">
                    <div class="profile-view">
                        <div class="profile-img-wrap">
                            <div class="profile-img">
                                <a href="">
                                    <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-19.jpg"
                                        alt="User Image">
                                </a>
                            </div>
                        </div>
                        <div class="profile-basic">
                            <div class="row">
                                <div class="col-md-5">
                                    <div class="profile-info-left">
                                        <h3 class="user-name m-t-0">
                                            <?php echo $customer['name']; ?>
                                        </h3>
                                        <h5 class="company-role m-t-0 mb-0">
                                            <? echo $customer['company']; ?>
                                        </h5>
                                        <div class="staff-id">Acronym :
                                            <span class="text-warning fw-bold">
                                                <?php echo $customer['acronym']; ?>
                                            </span>
                                        </div>
                                        <h6 class="text-muted mt-2">Created at:
                                            <?php echo $customer['created_at']; ?>
                                        </h6>
                                        <h6 class="text-muted">Created by:
                                            <?php echo $customer['created_by']; ?>
                                        </h6>
                                    </div>
                                </div>
                                <div class="col-md-7">
                                    <ul class="personal-info">
                                        <li>
                                            <span class="title">Email:</span>
                                            <span class="text text-info">
                                                <?php echo $customer['email']; ?>
                                            </span>
                                        </li>
                                        <li>
                                            <span class="title">Location:</span>
                                            <span class="text">
                                                <a href="<?php echo $customer['customer_url']; ?>" class="btn btn-sm">
                                                    <i class="fa fa-copy"></i>
                                                    Copy Location Address
                                                </a>
                                            </span>
                                        </li>
                                        <li>
                                            <span class="title">Group:</span>
                                            <span class="text fw-bold">
                                                <?php echo $customer['customer_group']; ?>
                                            </span>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <div class="card tab-box mt-3">
        <div class="row user-tabs">
            <div class="col-lg-12 col-md-12 col-sm-12 line-tabs pt-3 pb-2">
                <ul class="nav nav-tabs nav-tabs-bottom">
                    <li class="nav-item col-sm-3"><a class="nav-link active" data-bs-toggle="tab" href="#Styles">Styles</a>
                    </li>
                    <li class="nav-item col-sm-3"><a class="nav-link" data-bs-toggle="tab" href="#Projects">Projects</a>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-12">
            <div class="tab-content profile-tab-content">

                <!-- Styles Tab -->
                <div id="Styles" class="tab-pane fade show active">
                    <div class="card">
                        <div class="card-body">
                            <div class="row">
                                <div class="col-sm-4">
                                    <div class="row">
                                        <div class="col-4">National style:</div>
                                        <div class="col-sm-8 text-info fw-bold">
                                            <?php echo $customer['national_style']; ?>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-4">
                                    <div class="row">
                                        <div class="col-4">Color mode:</div>
                                        <div class="col-sm-8 text-info fw-bold">
                                            <?php echo $customer['color_mode']; ?>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-4">
                                    <div class="row">
                                        <div class="col-4">Output:</div>
                                        <div class="col-sm-8 text-info fw-bold">
                                            <?php echo $customer['output']; ?>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row mt-2">
                                <div class="col-sm-4">
                                    <div class="row">
                                        <div class="col-4">Straighten:</div>
                                        <div class="col-sm-8 fw-bold">
                                            <?php
                                            echo $customer['is_straighten'] == 1 ?
                                                '<i class="fa-regular fa-square-check"></i>' :
                                                '<i class="fa-regular fa-square"></i>';
                                            ?>
                                            <span class="text-info">
                                                <?php echo $customer['straighten_remark']; ?>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-4">
                                    <div class="row">
                                        <div class="col-4">TV:</div>
                                        <div class="col-sm-8 text-info fw-bold">
                                            <?php echo $customer['tv']; ?>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-4">
                                    <div class="row">
                                        <div class="col-4">Fire:</div>
                                        <div class="col-sm-8 text-info fw-bold">
                                            <?php echo $customer['fire']; ?>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row mt-2">
                                <div class="col-sm-4">
                                    <div class="row">
                                        <div class="col-4">Sky:</div>
                                        <div class="col-sm-8 text-info fw-bold">
                                            <?php echo $customer['sky']; ?>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-4">
                                    <div class="row">
                                        <div class="col-4">Grass:</div>
                                        <div class="col-sm-8 text-info fw-bold">
                                            <?php echo $customer['grass']; ?>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-sm-4">
                                    <div class="row">
                                        <div class="col-4">Cloud:</div>
                                        <div class="col-sm-8 text-info fw-bold">
                                            <?php echo $customer['cloud']; ?>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row mt-4">
                                <div class="card">
                                    <div class="card-header fw-bold text-success">Style remark:</div>
                                    <div class="card-body m-2">
                                        <p>
                                            <?php                                           
                                                echo '<pre>' . $customer['style_remark'] . '</pre>';
                                            ?>
                                            
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- /Styles Tab -->

                <!-- Projects Tab -->
                <div id="Projects" class="tab-pane fade">
                    <div class="project-task">
                        <div class="tab-pane show active" id="all_tasks">
                            <div class="task-wrapper">
                                <div class="task-list-container">
                                    <div class="task-list-body">
                                        <ul id="task-list">
                                            <li class="task">
                                                <div class="task-container">
                                                    <span class="task-action-btn task-check">
                                                        <span class="action-circle large complete-btn"
                                                            title="Mark Complete">
                                                            <i class="material-icons">check</i>
                                                        </span>
                                                    </span>
                                                    <span class="task-label" contenteditable="true">Patient appointment
                                                        booking</span>
                                                    <span class="task-action-btn task-btn-right">
                                                        <span class="action-circle large" title="Assign">
                                                            <i class="material-icons">person_add</i>
                                                        </span>
                                                        <span class="action-circle large delete-btn" title="Delete Task">
                                                            <i class="material-icons">delete</i>
                                                        </span>
                                                    </span>
                                                </div>
                                            </li>
                                            <li class="task">
                                                <div class="task-container">
                                                    <span class="task-action-btn task-check">
                                                        <span class="action-circle large complete-btn"
                                                            title="Mark Complete">
                                                            <i class="material-icons">check</i>
                                                        </span>
                                                    </span>
                                                    <span class="task-label" contenteditable="true">Appointment booking with
                                                        payment gateway</span>
                                                    <span class="task-action-btn task-btn-right">
                                                        <span class="action-circle large" title="Assign">
                                                            <i class="material-icons">person_add</i>
                                                        </span>
                                                        <span class="action-circle large delete-btn" title="Delete Task">
                                                            <i class="material-icons">delete</i>
                                                        </span>
                                                    </span>
                                                </div>
                                            </li>
                                            <li class="completed task">
                                                <div class="task-container">
                                                    <span class="task-action-btn task-check">
                                                        <span class="action-circle large complete-btn"
                                                            title="Mark Complete">
                                                            <i class="material-icons">check</i>
                                                        </span>
                                                    </span>
                                                    <span class="task-label">Doctor available module</span>
                                                    <span class="task-action-btn task-btn-right">
                                                        <span class="action-circle large" title="Assign">
                                                            <i class="material-icons">person_add</i>
                                                        </span>
                                                        <span class="action-circle large delete-btn" title="Delete Task">
                                                            <i class="material-icons">delete</i>
                                                        </span>
                                                    </span>
                                                </div>
                                            </li>
                                            <li class="task">
                                                <div class="task-container">
                                                    <span class="task-action-btn task-check">
                                                        <span class="action-circle large complete-btn"
                                                            title="Mark Complete">
                                                            <i class="material-icons">check</i>
                                                        </span>
                                                    </span>
                                                    <span class="task-label" contenteditable="true">Patient and Doctor video
                                                        conferencing</span>
                                                    <span class="task-action-btn task-btn-right">
                                                        <span class="action-circle large" title="Assign">
                                                            <i class="material-icons">person_add</i>
                                                        </span>
                                                        <span class="action-circle large delete-btn" title="Delete Task">
                                                            <i class="material-icons">delete</i>
                                                        </span>
                                                    </span>
                                                </div>
                                            </li>
                                            <li class="task">
                                                <div class="task-container">
                                                    <span class="task-action-btn task-check">
                                                        <span class="action-circle large complete-btn"
                                                            title="Mark Complete">
                                                            <i class="material-icons">check</i>
                                                        </span>
                                                    </span>
                                                    <span class="task-label" contenteditable="true">Private chat
                                                        module</span>
                                                    <span class="task-action-btn task-btn-right">
                                                        <span class="action-circle large" title="Assign">
                                                            <i class="material-icons">person_add</i>
                                                        </span>
                                                        <span class="action-circle large delete-btn" title="Delete Task">
                                                            <i class="material-icons">delete</i>
                                                        </span>
                                                    </span>
                                                </div>
                                            </li>
                                            <li class="task">
                                                <div class="task-container">
                                                    <span class="task-action-btn task-check">
                                                        <span class="action-circle large complete-btn"
                                                            title="Mark Complete">
                                                            <i class="material-icons">check</i>
                                                        </span>
                                                    </span>
                                                    <span class="task-label" contenteditable="true">Patient Profile
                                                        add</span>
                                                    <span class="task-action-btn task-btn-right">
                                                        <span class="action-circle large" title="Assign">
                                                            <i class="material-icons">person_add</i>
                                                        </span>
                                                        <span class="action-circle large delete-btn" title="Delete Task">
                                                            <i class="material-icons">delete</i>
                                                        </span>
                                                    </span>
                                                </div>
                                            </li>
                                        </ul>
                                    </div>
                                    <div class="task-list-footer">
                                        <div class="new-task-wrapper">
                                            <textarea id="new-task" placeholder="Enter new task here. . ."></textarea>
                                            <span class="error-message hidden">You need to enter a task first</span>
                                            <span class="add-new-task-btn btn" id="add-task">Add Task</span>
                                            <span class="btn" id="close-task-panel">Close</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- /Projects Tab -->

            </div>
        </div>
    </div>


<?php } ?>