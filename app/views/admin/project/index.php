    <!-- Search Filter -->
    <div class="row filter-row">
                        <div class="col-xxl-8">
                            <div class="row">
                                <div class="col-sm-6 col-md-3">  
                                    <div class="input-block mb-3 form-focus mb-0">
                                        <input type="text" class="form-control floating">
                                        <label class="focus-label">Project Name</label>
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
                                    <a href="#" class="btn btn-success btn-search mb-3"><i class="fas fa-search me-2"></i> Search </a>
                                </div>
                            </div>
                        </div>
                        <div class="col-xxl-4">
                            <div class="add-emp-section">
                                <a href="projects.html" class="grid-icon active"><i class="fas fa-th"></i></a>
                                <a href="project-list.html" class="list-icon"><i class="fas fa-bars"></i></a>
                                <a href="#" class="btn btn-success btn-add-emp" data-bs-toggle="modal" data-bs-target="#create_project"><i class="fas fa-plus"></i> Create Project</a>
                            </div>
                        </div>
                    </div>
                    <!-- /Search Filter -->
                    
                    <div class="row">
                        <div class="col-lg-4 col-sm-6 col-md-3">
                            <div class="card project-card-det">
                                <div class="card-header">
                                    <div class="dropdown dropdown-action profile-action">
                                        <a href="#" class="action-icon dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false"><i class="material-icons">more_vert</i></a>
                                        <div class="dropdown-menu dropdown-menu-right">
                                            <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#edit_project"><i class="fa fa-pencil m-r-5"></i> Edit</a>
                                            <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#delete_project"><i class="fa fa-trash-o m-r-5"></i> Delete</a>
                                        </div>
                                    </div>
                                </div>

                                <div class="card-body">
                                    <div class="media d-flex">
                                        <span class="avatar flex-shrink-0">
                                            <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/client-small.png" alt="Icon">
                                        </span>
                                        <div class="media-body flex-grow-1">
                                            <h4 class="project-title"><a href="project-view.html">Video Calling App</a></h4>
                                            <h6 class="project-text">3 open tasks, 3 tasks completed</h6>
                                        </div>
                                    </div>
                                    <p class="project-p">Lorem Ipsum is simply dummy text of the printing and typesetting industry. When an unknown printer took a galley of type and scrambled it...</p>
                                    <ul class="cost-li">
                                        <li>
                                            <h5>Cost</h5>
                                            <h6>$1200</h6>
                                        </li>
                                        <li>
                                            <h5>Deadline</h5>
                                            <h6>29 Jun, 2020</h6>
                                        </li>
                                    </ul>
                                    <ul class="team-li">
                                        <li>
                                            <h5>Project Leader</h5>
                                            <a href="#" data-bs-toggle="tooltip" title="Jeffery Lalor"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-16.jpg" alt="User Image"></a>
                                        </li>
                                        <li>
                                            <h5>Team</h5>
                                            <ul class="team-members">
                                                <li>
                                                    <a href="#" data-bs-toggle="tooltip" title="John Doe"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-02.jpg" alt="User Image"></a>
                                                </li>
                                                <li>
                                                    <a href="#" data-bs-toggle="tooltip" title="Mike Litorus"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-05.jpg" alt="User Image"></a>
                                                </li>
                                                <li class="dropdown avatar-dropdown">
                                                    <a href="#" class="all-users dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">+15</a>
                                                    <div class="dropdown-menu dropdown-menu-right">
                                                        <div class="avatar-group">
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-02.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-09.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-10.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-05.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-11.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-12.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-13.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-01.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-16.jpg" alt="User Image">
                                                            </a>
                                                        </div>
                                                        <div class="avatar-pagination">
                                                            <ul class="pagination">
                                                                <li class="page-item">
                                                                    <a class="page-link" href="#" aria-label="Previous">
                                                                        <span aria-hidden="true">«</span>
                                                                        <span class="visually-hidden">Previous</span>
                                                                    </a>
                                                                </li>
                                                                <li class="page-item"><a class="page-link" href="#">1</a></li>
                                                                <li class="page-item"><a class="page-link" href="#">2</a></li>
                                                                <li class="page-item">
                                                                    <a class="page-link" href="#" aria-label="Next">
                                                                        <span aria-hidden="true">»</span>
                                                                    <span class="visually-hidden">Next</span>
                                                                    </a>
                                                                </li>
                                                            </ul>
                                                        </div>
                                                    </div>
                                                </li>
                                            </ul>
                                        </li>
                                    </ul>

                                    <p class="m-b-5 mt-4">Progress <span class="text-blue float-end">40%</span></p>
                                    <div class="progress progress-sm mb-0">
                                        <div class="progress-bar progress-profile bg-blue" role="progressbar" data-bs-toggle="tooltip" title="40%"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-lg-4 col-sm-6 col-md-3">
                            <div class="card project-card-det">
                                <div class="card-header">
                                    <div class="dropdown dropdown-action profile-action">
                                        <a href="#" class="action-icon dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false"><i class="material-icons">more_vert</i></a>
                                        <div class="dropdown-menu dropdown-menu-right">
                                            <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#edit_project"><i class="fa fa-pencil m-r-5"></i> Edit</a>
                                            <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#delete_project"><i class="fa fa-trash-o m-r-5"></i> Delete</a>
                                        </div>
                                    </div>
                                </div>

                                <div class="card-body">
                                    <div class="media d-flex">
                                        <span class="avatar flex-shrink-0">
                                            <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/client-small.png" alt="Icon">
                                        </span>
                                        <div class="media-body flex-grow-1">
                                            <h4 class="project-title"><a href="project-view.html">Video Calling App</a></h4>
                                            <h6 class="project-text">3 open tasks, 3 tasks completed</h6>
                                        </div>
                                    </div>
                                    <p class="project-p">Lorem Ipsum is simply dummy text of the printing and typesetting industry. When an unknown printer took a galley of type and scrambled it...</p>
                                    <ul class="cost-li">
                                        <li>
                                            <h5>Cost</h5>
                                            <h6>$1200</h6>
                                        </li>
                                        <li>
                                            <h5>Deadline</h5>
                                            <h6>29 Jun, 2020</h6>
                                        </li>
                                    </ul>
                                    <ul class="team-li">
                                        <li>
                                            <h5>Project Leader</h5>
                                            <a href="#" data-bs-toggle="tooltip" title="Jeffery Lalor"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-16.jpg" alt="User Image"></a>
                                        </li>
                                        <li>
                                            <h5>Team</h5>
                                            <ul class="team-members">
                                                <li>
                                                    <a href="#" data-bs-toggle="tooltip" title="John Doe"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-02.jpg" alt="User Image"></a>
                                                </li>
                                                <li>
                                                    <a href="#" data-bs-toggle="tooltip" title="Mike Litorus"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-05.jpg" alt="User Image"></a>
                                                </li>
                                                <li class="dropdown avatar-dropdown">
                                                    <a href="#" class="all-users dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">+15</a>
                                                    <div class="dropdown-menu dropdown-menu-right">
                                                        <div class="avatar-group">
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-02.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-09.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-10.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-05.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-11.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-12.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-13.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-01.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-16.jpg" alt="User Image">
                                                            </a>
                                                        </div>
                                                        <div class="avatar-pagination">
                                                            <ul class="pagination">
                                                                <li class="page-item">
                                                                    <a class="page-link" href="#" aria-label="Previous">
                                                                        <span aria-hidden="true">«</span>
                                                                        <span class="visually-hidden">Previous</span>
                                                                    </a>
                                                                </li>
                                                                <li class="page-item"><a class="page-link" href="#">1</a></li>
                                                                <li class="page-item"><a class="page-link" href="#">2</a></li>
                                                                <li class="page-item">
                                                                    <a class="page-link" href="#" aria-label="Next">
                                                                        <span aria-hidden="true">»</span>
                                                                    <span class="visually-hidden">Next</span>
                                                                    </a>
                                                                </li>
                                                            </ul>
                                                        </div>
                                                    </div>
                                                </li>
                                            </ul>
                                        </li>
                                    </ul>

                                    <p class="m-b-5 mt-4">Progress <span class="text-blue float-end">40%</span></p>
                                    <div class="progress progress-sm mb-0">
                                        <div class="progress-bar progress-profile bg-blue" role="progressbar" data-bs-toggle="tooltip" title="40%"></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-4 col-sm-6 col-md-3">
                            <div class="card project-card-det">
                                <div class="card-header">
                                    <div class="dropdown dropdown-action profile-action">
                                        <a href="#" class="action-icon dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false"><i class="material-icons">more_vert</i></a>
                                        <div class="dropdown-menu dropdown-menu-right">
                                            <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#edit_project"><i class="fa fa-pencil m-r-5"></i> Edit</a>
                                            <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#delete_project"><i class="fa fa-trash-o m-r-5"></i> Delete</a>
                                        </div>
                                    </div>
                                </div>

                                <div class="card-body">
                                    <div class="media d-flex">
                                        <span class="avatar flex-shrink-0">
                                            <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/client-small.png" alt="Icon">
                                        </span>
                                        <div class="media-body flex-grow-1">
                                            <h4 class="project-title"><a href="project-view.html">Video Calling App</a></h4>
                                            <h6 class="project-text">3 open tasks, 3 tasks completed</h6>
                                        </div>
                                    </div>
                                    <p class="project-p">Lorem Ipsum is simply dummy text of the printing and typesetting industry. When an unknown printer took a galley of type and scrambled it...</p>
                                    <ul class="cost-li">
                                        <li>
                                            <h5>Cost</h5>
                                            <h6>$1200</h6>
                                        </li>
                                        <li>
                                            <h5>Deadline</h5>
                                            <h6>29 Jun, 2020</h6>
                                        </li>
                                    </ul>
                                    <ul class="team-li">
                                        <li>
                                            <h5>Project Leader</h5>
                                            <a href="#" data-bs-toggle="tooltip" title="Jeffery Lalor"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-16.jpg" alt="User Image"></a>
                                        </li>
                                        <li>
                                            <h5>Team</h5>
                                            <ul class="team-members">
                                                <li>
                                                    <a href="#" data-bs-toggle="tooltip" title="John Doe"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-02.jpg" alt="User Image"></a>
                                                </li>
                                                <li>
                                                    <a href="#" data-bs-toggle="tooltip" title="Mike Litorus"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-05.jpg" alt="User Image"></a>
                                                </li>
                                                <li class="dropdown avatar-dropdown">
                                                    <a href="#" class="all-users dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">+15</a>
                                                    <div class="dropdown-menu dropdown-menu-right">
                                                        <div class="avatar-group">
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-02.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-09.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-10.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-05.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-11.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-12.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-13.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-01.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-16.jpg" alt="User Image">
                                                            </a>
                                                        </div>
                                                        <div class="avatar-pagination">
                                                            <ul class="pagination">
                                                                <li class="page-item">
                                                                    <a class="page-link" href="#" aria-label="Previous">
                                                                        <span aria-hidden="true">«</span>
                                                                        <span class="visually-hidden">Previous</span>
                                                                    </a>
                                                                </li>
                                                                <li class="page-item"><a class="page-link" href="#">1</a></li>
                                                                <li class="page-item"><a class="page-link" href="#">2</a></li>
                                                                <li class="page-item">
                                                                    <a class="page-link" href="#" aria-label="Next">
                                                                        <span aria-hidden="true">»</span>
                                                                    <span class="visually-hidden">Next</span>
                                                                    </a>
                                                                </li>
                                                            </ul>
                                                        </div>
                                                    </div>
                                                </li>
                                            </ul>
                                        </li>
                                    </ul>

                                    <p class="m-b-5 mt-4">Progress <span class="text-blue float-end">40%</span></p>
                                    <div class="progress progress-sm mb-0">
                                        <div class="progress-bar progress-profile bg-blue" role="progressbar" data-bs-toggle="tooltip" title="40%"></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-4 col-sm-6 col-md-3">
                            <div class="card project-card-det">
                                <div class="card-header">
                                    <div class="dropdown dropdown-action profile-action">
                                        <a href="#" class="action-icon dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false"><i class="material-icons">more_vert</i></a>
                                        <div class="dropdown-menu dropdown-menu-right">
                                            <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#edit_project"><i class="fa fa-pencil m-r-5"></i> Edit</a>
                                            <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#delete_project"><i class="fa fa-trash-o m-r-5"></i> Delete</a>
                                        </div>
                                    </div>
                                </div>

                                <div class="card-body">
                                    <div class="media d-flex">
                                        <span class="avatar flex-shrink-0">
                                            <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/client-small.png" ...">
                                        </span>
                                        <div class="media-body flex-grow-1">
                                            <h4 class="project-title"><a href="project-view.html">Video Calling App</a></h4>
                                            <h6 class="project-text">3 open tasks, 3 tasks completed</h6>
                                        </div>
                                    </div>
                                    <p class="project-p">Lorem Ipsum is simply dummy text of the printing and typesetting industry. When an unknown printer took a galley of type and scrambled it...</p>
                                    <ul class="cost-li">
                                        <li>
                                            <h5>Cost</h5>
                                            <h6>$1200</h6>
                                        </li>
                                        <li>
                                            <h5>Deadline</h5>
                                            <h6>29 Jun, 2020</h6>
                                        </li>
                                    </ul>
                                    <ul class="team-li">
                                        <li>
                                            <h5>Project Leader</h5>
                                            <a href="#" data-bs-toggle="tooltip" title="Jeffery Lalor"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-16.jpg" alt="User Image"></a>
                                        </li>
                                        <li>
                                            <h5>Team</h5>
                                            <ul class="team-members">
                                                <li>
                                                    <a href="#" data-bs-toggle="tooltip" title="John Doe"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-02.jpg" alt="User Image"></a>
                                                </li>
                                                <li>
                                                    <a href="#" data-bs-toggle="tooltip" title="Mike Litorus"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-05.jpg" alt="User Image"></a>
                                                </li>
                                                <li class="dropdown avatar-dropdown">
                                                    <a href="#" class="all-users dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">+15</a>
                                                    <div class="dropdown-menu dropdown-menu-right">
                                                        <div class="avatar-group">
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-02.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-09.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-10.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-05.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-11.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-12.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-13.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-01.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-16.jpg" alt="User Image">
                                                            </a>
                                                        </div>
                                                        <div class="avatar-pagination">
                                                            <ul class="pagination">
                                                                <li class="page-item">
                                                                    <a class="page-link" href="#" aria-label="Previous">
                                                                        <span aria-hidden="true">«</span>
                                                                        <span class="visually-hidden">Previous</span>
                                                                    </a>
                                                                </li>
                                                                <li class="page-item"><a class="page-link" href="#">1</a></li>
                                                                <li class="page-item"><a class="page-link" href="#">2</a></li>
                                                                <li class="page-item">
                                                                    <a class="page-link" href="#" aria-label="Next">
                                                                        <span aria-hidden="true">»</span>
                                                                    <span class="visually-hidden">Next</span>
                                                                    </a>
                                                                </li>
                                                            </ul>
                                                        </div>
                                                    </div>
                                                </li>
                                            </ul>
                                        </li>
                                    </ul>

                                    <p class="m-b-5 mt-4">Progress <span class="text-blue float-end">40%</span></p>
                                    <div class="progress progress-sm mb-0">
                                        <div class="progress-bar progress-profile bg-blue" role="progressbar" data-bs-toggle="tooltip" title="40%"></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-4 col-sm-6 col-md-3">
                            <div class="card project-card-det">
                                <div class="card-header">
                                    <div class="dropdown dropdown-action profile-action">
                                        <a href="#" class="action-icon dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false"><i class="material-icons">more_vert</i></a>
                                        <div class="dropdown-menu dropdown-menu-right">
                                            <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#edit_project"><i class="fa fa-pencil m-r-5"></i> Edit</a>
                                            <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#delete_project"><i class="fa fa-trash-o m-r-5"></i> Delete</a>
                                        </div>
                                    </div>
                                </div>

                                <div class="card-body">
                                    <div class="media d-flex">
                                        <span class="avatar flex-shrink-0">
                                            <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/client-small.png" alt="...">
                                        </span>
                                        <div class="media-body flex-grow-1">
                                            <h4 class="project-title"><a href="project-view.html">Video Calling App</a></h4>
                                            <h6 class="project-text">3 open tasks, 3 tasks completed</h6>
                                        </div>
                                    </div>
                                    <p class="project-p">Lorem Ipsum is simply dummy text of the printing and typesetting industry. When an unknown printer took a galley of type and scrambled it...</p>
                                    <ul class="cost-li">
                                        <li>
                                            <h5>Cost</h5>
                                            <h6>$1200</h6>
                                        </li>
                                        <li>
                                            <h5>Deadline</h5>
                                            <h6>29 Jun, 2020</h6>
                                        </li>
                                    </ul>
                                    <ul class="team-li">
                                        <li>
                                            <h5>Project Leader</h5>
                                            <a href="#" data-bs-toggle="tooltip" title="Jeffery Lalor"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-16.jpg" alt="User Image"></a>
                                        </li>
                                        <li>
                                            <h5>Team</h5>
                                            <ul class="team-members">
                                                <li>
                                                    <a href="#" data-bs-toggle="tooltip" title="John Doe"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-02.jpg" alt="User Image"></a>
                                                </li>
                                                <li>
                                                    <a href="#" data-bs-toggle="tooltip" title="Mike Litorus"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-05.jpg" alt="User Image"></a>
                                                </li>
                                                <li class="dropdown avatar-dropdown">
                                                    <a href="#" class="all-users dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">+15</a>
                                                    <div class="dropdown-menu dropdown-menu-right">
                                                        <div class="avatar-group">
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-02.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-09.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-10.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-05.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-11.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-12.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-13.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-01.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-16.jpg" alt="User Image">
                                                            </a>
                                                        </div>
                                                        <div class="avatar-pagination">
                                                            <ul class="pagination">
                                                                <li class="page-item">
                                                                    <a class="page-link" href="#" aria-label="Previous">
                                                                        <span aria-hidden="true">«</span>
                                                                        <span class="visually-hidden">Previous</span>
                                                                    </a>
                                                                </li>
                                                                <li class="page-item"><a class="page-link" href="#">1</a></li>
                                                                <li class="page-item"><a class="page-link" href="#">2</a></li>
                                                                <li class="page-item">
                                                                    <a class="page-link" href="#" aria-label="Next">
                                                                        <span aria-hidden="true">»</span>
                                                                    <span class="visually-hidden">Next</span>
                                                                    </a>
                                                                </li>
                                                            </ul>
                                                        </div>
                                                    </div>
                                                </li>
                                            </ul>
                                        </li>
                                    </ul>

                                    <p class="m-b-5 mt-4">Progress <span class="text-blue float-end">40%</span></p>
                                    <div class="progress progress-sm mb-0">
                                        <div class="progress-bar progress-profile bg-blue" role="progressbar" data-bs-toggle="tooltip" title="40%"></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-4 col-sm-6 col-md-3">
                            <div class="card project-card-det">
                                <div class="card-header">
                                    <div class="dropdown dropdown-action profile-action">
                                        <a href="#" class="action-icon dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false"><i class="material-icons">more_vert</i></a>
                                        <div class="dropdown-menu dropdown-menu-right">
                                            <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#edit_project"><i class="fa fa-pencil m-r-5"></i> Edit</a>
                                            <a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#delete_project"><i class="fa fa-trash-o m-r-5"></i> Delete</a>
                                        </div>
                                    </div>
                                </div>

                                <div class="card-body">
                                    <div class="media d-flex">
                                        <span class="avatar flex-shrink-0">
                                            <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/client-small.png" Icon">
                                        </span>
                                        <div class="media-body flex-grow-1">
                                            <h4 class="project-title"><a href="project-view.html">Video Calling App</a></h4>
                                            <h6 class="project-text">3 open tasks, 3 tasks completed</h6>
                                        </div>
                                    </div>
                                    <p class="project-p">Lorem Ipsum is simply dummy text of the printing and typesetting industry. When an unknown printer took a galley of type and scrambled it...</p>
                                    <ul class="cost-li">
                                        <li>
                                            <h5>Cost</h5>
                                            <h6>$1200</h6>
                                        </li>
                                        <li>
                                            <h5>Deadline</h5>
                                            <h6>29 Jun, 2020</h6>
                                        </li>
                                    </ul>
                                    <ul class="team-li">
                                        <li>
                                            <h5>Project Leader</h5>
                                            <a href="#" data-bs-toggle="tooltip" title="Jeffery Lalor"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-16.jpg" alt="User Image"></a>
                                        </li>
                                        <li>
                                            <h5>Team</h5>
                                            <ul class="team-members">
                                                <li>
                                                    <a href="#" data-bs-toggle="tooltip" title="John Doe"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-02.jpg" alt="User Image"></a>
                                                </li>
                                                <li>
                                                    <a href="#" data-bs-toggle="tooltip" title="Mike Litorus"><img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-05.jpg" alt="User Image"></a>
                                                </li>
                                                <li class="dropdown avatar-dropdown">
                                                    <a href="#" class="all-users dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">+15</a>
                                                    <div class="dropdown-menu dropdown-menu-right">
                                                        <div class="avatar-group">
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-02.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-09.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-10.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-05.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-11.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-12.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-13.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-01.jpg" alt="User Image">
                                                            </a>
                                                            <a class="avatar avatar-xs" href="#">
                                                                <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-16.jpg" alt="User Image">
                                                            </a>
                                                        </div>
                                                        <div class="avatar-pagination">
                                                            <ul class="pagination">
                                                                <li class="page-item">
                                                                    <a class="page-link" href="#" aria-label="Previous">
                                                                        <span aria-hidden="true">«</span>
                                                                        <span class="visually-hidden">Previous</span>
                                                                    </a>
                                                                </li>
                                                                <li class="page-item"><a class="page-link" href="#">1</a></li>
                                                                <li class="page-item"><a class="page-link" href="#">2</a></li>
                                                                <li class="page-item">
                                                                    <a class="page-link" href="#" aria-label="Next">
                                                                        <span aria-hidden="true">»</span>
                                                                    <span class="visually-hidden">Next</span>
                                                                    </a>
                                                                </li>
                                                            </ul>
                                                        </div>
                                                    </div>
                                                </li>
                                            </ul>
                                        </li>
                                    </ul>

                                    <p class="m-b-5 mt-4">Progress <span class="text-blue float-end">40%</span></p>
                                    <div class="progress progress-sm mb-0">
                                        <div class="progress-bar progress-profile bg-blue" role="progressbar" data-bs-toggle="tooltip" title="40%"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>