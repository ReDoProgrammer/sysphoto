<!-- Create New Instruction Modal -->
<div id="modal_instruction" class="modal custom-modal fade" role="dialog">
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
                            <label class="col-form-label">Instruction</label>
                            <textarea name="" id="txaNewInstruction" class="form-control"></textarea>
                        </div>
                    </div>
                </div>
                <div class="submit-section">
                    <button class="btn btn-primary cancel-btn" data-bs-dismiss="modal"
                        aria-label="Close">Cancel</button>
                    <button class="btn btn-primary submit-btn" id="btnSubmitNewInstruction">Submit instruction</button>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- /Create New Instruction Modal -->