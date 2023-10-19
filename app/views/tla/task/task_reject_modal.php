<!-- Task Rejecting Modal -->
<div id="task_reject_modal" class="modal custom-modal fade" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="InstructionModalTitle">Add New Instruction</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-sm-12">
                        <div class="input-block mb-3">
                            <label class="col-form-label">Rejecting Remark</label>
                            <div id="divTaskRejectingRemark" style="min-height: 100px;"></div>
                        </div>
                    </div>
                </div>
                <div class="form-check mt-2">
                    <input class="form-check-input" type="checkbox" value="" id="ckbRejectReadInstructions">
                    <label class="form-check-label" for="flexCheckDefault">
                        I've read the task's instructions.
                    </label>
                </div>
                <div class="submit-section">
                    <button class="btn btn-primary cancel-btn" data-bs-dismiss="modal"
                        aria-label="Close">Cancel</button>
                    <button class="btn btn-warning submit-btn" id="btnSubmitRejectingTask">Submit Rejecting</button>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- /Task Rejecting Modal -->