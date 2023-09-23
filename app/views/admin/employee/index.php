<!-- Search Filter -->
<div class="row filter-row">
    <div class="col-md-8">
        <div class="row">
            <div class="col-sm-6 col-md-3">
                <div class="input-block mb-3 form-focus mb-0">
                    <input type="text" class="form-control floating">
                    <label class="focus-label">Employee ID</label>
                </div>
            </div>
            <div class="col-sm-6 col-md-3">
                <div class="input-block mb-3 form-focus mb-0">
                    <input type="text" class="form-control floating">
                    <label class="focus-label">Employee Name</label>
                </div>
            </div>
            <div class="col-sm-6 col-md-3">
                <div class="input-block mb-3 form-focus select-focus mb-0">
                    <select class="select floating">
                        <option>Select Designation</option>
                        <option>Web Developer</option>
                        <option>Web Designer</option>
                        <option>Android Developer</option>
                        <option>Ios Developer</option>
                    </select>
                    <label class="focus-label">Designation</label>
                </div>
            </div>
            <div class="col-sm-6 col-md-3">
                <a href="#" class="btn btn-success btn-search"><i class="fas fa-search me-2"></i> Search </a>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="add-emp-section">
            <a href="employees.html" class="grid-icon"><i class="fas fa-th"></i></a>
            <a href="employees-list.html" class="list-icon active"><i class="fas fa-bars"></i></a>
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
                        <th>Employee ID</th>
                        <th>Email</th>
                        <th>Mobile</th>
                        <th class="text-nowrap">Join Date</th>
                        <th>Role</th>
                        <th class="text-end no-sort">Action</th>
                    </tr>
                </thead>
                <tbody>

                    <?php
                    foreach ($employee as $emp) { ?>
                        <tr>
                            <td>
                                <h2 class="table-avatar">
                                    <a href="profile.html" class="avatar"><img
                                            src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-02.jpg"
                                            alt="User Image"></a>
                                    <a href="profile.html"><?php echo $emp['firstname']?> <span><?php echo $emp['name_ut'];?></span></a>
                                </h2>
                            </td>
                            <td><?php echo $emp['viettat'];?></td>
                            <td><?php echo $emp['email'];?></td>
                            <td>9876543210</td>
                            <td><?php echo date("jS M Y",strtotime($emp['date_created']));?></td>
                            <td>
                                <span class="role-info role-bg-one"><?php echo $emp['name_ut'];?></span>
                            </td>
                            <td class="text-end ico-sec">
                                <a href="#" data-bs-toggle="modal" data-bs-target="#edit_employee"><i
                                        class="fas fa-pen"></i></a>
                                <a href="#" data-bs-toggle="modal" data-bs-target="#delete_employee"><i
                                        class="far fa-trash-alt"></i></a>
                            </td>
                        </tr>
                    <?php }
                    ?>
                </tbody>
            </table>
        </div>
    </div>
</div>