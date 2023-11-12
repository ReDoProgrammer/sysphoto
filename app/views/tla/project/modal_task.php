<!-- Add or update Task Modal -->
<div id="task_modal" class="modal custom-modal fade" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="taskModalTitle">Add Task</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <div>
                    <div class="input-block mb-3">
                        <label class="col-form-label">Description</label>
                        <textarea name="" id="txaTaskDescription" class="form-control"></textarea>
                    </div>
                    <div class="row">
                        <div class="col-sm-10">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Level</label>
                                <select class="form-control" id="slLevels"></select>
                            </div>
                        </div>
                        <div class="col-sm-2">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Q.ty</label>
                                <input type="text" value="1" id="txtQuantity" class="form-control text-end"
                                    onkeypress="return isNumberKey(event)">
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Editor</label>
                                <select id="slEditors"></select>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="input-block mb-3">
                                <label class="col-form-label">Q.A</label>
                                <select id="slQAs"></select>
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
<!-- /Add or update Task Modal -->




<script src="<?php echo _WEB_ROOT; ?>/public/assets/js/custom/tla/project/task.js"></script>