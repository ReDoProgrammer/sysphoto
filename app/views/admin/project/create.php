<!-- Create Project Modal -->
<div id="create_project" class="modal custom-modal fade" role="dialog">
    <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Create Project</h5>
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
                                <input class="form-control" type="text">
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
                                <input placeholder="$50" class="form-control" type="text">
                            </div>
                        </div>
                        <div class="col-sm-3">
                            <div class="input-block mb-3">
                                <label class="col-form-label">&nbsp;</label>
                                <select class="select">
                                    <option>Hourly</option>
                                    <option>Fixed</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Priority</label>
                                <select class="select">
                                    <option>High</option>
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
                        <div id="editor"></div>
                    </div>
                    <div class="input-block mb-3">
                        <label class="col-form-label">Upload Files</label>
                        <input class="form-control" type="file">
                    </div>
                    <div class="submit-section">
                        <button class="btn btn-primary cancel-btn" data-bs-dismiss="modal"
                            aria-label="Close">Cancel</button>
                        <button class="btn btn-primary submit-btn">Submit</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<!-- /Create Project Modal -->