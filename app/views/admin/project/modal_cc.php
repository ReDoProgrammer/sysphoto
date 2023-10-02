<!-- Create CC Modal -->
<div id="modal_cc" class="modal custom-modal fade" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="taskModalTitle">Add New CC</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-sm-6">
                        <div class="input-block mb-3">
                            <label class="col-form-label">Start Date</label>
                            <div class="cal-icon">
                                <input type="date" id="txtCCBeginDate" class="form-control datetimepicker">
                            </div>
                        </div>
                    </div>

                    <div class="col-sm-6">
                        <div class="input-block mb-3">
                            <label class="col-form-label">End Date</label>
                            <div class="cal-icon">
                                <input type="date" id="txtCCEndDate" class="form-control datetimepicker">
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-sm-12">
                        <div class="input-block mb-3">
                            <label class="col-form-label">CC description</label>
                            <div id="divCCDescription" style="min-height: 100px;"></div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-sm-12">
                        <div class="input-block mb-3">
                            <label class="col-form-label">CC Instruction</label>
                            <div id="divCCInstruction" style="min-height: 100px;"></div>
                        </div>
                    </div>
                </div>


                <div class="submit-section">
                    <button class="btn btn-primary cancel-btn" data-bs-dismiss="modal"
                        aria-label="Close">Cancel</button>
                    <button class="btn btn-primary submit-btn" id="btnSubmitCC">Submit</button>
                </div>


            </div>
        </div>
    </div>
</div>
<!-- /Create CC Modal -->


<script src="<?php echo _WEB_ROOT; ?>/public/assets/js/custom/project/cc.js"></script>