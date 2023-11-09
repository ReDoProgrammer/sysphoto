<!-- Create CC Modal -->
<div id="modal_status" class="modal custom-modal fade" role="dialog">
    <div class="modal-dialog modal-md">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="taskModalTitle">Modal status</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label for="">Name</label>
                    <input type="text" name="" id="txtName" class="form-control">
                </div>
                <div class="form-group mt-3">
                    <label for="">Background color (using class)</label>
                    <input type="text" name="" id="txtColor" class="form-control">
                </div>
                <div class="form-group mt-3">
                    <label for="">Description</label>
                    <textarea name="" id="txaDescription" class="form-control"></textarea>
                </div>

                <div class="punch-btn-section mt-3">
                    <span>CSS visible</span>
                    <div class="onoffswitch">
                        <input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="switch_visible"
                            >
                        <label class="onoffswitch-label" for="switch_visible">
                            <span class="onoffswitch-inner"></span>
                            <span class="onoffswitch-switch onoffswitch-innerone"></span>
                        </label>
                    </div>
                    <span>Normal status</span>
                </div>
                <div class="submit-section">
                    <button class="btn btn-primary cancel-btn" data-bs-dismiss="modal"
                        aria-label="Close">Cancel</button>
                    <button class="btn btn-primary submit-btn" id="btnSubmit">Submit</button>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- /Create CC Modal -->