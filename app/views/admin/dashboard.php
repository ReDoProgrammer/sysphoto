<div class="row">
                    <div class="col-md-6 col-sm-6 col-lg-6 col-xl-3">
                        <div class="card flex-fill tickets-card">
                            <div class="card-header">
                                <div class="text-center w-100 p-3">
                                    <h3 class="bl-text mb-1">112</h3>
                                    <h2>Projects</h2>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-sm-6 col-lg-6 col-xl-3">
                        <div class="card flex-fill tickets-card">
                            <div class="card-header">
                                <div class="text-center w-100 p-3">
                                    <h3 class="bl-text mb-1">44</h3>
                                    <h2>Clients</h2>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-sm-6 col-lg-6 col-xl-3">
                        <div class="card flex-fill tickets-card">
                            <div class="card-header">
                                <div class="text-center w-100 p-3">
                                    <h3 class="bl-text mb-1">37</h3>
                                    <h2>Tasks</h2>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-sm-6 col-lg-6 col-xl-3">
                        <div class="card flex-fill tickets-card">
                            <div class="card-header">
                                <div class="text-center w-100 p-3">
                                    <h3 class="bl-text mb-1">218</h3>
                                    <h2>Employees</h2>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-12">
                        <div class="row jb-dashboard">
                            <div class="col-md-6 text-center">
                                <div class="card flex-fill">
                                    <div class="card-header">
                                        <h3 class="card-title">Total Revenue</h3>
                                        <div class="dropdown">
                                            <button class="btn btn-secondary dropdown-toggle" type="button"
                                                id="dropdownMenuButton" data-bs-toggle="dropdown" aria-haspopup="true"
                                                aria-expanded="false">
                                                Last 6 months
                                            </button>
                                            <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                                                <a class="dropdown-item" href="#">Last 6 months</a>
                                                <a class="dropdown-item" href="#">Last 3 months</a>
                                                <a class="dropdown-item" href="#">Last 1 months</a>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <div id="bar-charts"></div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 text-center">
                                <div class="card flex-fill">
                                    <div class="card-header">
                                        <h3 class="card-title">Sales Overview</h3>
                                        <div class="dropdown">
                                            <button class="btn btn-secondary dropdown-toggle" type="button"
                                                id="dropdownMenuButton1" data-bs-toggle="dropdown" aria-haspopup="true"
                                                aria-expanded="false">
                                                Last 6 months
                                            </button>
                                            <div class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
                                                <a class="dropdown-item" href="#">Last 6 months</a>
                                                <a class="dropdown-item" href="#">Last 3 months</a>
                                                <a class="dropdown-item" href="#">Last 1 months</a>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <div id="line-charts"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 col-lg-3 d-flex">
                        <div class="card flex-fill tickets-card">
                            <div class="card-header">
                                <div class="">
                                    <h2>New Employees</h2>
                                    <h3 class="bl-text">112</h3>
                                </div>
                                <h6>+10%</h6>
                            </div>
                            <div class="" id="newTicketChart"></div>
                        </div>
                    </div>

                    <div class="col-md-6 col-lg-3 d-flex">
                        <div class="card flex-fill tickets-card">
                            <div class="card-header">
                                <div class="">
                                    <h2>Earnings</h2>
                                    <h3 class="org-text">$1,42,300</h3>
                                </div>
                                <h6>+10%</h6>
                            </div>
                            <div id="solvedTicketChart"></div>
                        </div>
                    </div>

                    <div class="col-md-6 col-lg-3 d-flex">
                        <div class="card flex-fill tickets-card">
                            <div class="card-header">
                                <div class="">
                                    <h2>Expenses</h2>
                                    <h3 class="red-text">$8,500</h3>
                                </div>
                                <h6>+10%</h6>
                            </div>
                            <div id="openTicketChart"></div>
                        </div>
                    </div>

                    <div class="col-md-6 col-lg-3 d-flex">
                        <div class="card flex-fill tickets-card">
                            <div class="card-header">
                                <div class="">
                                    <h2>Profit</h2>
                                    <h3 class="grn-text">$1,12,000</h3>
                                </div>
                                <h6 class="red-text">-10%</h6>
                            </div>
                            <div class="" id="pendingTicketChart"></div>
                        </div>
                    </div>
                </div>

                <!-- Statistics Widget -->
                <div class="row">
                    <div class="col-md-12 col-lg-12 col-xl-5 d-flex">
                        <div class="card project-card flex-fill">
                            <h4>Statistics</h4>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="card st-card st-c1">
                                        <div class="stats-info">
                                            <div class="text-start">
                                                <p>Today</p>
                                                <h5>3.45 / 8 hrs</h5>
                                            </div>

                                            <div class="progress">
                                                <div class="progress-bar bg-primary" role="progressbar"
                                                    style="width: 31%" aria-valuenow="31" aria-valuemin="0"
                                                    aria-valuemax="100"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="card st-card st-c2">
                                        <div class="stats-info">
                                            <div class="text-start">
                                                <p>This Week</p>
                                                <h5>3.45 / 8 hrs</h5>
                                            </div>

                                            <div class="progress">
                                                <div class="progress-bar bg-primary" role="progressbar"
                                                    style="width: 47%" aria-valuenow="47" aria-valuemin="0"
                                                    aria-valuemax="100"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="card st-card st-c3">
                                        <div class="stats-info">
                                            <div class="text-start">
                                                <p>This Month</p>
                                                <h5>3.45 / 8 hrs</h5>
                                            </div>

                                            <div class="progress">
                                                <div class="progress-bar bg-primary" role="progressbar"
                                                    style="width: 87%" aria-valuenow="87" aria-valuemin="0"
                                                    aria-valuemax="100"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="card st-card st-c4">
                                        <div class="stats-info">
                                            <div class="text-start">
                                                <p>Remaining</p>
                                                <h5>3.45 / 8 hrs</h5>
                                            </div>

                                            <div class="progress">
                                                <div class="progress-bar bg-primary" role="progressbar"
                                                    style="width: 87%" aria-valuenow="87" aria-valuemin="0"
                                                    aria-valuemax="100"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-12 col-lg-12 col-xl-7 d-flex">
                        <div class="card project-card flex-fill">
                            <h4>Projects</h4>
                            <div class="row">
                                <div class="col-md-6 d-flex align-items-center justify-content-center">
                                    <div id="radialBarChart"></div>
                                </div>

                                <div class="col-md-6">
                                    <div class="row">
                                        <div class="col-md-12 mb-3">
                                            <div class="task-box color-one">
                                                <div class="task-media">
                                                    <div class="task-icon">
                                                        <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/icons/icon-01.png"
                                                            alt="Icons">
                                                    </div>
                                                    <div class="task-info">
                                                        <h5>Pending Tasks</h5>
                                                        <h2>55</h2>
                                                    </div>
                                                </div>

                                                <div class="task-redirect">
                                                    <div class="redirect-icon">
                                                        <i class="fas fa-long-arrow-alt-right"></i>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-md-12 mb-3">
                                            <div class="task-box color-two">
                                                <div class="task-media">
                                                    <div class="task-icon">
                                                        <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/icons/icon-02.png"
                                                            alt="Icons">
                                                    </div>
                                                    <div class="task-info">
                                                        <h5>Completed Tasks</h5>
                                                        <h2>55</h2>
                                                    </div>
                                                </div>

                                                <div class="task-redirect">
                                                    <div class="redirect-icon">
                                                        <i class="fas fa-long-arrow-alt-right"></i>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-md-12">
                                            <div class="task-box color-three">
                                                <div class="task-media">
                                                    <div class="task-icon">
                                                        <img src="<?php echo _WEB_ROOT; ?>/public/assets/img/icons/icon-03.png"
                                                            alt="Icons">
                                                    </div>
                                                    <div class="task-info">
                                                        <h5>Total Projects</h5>
                                                        <h2>55</h2>
                                                    </div>
                                                </div>

                                                <div class="task-redirect">
                                                    <div class="redirect-icon">
                                                        <i class="fas fa-long-arrow-alt-right"></i>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- /Statistics Widget -->

                <div class="row">
                    <div class="col-md-6 d-flex">
                        <div class="card card-table flex-fill">
                            <div class="card-header">
                                <h3 class="card-title mb-0">Invoices</h3>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-nowrap custom-table mb-0">
                                        <thead>
                                            <tr>
                                                <th>Invoice ID</th>
                                                <th>Client</th>
                                                <th>Due Date</th>
                                                <th>Total</th>
                                                <th>Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td><a href="invoice-view.html">#INV-0001</a></td>
                                                <td>
                                                    <h2><a href="#">Global Technologies</a></h2>
                                                </td>
                                                <td>11 Mar 2019</td>
                                                <td>$380</td>
                                                <td>
                                                    <span class="badge bg-inverse-warning">Partially Paid</span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td><a href="invoice-view.html">#INV-0002</a></td>
                                                <td>
                                                    <h2><a href="#">Delta Infotech</a></h2>
                                                </td>
                                                <td>8 Feb 2019</td>
                                                <td>$500</td>
                                                <td>
                                                    <span class="badge bg-inverse-success">Paid</span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td><a href="invoice-view.html">#INV-0003</a></td>
                                                <td>
                                                    <h2><a href="#">Cream Inc</a></h2>
                                                </td>
                                                <td>23 Jan 2019</td>
                                                <td>$60</td>
                                                <td>
                                                    <span class="badge bg-inverse-danger">Unpaid</span>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="card-footer">
                                <a href="invoices.html">View all invoices</a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 d-flex">
                        <div class="card card-table flex-fill">
                            <div class="card-header">
                                <h3 class="card-title mb-0">Payments</h3>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table custom-table table-nowrap mb-0">
                                        <thead>
                                            <tr>
                                                <th>Invoice ID</th>
                                                <th>Client</th>
                                                <th>Payment Type</th>
                                                <th>Paid Date</th>
                                                <th>Paid Amount</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td><a href="invoice-view.html">#INV-0001</a></td>
                                                <td>
                                                    <h2><a href="#">Global Technologies</a></h2>
                                                </td>
                                                <td>Paypal</td>
                                                <td>11 Mar 2019</td>
                                                <td>$380</td>
                                            </tr>
                                            <tr>
                                                <td><a href="invoice-view.html">#INV-0002</a></td>
                                                <td>
                                                    <h2><a href="#">Delta Infotech</a></h2>
                                                </td>
                                                <td>Paypal</td>
                                                <td>8 Feb 2019</td>
                                                <td>$500</td>
                                            </tr>
                                            <tr>
                                                <td><a href="invoice-view.html">#INV-0003</a></td>
                                                <td>
                                                    <h2><a href="#">Cream Inc</a></h2>
                                                </td>
                                                <td>Paypal</td>
                                                <td>23 Jan 2019</td>
                                                <td>$60</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="card-footer">
                                <a href="payments.html">View all payments</a>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 d-flex">
                        <div class="card card-table flex-fill">
                            <div class="card-header">
                                <h3 class="card-title mb-0">Clients</h3>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table custom-table mb-0">
                                        <thead>
                                            <tr>
                                                <th>Name</th>
                                                <th>Email</th>
                                                <th>Status</th>
                                                <th class="text-end">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>
                                                    <h2 class="table-avatar">
                                                        <a href="#" class="avatar"><img
                                                                src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-19.jpg"
                                                                alt="User Image"></a>
                                                        <a href="client-profile.html">Barry Cuda <span>CEO</span></a>
                                                    </h2>
                                                </td>
                                                <td>barrycuda@example.com</td>
                                                <td>
                                                    <div class="dropdown action-label">
                                                        <a class="btn btn-white btn-sm btn-rounded dropdown-toggle"
                                                            href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                                            <i class="fa fa-dot-circle-o text-success"></i> Active
                                                        </a>
                                                        <div class="dropdown-menu dropdown-menu-right">
                                                            <a class="dropdown-item" href="#"><i
                                                                    class="fa fa-dot-circle-o text-success"></i>
                                                                Active</a>
                                                            <a class="dropdown-item" href="#"><i
                                                                    class="fa fa-dot-circle-o text-danger"></i>
                                                                Inactive</a>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="text-end">
                                                    <div class="dropdown dropdown-action">
                                                        <a href="#" class="action-icon dropdown-toggle"
                                                            data-bs-toggle="dropdown" aria-expanded="false"><i
                                                                class="material-icons">more_vert</i></a>
                                                        <div class="dropdown-menu dropdown-menu-right">
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-pencil m-r-5"></i> Edit</a>
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-trash-o m-r-5"></i> Delete</a>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <h2 class="table-avatar">
                                                        <a href="#" class="avatar"><img
                                                                src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-19.jpg"
                                                                alt="User Image"></a>
                                                        <a href="client-profile.html">Tressa Wexler
                                                            <span>Manager</span></a>
                                                    </h2>
                                                </td>
                                                <td>tressawexler@example.com</td>
                                                <td>
                                                    <div class="dropdown action-label">
                                                        <a class="btn btn-white btn-sm btn-rounded dropdown-toggle"
                                                            href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                                            <i class="fa fa-dot-circle-o text-danger"></i> Inactive
                                                        </a>
                                                        <div class="dropdown-menu dropdown-menu-right">
                                                            <a class="dropdown-item" href="#"><i
                                                                    class="fa fa-dot-circle-o text-success"></i>
                                                                Active</a>
                                                            <a class="dropdown-item" href="#"><i
                                                                    class="fa fa-dot-circle-o text-danger"></i>
                                                                Inactive</a>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="text-end">
                                                    <div class="dropdown dropdown-action">
                                                        <a href="#" class="action-icon dropdown-toggle"
                                                            data-bs-toggle="dropdown" aria-expanded="false"><i
                                                                class="material-icons">more_vert</i></a>
                                                        <div class="dropdown-menu dropdown-menu-right">
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-pencil m-r-5"></i> Edit</a>
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-trash-o m-r-5"></i> Delete</a>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <h2 class="table-avatar">
                                                        <a href="client-profile.html" class="avatar"><img
                                                                src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-07.jpg"
                                                                alt="User Image"></a>
                                                        <a href="client-profile.html">Ruby Bartlett <span>CEO</span></a>
                                                    </h2>
                                                </td>
                                                <td>rubybartlett@example.com</td>
                                                <td>
                                                    <div class="dropdown action-label">
                                                        <a class="btn btn-white btn-sm btn-rounded dropdown-toggle"
                                                            href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                                            <i class="fa fa-dot-circle-o text-danger"></i> Inactive
                                                        </a>
                                                        <div class="dropdown-menu dropdown-menu-right">
                                                            <a class="dropdown-item" href="#"><i
                                                                    class="fa fa-dot-circle-o text-success"></i>
                                                                Active</a>
                                                            <a class="dropdown-item" href="#"><i
                                                                    class="fa fa-dot-circle-o text-danger"></i>
                                                                Inactive</a>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="text-end">
                                                    <div class="dropdown dropdown-action">
                                                        <a href="#" class="action-icon dropdown-toggle"
                                                            data-bs-toggle="dropdown" aria-expanded="false"><i
                                                                class="material-icons">more_vert</i></a>
                                                        <div class="dropdown-menu dropdown-menu-right">
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-pencil m-r-5"></i> Edit</a>
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-trash-o m-r-5"></i> Delete</a>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <h2 class="table-avatar">
                                                        <a href="client-profile.html" class="avatar"><img
                                                                src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-06.jpg"
                                                                alt="User Image"></a>
                                                        <a href="client-profile.html"> Misty Tison <span>CEO</span></a>
                                                    </h2>
                                                </td>
                                                <td>mistytison@example.com</td>
                                                <td>
                                                    <div class="dropdown action-label">
                                                        <a class="btn btn-white btn-sm btn-rounded dropdown-toggle"
                                                            href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                                            <i class="fa fa-dot-circle-o text-success"></i> Active
                                                        </a>
                                                        <div class="dropdown-menu dropdown-menu-right">
                                                            <a class="dropdown-item" href="#"><i
                                                                    class="fa fa-dot-circle-o text-success"></i>
                                                                Active</a>
                                                            <a class="dropdown-item" href="#"><i
                                                                    class="fa fa-dot-circle-o text-danger"></i>
                                                                Inactive</a>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="text-end">
                                                    <div class="dropdown dropdown-action">
                                                        <a href="#" class="action-icon dropdown-toggle"
                                                            data-bs-toggle="dropdown" aria-expanded="false"><i
                                                                class="material-icons">more_vert</i></a>
                                                        <div class="dropdown-menu dropdown-menu-right">
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-pencil m-r-5"></i> Edit</a>
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-trash-o m-r-5"></i> Delete</a>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <h2 class="table-avatar">
                                                        <a href="client-profile.html" class="avatar"><img
                                                                src="<?php echo _WEB_ROOT; ?>/public/assets/img/profiles/avatar-14.jpg"
                                                                alt="User Image"></a>
                                                        <a href="client-profile.html"> Daniel Deacon
                                                            <span>CEO</span></a>
                                                    </h2>
                                                </td>
                                                <td>danieldeacon@example.com</td>
                                                <td>
                                                    <div class="dropdown action-label">
                                                        <a class="btn btn-white btn-sm btn-rounded dropdown-toggle"
                                                            href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                                            <i class="fa fa-dot-circle-o text-danger"></i> Inactive
                                                        </a>
                                                        <div class="dropdown-menu dropdown-menu-right">
                                                            <a class="dropdown-item" href="#"><i
                                                                    class="fa fa-dot-circle-o text-success"></i>
                                                                Active</a>
                                                            <a class="dropdown-item" href="#"><i
                                                                    class="fa fa-dot-circle-o text-danger"></i>
                                                                Inactive</a>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="text-end">
                                                    <div class="dropdown dropdown-action">
                                                        <a href="#" class="action-icon dropdown-toggle"
                                                            data-bs-toggle="dropdown" aria-expanded="false"><i
                                                                class="material-icons">more_vert</i></a>
                                                        <div class="dropdown-menu dropdown-menu-right">
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-pencil m-r-5"></i> Edit</a>
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-trash-o m-r-5"></i> Delete</a>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="card-footer">
                                <a href="clients.html">View all clients</a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 d-flex">
                        <div class="card card-table flex-fill">
                            <div class="card-header">
                                <h3 class="card-title mb-0">Recent Projects</h3>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table custom-table mb-0">
                                        <thead>
                                            <tr>
                                                <th>Project Name </th>
                                                <th>Progress</th>
                                                <th class="text-end">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>
                                                    <h2><a href="project-view.html">Office Management</a></h2>
                                                    <small class="block text-ellipsis">
                                                        <span>1</span> <span class="text-muted">open tasks, </span>
                                                        <span>9</span> <span class="text-muted">tasks completed</span>
                                                    </small>
                                                </td>
                                                <td>
                                                    <div class="progress progress-xs progress-striped">
                                                        <div class="progress-bar" role="progressbar"
                                                            data-bs-toggle="tooltip" title="65%" style="width: 65%">
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="text-end">
                                                    <div class="dropdown dropdown-action">
                                                        <a href="#" class="action-icon dropdown-toggle"
                                                            data-bs-toggle="dropdown" aria-expanded="false"><i
                                                                class="material-icons">more_vert</i></a>
                                                        <div class="dropdown-menu dropdown-menu-right">
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-pencil m-r-5"></i> Edit</a>
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-trash-o m-r-5"></i> Delete</a>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <h2><a href="project-view.html">Project Management</a></h2>
                                                    <small class="block text-ellipsis">
                                                        <span>2</span> <span class="text-muted">open tasks, </span>
                                                        <span>5</span> <span class="text-muted">tasks completed</span>
                                                    </small>
                                                </td>
                                                <td>
                                                    <div class="progress progress-xs progress-striped">
                                                        <div class="progress-bar" role="progressbar"
                                                            data-bs-toggle="tooltip" title="15%" style="width: 15%">
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="text-end">
                                                    <div class="dropdown dropdown-action">
                                                        <a href="#" class="action-icon dropdown-toggle"
                                                            data-bs-toggle="dropdown" aria-expanded="false"><i
                                                                class="material-icons">more_vert</i></a>
                                                        <div class="dropdown-menu dropdown-menu-right">
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-pencil m-r-5"></i> Edit</a>
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-trash-o m-r-5"></i> Delete</a>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <h2><a href="project-view.html">Video Calling App</a></h2>
                                                    <small class="block text-ellipsis">
                                                        <span>3</span> <span class="text-muted">open tasks, </span>
                                                        <span>3</span> <span class="text-muted">tasks completed</span>
                                                    </small>
                                                </td>
                                                <td>
                                                    <div class="progress progress-xs progress-striped">
                                                        <div class="progress-bar" role="progressbar"
                                                            data-bs-toggle="tooltip" title="49%" style="width: 49%">
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="text-end">
                                                    <div class="dropdown dropdown-action">
                                                        <a href="#" class="action-icon dropdown-toggle"
                                                            data-bs-toggle="dropdown" aria-expanded="false"><i
                                                                class="material-icons">more_vert</i></a>
                                                        <div class="dropdown-menu dropdown-menu-right">
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-pencil m-r-5"></i> Edit</a>
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-trash-o m-r-5"></i> Delete</a>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <h2><a href="project-view.html">Hospital Administration</a></h2>
                                                    <small class="block text-ellipsis">
                                                        <span>12</span> <span class="text-muted">open tasks, </span>
                                                        <span>4</span> <span class="text-muted">tasks completed</span>
                                                    </small>
                                                </td>
                                                <td>
                                                    <div class="progress progress-xs progress-striped">
                                                        <div class="progress-bar" role="progressbar"
                                                            data-bs-toggle="tooltip" title="88%" style="width: 88%">
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="text-end">
                                                    <div class="dropdown dropdown-action">
                                                        <a href="#" class="action-icon dropdown-toggle"
                                                            data-bs-toggle="dropdown" aria-expanded="false"><i
                                                                class="material-icons">more_vert</i></a>
                                                        <div class="dropdown-menu dropdown-menu-right">
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-pencil m-r-5"></i> Edit</a>
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-trash-o m-r-5"></i> Delete</a>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <h2><a href="project-view.html">Digital Marketplace</a></h2>
                                                    <small class="block text-ellipsis">
                                                        <span>7</span> <span class="text-muted">open tasks, </span>
                                                        <span>14</span> <span class="text-muted">tasks completed</span>
                                                    </small>
                                                </td>
                                                <td>
                                                    <div class="progress progress-xs progress-striped">
                                                        <div class="progress-bar" role="progressbar"
                                                            data-bs-toggle="tooltip" title="100%" style="width: 100%">
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="text-end">
                                                    <div class="dropdown dropdown-action">
                                                        <a href="#" class="action-icon dropdown-toggle"
                                                            data-bs-toggle="dropdown" aria-expanded="false"><i
                                                                class="material-icons">more_vert</i></a>
                                                        <div class="dropdown-menu dropdown-menu-right">
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-pencil m-r-5"></i> Edit</a>
                                                            <a class="dropdown-item" href="javascript:void(0)"><i
                                                                    class="fa fa-trash-o m-r-5"></i> Delete</a>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="card-footer">
                                <a href="projects.html">View all projects</a>
                            </div>
                        </div>
                    </div>
                </div>