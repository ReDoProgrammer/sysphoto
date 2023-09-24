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

<?php include_once 'create.php'?>

<!-- Edit Project Modal -->
<div id="edit_project" class="modal custom-modal fade" role="dialog">
    <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Edit Project</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-body">
                <form>
                    <div class="row">
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Project Name</label>
                                <input class="form-control" value="Project Management" type="text">
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Client</label>
                                <select class="select">
                                    <option>Global Technologies</option>
                                    <option>Delta Infotech</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Start Date</label>
                                <div class="cal-icon">
                                    <input class="form-control datetimepicker" type="text">
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">End Date</label>
                                <div class="cal-icon">
                                    <input class="form-control datetimepicker" type="text">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-3">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Rate</label>
                                <input placeholder="$50" class="form-control" value="$5000" type="text">
                            </div>
                        </div>
                        <div class="col-sm-3">
                            <div class="input-block mb-3">
                                <label class="col-form-label">&nbsp;</label>
                                <select class="select">
                                    <option>Hourly</option>
                                    <option selected>Fixed</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Priority</label>
                                <select class="select">
                                    <option selected>High</option>
                                    <option>Medium</option>
                                    <option>Low</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Add Project Leader</label>
                                <input class="form-control" type="text">
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Team Leader</label>
                                <div class="project-members">
                                    <a href="#" data-bs-toggle="tooltip" title="Jeffery Lalor" class="avatar">
                                        <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-16.jpg" alt="User Image">
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Add Team</label>
                                <input class="form-control" type="text">
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Team Members</label>
                                <div class="project-members">
                                    <a href="#" data-bs-toggle="tooltip" title="John Doe" class="avatar">
                                        <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-16.jpg" alt="User Image">
                                    </a>
                                    <a href="#" data-bs-toggle="tooltip" title="Richard Miles" class="avatar">
                                        <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-09.jpg" alt="User Image">
                                    </a>
                                    <a href="#" data-bs-toggle="tooltip" title="John Smith" class="avatar">
                                        <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-10.jpg" alt="User Image">
                                    </a>
                                    <a href="#" data-bs-toggle="tooltip" title="Mike Litorus" class="avatar">
                                        <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-05.jpg" alt="User Image">
                                    </a>
                                    <span class="all-team">+2</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="input-block mb-3">
                        <label class="col-form-label">Description</label>
                        <textarea rows="4" class="form-control" placeholder="Enter your message here"></textarea>
                    </div>
                    <div class="input-block mb-3">
                        <label class="col-form-label">Upload Files</label>
                        <input class="form-control" type="file">
                    </div>
                    <div class="submit-section">
                        <button class="btn btn-primary cancel-btn" data-bs-dismiss="modal"
                            aria-label="Close">Cancel</button>
                        <button class="btn btn-primary submit-btn">Save</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<!-- /Edit Project Modal -->

<!-- Delete Project Modal -->
<div class="modal custom-modal fade" id="delete_project" role="dialog">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body">
                <div class="form-header">
                    <h3>Delete Project</h3>
                    <p>Are you sure want to delete?</p>
                </div>
                <div class="modal-btn delete-action">
                    <div class="row">
                        <div class="col-6">
                            <a href="javascript:void(0);" class="btn btn-primary continue-btn">Delete</a>
                        </div>
                        <div class="col-6">
                            <a href="javascript:void(0);" data-bs-dismiss="modal"
                                class="btn btn-primary cancel-btn">Cancel</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- /Delete Project Modal -->

<script src="<?php echo _WEB_ROOT; ?>/public/assets/js/task/task.js"></script>