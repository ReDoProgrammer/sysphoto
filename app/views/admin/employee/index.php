<!-- Search Filter -->
<div class="row filter-row">
    <div class="col-md-9">
        <div class="row">
            <div class="col-xs-12 col-sm-6 col-md-5 col-lg-5">
                <div class="input-block mb-3 form-focus select-focus mb-0">
                    <select id="slEmployeeGroups"></select>
                    <label class="focus-label">Employee groups</label>
                </div>
            </div>

            <div class="col-xs-6 col-sm-6 col-md-5 col-lg-5">
                <div class="input-block mb-3 form-focus mb-0">
                    <input type="text" class="form-control floating" id="txtSearch">
                    <label class="focus-label">Employee filter</label>
                </div>
            </div>

            <div class="col-xs-6 col-sm-6 col-md-2 col-lg-2">
                <a href="#" class="btn btn-success btn-search" id="btnSearch"><i class="fas fa-search me-2"></i> Search </a>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="add-emp-section">
            <a href="#" class="btn btn-success btn-add-emp" data-bs-toggle="modal" data-bs-target="#add_employee"><i
                    class="fas fa-plus"></i> Add Employee</a>
        </div>
    </div>
</div>
<!-- /Search Filter -->

<div class="row">
    <div class="col-md-12">
        <div class="table-responsive">
            <table class="table table-striped custom-table datatable">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Acronym</th>
                        <th>Email</th>
                        <th>Editor Group</th>
                        <th>QA Group</th>
                        <th>Role</th>
                        <th>Group</th>
                        <th>Status</th>
                        <th class="text-nowrap">Join Date</th>
                        <th class="text-end no-sort">Action</th>
                    </tr>
                </thead>
                <tbody id="tblEmployees">
                   
                </tbody>
            </table>
        </div>
    </div>
</div>
<script src="<?php echo _WEB_ROOT; ?>/public/assets/js/custom/employee.js"></script>