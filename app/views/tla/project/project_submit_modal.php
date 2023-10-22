<!-- Project Submit Modal -->
<div id="project_submit_modal" class="modal custom-modal fade" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="ModalTitle">Upload Project With Url</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">

                <div class="form-group">
                    <label for="">Url</label>
                    <input type="text" placeholder="Please enter the submitting URL ..." id="txtUrl"
                        class="form-control">
                </div>
                <!-- <div class="form-check mt-2">
                    <input class="form-check-input" type="checkbox" value="" id="ckbReadInstruction">
                    <label class="form-check-label" for="flexCheckDefault">
                        I've read the task's instructions.
                    </label>
                </div> -->
                <div class="submit-section">
                    <button class="btn btn-sm btn-secondary" data-bs-dismiss="modal" aria-label="Close">Close</button>
                    <button class="btn btn-sm btn-primary" id="btnSubmitUploadProject">Submit</button>
                </div>


            </div>
        </div>
    </div>
</div>
<!-- /Project Submit Modal -->