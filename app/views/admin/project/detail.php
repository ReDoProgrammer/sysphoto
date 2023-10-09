<?php if (!isset($project) || empty($project)) {
    echo '<h1 class="text-center p-3 text-danger">PROJECT NOT FOUND</h1>';
    return;
} ?>
<div class="row">
    <div class="col-lg-8 col-xl-9">
        <div class="card">
            <div class="card-body">
                <div class="project-title">
                    <h5 class="card-title text-info fw-bold">
                        <?php echo $project['project_name']; ?>
                    </h5>
                    <?php
                    $tasks = "";
                    $tasks_list = json_decode($project['tasks_list'], true);
                    foreach ($tasks_list as $d) {
                        $tasks .= $d['quantity'] . " " . $d["status"] . " TASK, ";
                    }
                    ?>
                    <h6>
                        <?php echo rtrim($tasks, ' ,'); ?>
                    </h6>
                </div>
                <?php
                echo '<pre>' . $project['description'] . '</pre>';
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
                            <td class="text-end">
                                <?php echo $project['start_date']; ?>
                            </td>
                        </tr>
                        <tr>
                            <td>Deadline:</td>
                            <td class="text-end">
                                <?php echo $project['end_date']; ?>
                            </td>
                        </tr>
                        <tr>
                            <td>Priority:</td>
                            <td class="text-end">
                                <?php echo $project['priority'] == 1 ? '<i class="fa fa-dot-circle-o text-danger">Urgent</i>' : 'Normal'; ?>
                            </td>
                        </tr>
                        <tr>
                            <td>Combo:</td>
                            <td class="text-end">
                                <?php echo $project['combo_name'] ? '<i class="fa fa-dot-circle-o text-success">' . $project['combo_name'] . '</i>' : ''; ?>
                            </td>
                        </tr>
                        <tr>
                            <td>Status:</td>
                            <td class="text-end">
                                <?php echo '<i class="fa fa-dot-circle-o text-info">' . $project['status'] . '</i>'; ?>
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



<?php
$this->render('admin/task/modal');
$this->render('admin/task/detail');

?>

<script>
    $(document).ready(function () {
        $(".content").each(function () {
            var $content = $(this).find("p");
            var $button = $(this).find(".show-more");
            var currentText = $content.text();

            if (currentText.length > 100) {
                // Hiển thị chỉ 100 ký tự ban đầu và nút "Xem thêm"
                $content.text(currentText.substring(0, 100) + "...");
                $button.show();
            }

            $button.click(function () {
                var hiddenText = $content.data("hidden-text");

                if (hiddenText) {
                    // Đã hiển thị "Xem thêm", nên ẩn nó đi
                    $content.text(hiddenText);
                    $content.data("hidden-text", "");
                    $button.text("Xem thêm");
                } else {
                    // Chưa hiển thị "Xem thêm", nên hiển thị toàn bộ nội dung
                    $content.text(currentText);
                    $content.data("hidden-text", currentText);
                    $button.text("Ẩn bớt");
                }
            });
        });
    });

</script>
<style>
    .show-more {
        display: none;
    }

    .content p {
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        max-width: 100%;
    }
</style>