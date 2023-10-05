<!-- Search Filter -->
<div class="row filter-row">
    <div class="col-md-8">
        <div class="row">
            <div class="col-sm-5 col-md-5">
                <div class="input-block mb-3 form-focus select-focus mb-0">
                    <select class="floating" id="slCustomerGroups"></select>
                    <label class="focus-label">Customer Group</label>
                </div>
            </div>
            <div class="col-sm-5 col-md-5">
                <div class="input-block mb-3 form-focus mb-0">
                    <input type="text" class="form-control floating" id="txtSearch">
                    <label class="focus-label">Customer search key</label>
                </div>
            </div>

            <div class="col-sm-2 col-md-2">
                <button class="btn btn-success btn-search" id="btnSearch">
                    <i class="fas fa-search me-2"></i>
                    Search
                </button>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="add-emp-section">
            <a href="#" class="btn btn-success btn-add-emp" data-bs-toggle="modal" data-bs-target="#modal_customer"><i
                    class="fas fa-plus"></i> Add Customer</a>
        </div>
    </div>
</div>
<!-- /Search Filter -->

<div class="row">
    <div class="col-md-12">
        <div class="table-responsive" style="min-height:400px; max-height:450px;">
            <table class="table table-striped custom-table datatable">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Group</th>
                        <th>Fullname</th>
                        <th>Acronym</th>
                        <th>Email</th>
                        <th>Company</th>
                        <th>Url</th>
                        <th class="text-end">Action</th>
                    </tr>
                </thead>
                <tbody id="tblCustomers"></tbody>
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
    </div>
</div>

<?php
include_once 'modal.php';
?>

<script src="<?php echo _WEB_ROOT; ?>/public/assets/js/custom/customer/customer.js"></script>