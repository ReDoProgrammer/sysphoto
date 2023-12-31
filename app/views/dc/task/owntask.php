<!-- Search Filter -->
<div class="row filter-row">
    <div class="col-xxl-6 col-lg-6 col-md-6 col-sm-12 col-xs-12">
        <div class="row">
            <div class="col-sm-6 col-md-6">
            <input type="date" id="txtFromDate" class="form-control datetimepicker-start">
            </div>
            <div class="col-sm-6 col-md-6">
                <input type="date" id="txtToDate" class="form-control datetimepicker-end">
            </div>
        </div>
    </div>
    <div class="col-xxl-4 col-lg-4 col-md-4 col-sm-6 col-xs-6">
        <select name="" id="slTaskStatuses" ></select>
    </div>   
    <div class="col-xxl-2 col-lg-2 col-md-2 col-sm-6 col-xs-6">
        <a href="#" id="btnSearch" class="btn btn-success btn-search">
            <i class="fas fa-search me-2"></i>
            Load Tasks
        </a>
    </div>   
</div>
<!-- /Search Filter -->
<div class="card">
    <div class="card-header">
        <h4 class="card-title mb-0">Your Own Tasks List</h4>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-hover mb-0" style="min-height: 200px;max-height:300px; overflow-y: auto;border: 1px solid #ccc; padding-left:20px; padding-top:10px; padding-bottom: 10px; ">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Project</th>                      
                        <th>Level</th>
                        <th>From date</th>
                        <th>To date</th>
                        <th class="text-center">Q.ty</th>
                        <th>Status</th>
                        <th class="text-center">Editor</th>
                        <th class="text-center">Link</th>
                        <th class="text-center">QA</th>
                        <th class="text-center">DC</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody id="tblOwnTasks" ></tbody>
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
</div>

<script src="<?php echo _WEB_ROOT; ?>/public/assets/js/custom/dc/task/own-task.js"></script>