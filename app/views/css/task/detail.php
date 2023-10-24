<!-- View Task Modal -->
<div id="view_task_modal" class="modal custom-modal fade" role="dialog">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title">Task detail</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-sm-12">
                        <p class="text-info" id="pDescription"></p>
                    </div>
                </div>
                <hr>
                <div class="row mt-3">
                    <div class="col-sm-3">Level</div>
                    <div class="col-sm-3 fw-bold" id="dLevel"></div>
                    <div class="col-sm-3">Quantity:</div>
                    <div class="col-sm-3" id="dQuantity"></div>
                </div>
               
                <div class="row mt-3">
                    <div class="col-sm-3">Editor:</div>
                    <div class="col-sm-5" id="dEditor"></div>
                    <div class="col-sm-4" id="dETimeStamp"></div>                    
                </div>
                <div class="row mt-3">
                    <div class="col-sm-3"></div>                  
                    <div class="col-sm-5" id="dEAssigned"></div>
                    <div class="col-sm-4" id="dEView"></div>
                </div>

                <div class="row mt-3">
                    <div class="col-sm-3">QA:</div>
                    <div class="col-sm-5" id="dQA"></div>
                    <div class="col-sm-4" id="dQATimeStamp"></div>                    
                </div>
                <div class="row mt-3">
                    <div class="col-sm-3"></div>                  
                    <div class="col-sm-5" id="dQAAssigned"></div>
                    <div class="col-sm-4" id="dQAView"></div>
                </div>

                <div class="row mt-3">
                    <div class="col-sm-3">DC:</div>                  
                    <div class="col-sm-3" id="dDC"></div>
                    <div class="col-sm-3" id="dDCSubmit"></div>
                    <div class="col-sm-3" id="dDCTimeStamp"></div>
                </div>


            </div>
        </div>
    </div>
</div>
<!-- /Add Task Modal -->