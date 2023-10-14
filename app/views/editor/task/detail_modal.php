<!-- Task Detail Modal -->
<div id="task_modal" class="modal custom-modal fade" role="dialog">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="CustomerModalTitle">Task Detail</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-sm-4 form-group">
                        <label for="">Level</label>
                        <h4 id="level" class="mt-2"></h4>
                    </div>
                    <div class="col-sm-4 form-group">
                        <label for="">Quantity</label>
                        <h4 id="quantity" class="mt-2"></h4>
                    </div>
                    <div class="col-sm-4 form-group">
                        <label for="">Status</label>
                        <h4 id="status" class="mt-2"></h4>
                    </div>
                </div>
                <hr>
                <div class="card">
                    <div class="card-header">Project Description</div>
                    <div class="card-body">
                        <p id="pDescription" class="mt-2"></p>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">Instructions:</div>
                    <div class="card-body">
                        <div id="divInstructions"
                            style="max-height:200px; overflow-y: auto;border: 1px solid #ccc;"></div>
                    </div>
                </div>


               <div class="card" id="divCC"></div>

               

                <div class="card mt-2">
                    <div class="card-header">Task logs:</div>
                    <div class="card-body" id="divTaskLogs"></div>
                </div>

                <div class="row">
                    <div class="col-sm-4 form-group">
                        <label for="">Editor</label>
                        <h4 id="editor" class="mt-2 text-info"></h4>
                    </div>
                    <div class="col-sm-4 form-group">
                        <label for="">QA</label>
                        <h4 id="qa" class="mt-2 text-info"></h4>
                    </div>
                    <div class="col-sm-4 form-group">
                        <label for="">DC</label>
                        <h4 id="dc" class="mt-2 text-info"></h4>
                    </div>
                </div>

                <div class="submit-section">
                    <button class="btn btn-sm btn-primary cancel-btn" data-bs-dismiss="modal"
                        aria-label="Close">Close</button>
                </div>


            </div>
        </div>
    </div>
</div>
<!-- /Task Detail Modal -->