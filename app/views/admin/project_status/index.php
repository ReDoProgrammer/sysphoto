<div class="row filter-row">
    <a href="#" class="btn btn-success btn-sm btn-add-emp" data-bs-toggle="modal" data-bs-target="#modal_status"><i
            class="fas fa-plus"></i>Add</a>
</div>
<div class="table-responsive" style="min-height:400px; max-height:450px;">
    <table class="table table-hover mb-0">
        <thead>
            <tr>
                <th>#</th>
                <th>Name</th>
                <th>Description</th>
                <th class="text-center">CSS status</th>
                <th></th>
            </tr>
        </thead>
        <tbody id="tblProjectStatuses"></tbody>
    </table>
</div>

<?php
include_once 'modal_status.php';
?>

<script src="<?php echo _WEB_ROOT; ?>/public/assets/js/custom/project_status/project_status.js"></script>