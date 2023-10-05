<!-- Add Or Update Customer Modal -->
<div id="modal_customer" class="modal custom-modal fade" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="taskModalTitle">Add New Customer</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <div class="input-block mb-3">
                    <label class="col-form-label">Customer group</label>
                    <select id="slMDCustomerGroups" class="form-control"></select>
                </div>

                <div class="input-block mb-3">
                    <label class="col-form-label">Customer name (<span class="text-danger fw-bold">*</span>)</label>
                    <input class="form-control" type="text" id="txtCustomerName">
                </div>

                <div class="input-block mb-3">
                    <label class="col-form-label">Email (<span class="text-danger fw-bold">*</span>)</label>
                    <input class="form-control" type="text" id="txtCustomerEmail">
                </div>

                <div class="input-block mb-3">
                    <label class="col-form-label">Password (<span class="text-danger fw-bold">*</span>)</label>
                    <input class="form-control" type="password" id="txtCustomerPassword">
                </div>
                <div class="input-block mb-3">
                    <label class="col-form-label">Confirm Password (<span class="text-danger fw-bold">*</span>)</label>
                    <input class="form-control" type="password" id="txtConfirmCustomerPassword">
                </div>

                <div class="input-block mb-3">
                    <label class="col-form-label">Url (<span class="text-danger fw-bold">*</span>)</label>
                    <input class="form-control" type="text" id="txtCustomerUrl">
                </div>                       


                <div class="submit-section">
                    <button class="btn btn-primary cancel-btn" data-bs-dismiss="modal"
                        aria-label="Close">Cancel</button>
                    <button class="btn btn-primary submit-btn" id="btnSubmitCustomer">Submit</button>
                </div>


            </div>
        </div>
    </div>
</div>
<!-- /Add Or Update Customer Modal -->

