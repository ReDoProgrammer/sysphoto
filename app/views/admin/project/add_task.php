<!-- Add Task Modal -->
<div id="add_task_modal" class="modal custom-modal fade" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title">Add Task</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <div>
                    <div class="input-block mb-3">
                        <label class="col-form-label">Description</label>
                        <div id="divDescription" style="min-height: 100px;"></div>
                    </div>
                    <div class="input-block mb-3">
                        <label class="col-form-label">Level</label>
                        <select class="form-control" id="slLevels"></select>
                    </div>

                    <div class="input-block mb-3">
                        <label class="col-form-label">Editor</label>
                        <select id="slEditors"></select>
                    </div>

                    <div class="input-block mb-3">
                        <label class="col-form-label">Q.A</label>
                        <select id="slQAs"></select>
                    </div>

                    <div class="row">
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Image quantity</label>
                                <select id="slQAs"></select>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Status</label>
                                <select id="slTaskStatuses"></select>
                            </div>
                        </div>
                    </div>
                    <div class="submit-section text-center">
                        <button class="btn btn-primary submit-btn" id="btnSubmitTask">Submit</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- /Add Task Modal -->