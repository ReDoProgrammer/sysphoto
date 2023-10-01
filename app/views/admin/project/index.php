<!-- Search Filter -->
<div class="row filter-row">
    <div class="col-xxl-4">
        <div class="row">
            <div class="col-sm-6 col-md-6">
                <input type="date" id="txtFromDate" class="form-control datepicker">
            </div>
            <div class="col-sm-6 col-md-6">
                <input type="date" id="txtToDate" class="form-control datepicker">
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
        <a href="#" id="btnSearch" class="btn btn-success btn-search"><i class="fas fa-search me-2"></i>
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

<div class="table-responsive"  style="min-height:300px;">
    <table class="table table-hover mb-0">
        <thead>
            <tr>
                <th>#</th>
                <th>Customer</th>
                <th>Job</th>
                <th>Start</th>
                <th>Deadline</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody id="tblProjects"></tbody>
    </table>
</div>
<div class="row mt-2">
    <div class="col-md-2 col-xs-6">
        <select name="" id="slPageSize" class="form-control">]
            <option value="10">10</option>
            <option value="50">50</option>
            <option value="100">100</option>
            <option value="200">200</option>
            <option value="0">All</option>
        </select>
    </div>
    <div class="col-md-10 col-xs-6 text-end mt-2">
        <nav aria-label="...">
            <ul class="pagination" id="pagination">
                <li class="page-item disabled">
                    <a class="page-link" href="#" tabindex="-1" aria-disabled="true">Previous</a>
                </li>
                <li class="page-item"><a class="page-link" href="#">1</a></li>
                <li class="page-item active" aria-current="page">
                    <a class="page-link" href="#">2</a>
                </li>
                <li class="page-item"><a class="page-link" href="#">3</a></li>
                <li class="page-item">
                    <a class="page-link" href="#">Next</a>
                </li>
            </ul>
        </nav>
    </div>
</div>

<link rel="stylesheet" href="<?php echo _WEB_ROOT; ?>/public/assets/plugins/quill/quill.snow.css">
<script src="<?php echo _WEB_ROOT; ?>/public/assets/plugins/quill/quill.js"></script>
<?php
include_once 'create.php';
include_once 'edit.php';
include_once 'delete.php';
?>


<script src="<?php echo _WEB_ROOT; ?>/public/assets/js/custom/project/index.js"></script>

