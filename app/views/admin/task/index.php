<!-- Search Filter -->
<div class="row filter-row">
    <div class="col-xxl-8">
        <div class="row">
            <div class="col-sm-6 col-md-3">
                <div class="input-block mb-3 form-focus mb-0">
                    <input type="text" class="form-control floating" id="txtProject" value = "project 1">
                    <label class="focus-label">Project Name</label>
                </div>
            </div>
            <div class="col-sm-6 col-md-3">
                <div class="input-block mb-3 form-focus mb-0">
                    <input type="text" class="form-control floating" id="txtEmployee" value="Thien">
                    <label class="focus-label">Employee Name</label>
                </div>
            </div>
            <div class="col-sm-6 col-md-3">
                <div class="input-block mb-3 form-focus select-focus mb-0">
                    <select class="select floating">
                        <option>Select Role</option>
                        <option>Web Developer</option>
                        <option>Web Designer</option>
                        <option>Android Developer</option>
                        <option>Ios Developer</option>
                    </select>
                    <label class="focus-label">Designation</label>
                </div>
            </div>
            <div class="col-sm-6 col-md-3">
                <a href="#" id="btnSearch" class="btn btn-success btn-search mb-3"><i class="fas fa-search me-2"></i> Search </a>
            </div>
        </div>
    </div>
    <div class="col-xxl-4">
        <div class="add-emp-section">
            <a href="projects.html" class="grid-icon active"><i class="fas fa-th"></i></a>
            <a href="project-list.html" class="list-icon"><i class="fas fa-bars"></i></a>
            <a href="#" class="btn btn-success btn-add-emp" data-bs-toggle="modal" data-bs-target="#create_project"><i
                    class="fas fa-plus"></i> Create Project</a>
        </div>
    </div>
</div>
<!-- /Search Filter -->

<table>
    <tbody id = "tblTasks"></tbody>
</table>

<?php include_once 'modal.php'?>

<script src="<?php echo _WEB_ROOT; ?>/public/assets/js/custom/task.js"></script>