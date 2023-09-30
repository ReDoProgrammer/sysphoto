<div class="row">
    <div class="col-lg-8 col-xl-9">
        <div class="card">
            <div class="card-body">
                <div class="project-title">
                    <h5 class="card-title">
                        <?php echo $details[0]['name']; ?>
                    </h5>
                    <?php
                    if (empty($details)) {
                        return;
                    }
                    $tasks = "";
                    foreach ($details as $d) {
                        $tasks .= $d['tasks_number'] . " " . $d["stt_task_name"] . " task, ";
                    }
                    ?>
                    <h6>
                        <?php echo rtrim($tasks, ' ,'); ?>
                    </h6>
                </div>
                <?php
                $notes = $details[0]['description'];
                $notes_with_links = preg_replace('/(https?:\/\/[^\s]+)/', '<a href="$1">$1</a>', $notes);
                $notes_with_links = preg_replace('/(\R{2,})/', "\n", $notes_with_links);
                echo '<pre>' . $notes_with_links . '</pre>';
                ?>
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
                                data-bs-target="#add_task"><i class="fas fa-plus"></i> Add new task</a>
                        </div>
                    </div>
                </div>

            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Level</th>
                                <th>Q.ty</th>
                                <th>Note</th>
                                <th>Editor</th>
                                <th>Q.A</th>
                                <th>Got job</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody id="tblTasksList"></tbody>
                    </table>
                </div>
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
                            <td>Cost:</td>
                            <td class="text-end">$1200</td>
                        </tr>
                        <tr>
                            <td>Total Hours:</td>
                            <td class="text-end">100 Hours</td>
                        </tr>
                        <tr>
                            <td>Started date:</td>
                            <td class="text-end">
                                <?php echo $details[0]['start_date']; ?>
                            </td>
                        </tr>
                        <tr>
                            <td>Deadline:</td>
                            <td class="text-end">
                                <?php echo $details[0]['end_date']; ?>
                            </td>
                        </tr>
                        <tr>
                            <td>Priority:</td>
                            <td class="text-end">
                                <?php echo $details[0]['urgent'] == 1 ? '<i class="fa fa-dot-circle-o text-danger">Urgent</i>' : 'Normal'; ?>
                            </td>
                        </tr>
                        <tr>
                            <td>Combo:</td>
                            <td class="text-end">
                                <?php echo '<span class="' . $details[0]['mau_sac'] . '">' . $details[0]['ten_combo'] . '</span>'; ?>
                            </td>
                        </tr>
                        <tr>
                            <td>Status:</td>
                            <td class="text-end">
                                <?php echo '<span class="' . $details[0]['color_sttj'] . '">' . $details[0]['stt_job_name'] . '</span>'; ?>
                            </td>
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