<!-- Task Detail Modal -->
<div id="task_detail_modal" class="modal custom-modal fade" role="dialog">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="CustomerModalTitle">Task Detail</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-sm-2 form-group">
                        <label for="">Level</label>
                        <h4 id="level" class="mt-2"></h4>
                    </div>
                    <div class="col-sm-2 form-group">
                        <label for="">Quantity</label>
                        <h4 id="quantity" class="mt-2"></h4>
                    </div>
                    <div class="col-sm-2 form-group">
                        <label for="">Status</label><br/>
                        <h4 id="status" class="mt-2"></h4>
                    </div>
                    <div class="col-sm-3 form-group text-center">
                        <label for="">Start date</label>
                        <h5 class="mt-2 text-center" id="start_date"></h5>
                    </div>
                    <div class="col-sm-3 form-group text-center">
                        <label for="">End date</label>
                        <h5 class="mt-2 text-center" id="end_date"></h5>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header fw-bold text-info">Description</div>
                    <div class="card-body" id="divDescription"
                        style="max-height:350px; overflow-y: auto;border: 1px solid #ccc; padding-left:20px; padding-top:10px; padding-bottom: 10px; ">
                    </div>
                </div>

                <div class="card mt-2">
                    <div class="card-header fw-bold text-info">Task logs:</div>
                    <div class="card-body">
                        <ul class="res-activity-list" id="ulTaskLogs"
                            style="max-height:200px; overflow-y: auto;border: 1px solid #ccc; padding-left:20px; padding-top:10px; padding-bottom: 10px; ">


                        </ul>
                    </div>
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