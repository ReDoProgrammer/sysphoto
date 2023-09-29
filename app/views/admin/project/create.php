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
                <div>
                    <div class="row">
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Customer</label>                                
                                <select id="slCustomers"></select>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Project Name (<span
                                        class="text-danger fw-bold">*</span>)</label>
                                <input class="form-control" type="text" id="txtProjectName">
                            </div>
                        </div>

                    </div>
                    <div class="row">
                        <div class="col-sm-5">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Start Date</label>
                                <div class="cal-icon">
                                    <input type="date" id="txtBeginDate" class="form-control datetimepicker">
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-2">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Duration(hour)</label>
                                <input class="form-control" type="text" id="txtDuration" value="1"
                                    style="text-align: right;">
                            </div>
                        </div>
                        <div class="col-sm-5">
                            <div class="input-block mb-3">
                                <label class="col-form-label">End Date</label>
                                <div class="cal-icon">
                                    <input type="date" id="txtEndDate" class="form-control datetimepicker">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-4">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Combo</label>                               
                                <select id="slComboes"></select>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Template</label>
                                <select class="select" name="templates[]" multiple="multiple" id="slTemplates"></select>
                            </div>
                        </div>

                        <div class="col-sm-2">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Priority</label>
                                <div class="checkbox">
                                    <label class="col-form-label">
                                        <input type="checkbox" name="checkbox" id="ckbPriority"> Urgent
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Project's description</label>
                                <div class="editor" id="divDescription"></div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Intruction for Editor</label>
                                <textarea name="" id="txaIntruction" rows="3" class="form-control"></textarea>
                            </div>
                        </div>
                    </div>

                    <div class="submit-section">
                        <button class="btn btn-primary cancel-btn" data-bs-dismiss="modal"
                            aria-label="Close">Cancel</button>
                        <button class="btn btn-primary submit-btn" id="btnSubmitJob">Submit</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- /Create Project Modal -->

