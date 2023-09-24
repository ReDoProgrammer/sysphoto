<!-- Search Filter -->
<div class="row filter-row">
    <div class="col-xxl-4">
        <div class="row">
            <div class="col-sm-6 col-md-6">
                <input type="date" id="txtFromDate" class="form-control datepicker" value="2023-09-24">
            </div>
            <div class="col-sm-6 col-md-6">
                <input type="date" id="txtToDate" class="form-control datepicker" value="2023-09-24">

            </div>
        </div>
    </div>
    <div class="col-xxl-3">
        <select class="select" name="states[]" multiple="multiple" id="slJobStatus">
            
        </select>
    </div>
    <div class="col-xxl-3">
        <div class="input-block mb-3 form-focus mb-0">
            <input type="text" class="form-control floating" id="txtSearch">
            <label class="focus-label">Filter project</label>
        </div>
    </div>
    <div class="col-xxl-1">
        <a href="#" id="btnSearch" class="btn btn-success btn-search btn-add-emp"><i class="fas fa-search me-2"></i>
        </a>
    </div>
    <div class="col-xxl-1">
        <div class="add-emp-section">
            <a href="#" class="btn btn-success btn-add-emp" data-bs-toggle="modal" data-bs-target="#create_project"><i
                    class="fas fa-plus"></i>Add</a>
        </div>
    </div>

</div>
<!-- /Search Filter -->

<div class="table-responsive">
    <table class="table table-hover mb-0">
        <thead>
            <tr>
                <th>#</th>
                <th>Customer</th>
                <th>Job</th>
                <th>Start</th>
                <th>Deadline</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody id="tblProjects"></tbody>
    </table>
</div>
<?php
include_once 'create.php';
include_once 'edit.php';
include_once 'delete.php';
?>

<script src="<?php echo _WEB_ROOT; ?>/public/assets/js/custom/project.js"></script>