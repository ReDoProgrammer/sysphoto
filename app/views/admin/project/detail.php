<div class="row">
    <div class="col-lg-8 col-xl-9">
        <div class="card">
            <div class="card-body">
                <div class="project-title">
                    <h5 class="card-title text-info fw-bold"  id="project_name"></h5>
                    <h6 id="ProjectTasksAndStatus">
                        1 Done tasks, 2 Wait Tasks
                    </h6>
                </div>
                <hr/>
                <div id="DescriptionAndInstructions" class="mt-3"></div>
                
            </div>
        </div>


        <div class="card p-4">
            <div class="card-header">
                <div class="row">
                    <div class="col-sm-8">
                        <h4>Tasks list</h4>
                    </div>
                    <div class="col-sm-4 text-end">
                        <div class="add-emp-section">
                            <a href="#" class="btn btn-success btn-add-emp" data-bs-toggle="modal"
                                data-bs-target="#task_modal"><i class="fas fa-plus"></i> Add new task</a>
                        </div>
                    </div>
                </div>

            </div>
            <div class="card-body">
                <div class="table-responsive" style="min-height:100px; max-height:200px;">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Level</th>
                                <th>Q.ty</th>
                                <th>Editor</th>
                                <th>Q.A</th>
                                <th>DC</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody id="tblTasksList"></tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="card p-2">
            <div class="card-header">CC & Feedback</div>
            <div class="card-body">
                <div class="accordion" id="accordionFeedbacksAndCCs">                  
                    
                </div>
            </div>
        </div>

        <div class="card recent-activity flex-fill">
            <div class="card-body">
                <h5 class="card-title">Project logs</h5>
                <ul class="res-activity-list" id="ulProjectLogs"
                    style="max-height:200px; overflow-y: auto;border: 1px solid #ccc; ">


                </ul>
            </div>
        </div>



    </div>
    <div class="col-lg-4 col-xl-3">
        <div class="card">
            <div class="card-body prj-tbl pb-0">
                <h6 class="card-title m-b-15">Project summary</h6>
                <table class="table">
                    <tbody>
                        <tr>
                            <td>Begin:</td>
                            <td class="text-end" id="tdStartDate"></td>
                        </tr>
                        <tr>
                            <td>Deadline:</td>
                            <td class="text-end" id="tdEndDate"></td>
                        </tr>
                        <tr>
                            <td>Priority:</td>
                            <td class="text-end" id="tdPriority"></td>
                        </tr>
                        <tr>
                            <td>Combo:</td>
                            <td class="text-end" id="tdCombo"></td>
                        </tr>
                        <tr>
                            <td>Status:</td>
                            <td class="text-end" id="tdStatus"></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card">
            <div class="card-body prj-tbl">
                <p class="m-b-5">Progress <span class="text-success float-end">40%</span></p>
                <div class="progress progress-sm mb-0">
                    <div class="progress-bar progress-profile bg-success" role="progressbar" data-bs-toggle="tooltip"
                        title="40%"></div>
                </div>
            </div>
        </div>
        <div class="card project-user">
            <div class="card-body">
                <h6 class="card-title m-b-20">
                    Assigned users
                    <button type="button" class="float-end btn btn-primary btn-sm" data-bs-toggle="modal"
                        data-bs-target="#assign_user"><i class="fa fa-plus"></i> Add</button>
                </h6>
                <ul class="list-box">
                    <li>
                        <a href="profile.html">
                            <div class="list-item">
                                <div class="list-left">
                                    <span class="avatar"><img
                                            src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-02.jpg"
                                            alt="User Image"></span>
                                </div>
                                <div class="list-body">
                                    <span class="message-author">John Doe</span>
                                    <div class="clearfix"></div>
                                    <span class="message-content">Web Designer</span>
                                </div>
                            </div>
                        </a>
                    </li>
                    <li>
                        <a href="profile.html">
                            <div class="list-item">
                                <div class="list-left">
                                    <span class="avatar"><img
                                            src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-09.jpg"
                                            alt="User Image"></span>
                                </div>
                                <div class="list-body">
                                    <span class="message-author">Richard Miles</span>
                                    <div class="clearfix"></div>
                                    <span class="message-content">Web Developer</span>
                                </div>
                            </div>
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</div>



<script src="<?php echo _WEB_ROOT; ?>/public/assets/js/custom/project/detail.js"></script>



<?php
$this->render('admin/task/modal');
$this->render('admin/task/detail');

?>

