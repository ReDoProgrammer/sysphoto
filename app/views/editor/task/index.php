<!-- Search Filter -->
<div class="row filter-row">
    <div class="col-xxl-4 col-lg-4 col-md-4 col-sm-6 col-xs-12">
        <div class="row">
            <div class="col-sm-6 col-md-6">
                <input type="date" id="txtFromDate" class="form-control datepicker">
            </div>
            <div class="col-sm-6 col-md-6">
                <input type="date" id="txtToDate" class="form-control datepicker">
            </div>
        </div>
    </div>
    <div class="col-xxl-4 col-lg-4 col-md-3 col-sm-6 col-xs-12">
        <div class="input-block mb-3 form-focus mb-0">
            <input type="text" class="form-control floating" id="txtSearch">
            <label class="focus-label">Filter task</label>
        </div>
    </div>
    <div class="col-xxl-1 col-lg-1 col-md-3 col-sm-6 col-xs-12">
        <a href="#" id="btnSearch" class="btn btn-success btn-search"><i class="fas fa-search me-2"></i>
        </a>
    </div>
    <div class="col-xxl-3 col-lg-3 col-md-2 col-sm-6 col-xs-12">
        <div class="add-emp-section">
            <button class="btn btn-success btn-add-emp" id="btnGetTask">
                <i class="fas fa-plus"></i>
                Get more task
            </button>
        </div>
    </div>
</div>
<!-- /Search Filter -->
<div class="card">
    <div class="card-header">
        <h4 class="card-title mb-0">Your Tasks List</h4>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead>
                    <tr>
                        <th>First Name</th>
                        <th>Last Name</th>
                        <th>Email</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>John</td>
                        <td>Doe</td>
                        <td>john@example.com</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>
<script src="<?php echo _WEB_ROOT; ?>/public/assets/js/custom/editor/task/task.js"></script>
