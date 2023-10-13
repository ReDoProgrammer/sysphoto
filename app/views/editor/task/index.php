<!-- Search Filter -->
<div class="row filter-row">
    <div class="col-xxl-6 col-lg-6 col-md-6 col-sm-12 col-xs-12">
        <div class="row">
            <div class="col-sm-6 col-md-6">
            <input type="date" id="txtFromDate" class="form-control datetimepicker">
            </div>
            <div class="col-sm-6 col-md-6">
                <input type="date" id="txtToDate" class="form-control datetimepicker">
            </div>
        </div>
    </div>
    <div class="col-xxl-2 col-lg-2 col-md-2 col-sm-6 col-xs-6">
        <select name="" id="slTaskStatuses" ></select>
    </div>   
    <div class="col-xxl-2 col-lg-2 col-md-2 col-sm-6 col-xs-6">
        <a href="#" id="btnSearch" class="btn btn-success btn-search">
            <i class="fas fa-search me-2"></i>
            Load Tasks
        </a>
    </div>
    <div class="col-xxl-2 col-lg-2 col-md-2 col-sm-12 col-xs-12">
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

<script src="<?php echo _WEB_ROOT; ?>/public/assets/js/custom/editor/task/task.js"></script>