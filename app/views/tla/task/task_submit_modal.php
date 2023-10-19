<!-- Task Submit Modal -->
<div id="task_submit_modal" class="modal custom-modal fade" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="SubmitingModalTitle">Editor Submit Task</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-sm-12">
                        <div class="input-block mb-3">
                            <label class="col-form-label">Submit Remark</label>
                            <div id="divTaskSubmitingRemark" style="min-height: 100px;"></div>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-sm-12">
                        <div class="form-check mt-2">
                            <input class="form-check-input" type="checkbox" value="" id="ckbReadInstruction">
                            <label class="form-check-label" for="flexCheckDefault">
                                I've read the task's instructions.
                            </label>
                        </div>
                    </div>
                </div>

                <div class="submit-section">
                    <button class="btn btn-sm btn-secondary" data-bs-dismiss="modal" aria-label="Close">Close</button>
                    <button class="btn btn-sm btn-primary" id="btnSubmitTask">Submit</button>
                </div>


            </div>
        </div>
    </div>
</div>
<!-- /Task Submit Modal -->