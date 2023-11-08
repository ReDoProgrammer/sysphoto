<!-- Add Or Update Customer Modal -->
<div id="modal_customer" class="modal custom-modal fade" role="dialog">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="CustomerModalTitle">Add New Customer</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-sm-3 col-xs-6">
                        <div class="input-block mb-3">
                            <label class="col-form-label">Customer group</label>
                            <select id="slMDCustomerGroups" class="form-control"></select>
                        </div>
                    </div>
                    <div class="col-sm-3 col-xs-6">
                        <div class="input-block mb-3">
                            <label class="col-form-label">Customer name (<span
                                    class="text-danger fw-bold">*</span>)</label>
                            <input class="form-control" type="text" id="txtCustomerName">
                        </div>
                    </div>
                    <div class="col-sm-3 col-xs-6">
                        <div class="input-block mb-3">
                            <label class="col-form-label">Acronym (<span
                                    class="text-danger fw-bold">*</span>)</label>
                            <input class="form-control" type="text" id="txtAcronym">
                        </div>
                    </div>
                    <div class="col-sm-3 col-xs-6">
                        <div class="input-block mb-3">
                            <label class="col-form-label">Email (<span class="text-danger fw-bold">*</span>)</label>
                            <input class="form-control" type="text" id="txtCustomerEmail">
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-sm-4 col-xs-12">
                        <div class="input-block mb-3">
                            <label class="col-form-label">Password (<span class="text-danger fw-bold">*</span>)</label>
                            <input class="form-control" type="password" id="txtCustomerPassword">
                        </div>
                    </div>
                    <div class="col-sm-4 col-xs-12">
                        <div class="input-block mb-3">
                            <label class="col-form-label">Confirm Password (<span
                                    class="text-danger fw-bold">*</span>)</label>
                            <input class="form-control" type="password" id="txtConfirmCustomerPassword">
                        </div>
                    </div>
                    <div class="col-sm-4 col-xs-12">
                        <div class="input-block mb-3">
                            <label class="col-form-label">Url (<span class="text-danger fw-bold">*</span>)</label>
                            <input class="form-control" type="text" id="txtCustomerUrl">
                        </div>
                    </div>
                </div>

                <div class="card mt-4">
                    <div class="card-header">
                        <h4 class="fw-bold">Customer style</h4>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-sm-3">
                                <div class="input-block mb-3">
                                    <div class="input-block mb-3">
                                        <label class="col-form-label">Color mode</label>
                                        <select id="slColorModes"></select>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-3">
                                <div class="input-block mb-3">
                                    <div class="input-block mb-3">
                                        <label class="col-form-label">Output</label>
                                        <select id="slOutputs"></select>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-3">
                                <div class="input-block mb-3">
                                    <div class="input-block mb-3">
                                        <label class="col-form-label">Size</label>
                                        <input class="form-control" type="text" id="txtSize">
                                    </div>
                                </div>
                            </div>

                            <div class="col-sm-3">
                                <div class="input-block mb-3">
                                <div class="checkbox">
                                            <label class="col-form-label">
                                                <input type="checkbox" name="checkbox" id="ckbStraighten"> Straighten
                                            </label>
                                        </div>
                                    <input class="form-control" type="text" id="txtStraighten">
                                </div>
                            </div>
                        </div>


                        <div class="row">
                            <div class="col-sm-4">
                                <div class="input-block mb-3">
                                    <div class="input-block mb-3">
                                        <div class="checkbox">
                                            <label class="col-form-label">
                                                <input type="checkbox" name="checkbox" id="ckbTV"> TV
                                            </label>
                                        </div>
                                        <input class="form-control" type="text" id="txtTV">
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="input-block mb-3">
                                    <div class="input-block mb-3">
                                        <div class="checkbox">
                                            <label class="col-form-label">
                                                <input type="checkbox" name="checkbox" id="ckbFire"> Fire
                                            </label>
                                        </div>
                                        <input class="form-control" type="text" id="txtFire">
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="input-block mb-3">
                                    <div class="input-block mb-3">
                                        <div class="checkbox">
                                            <label class="col-form-label">
                                                <input type="checkbox" name="checkbox" id="ckbSky"> Sky
                                            </label>
                                        </div>
                                        <input class="form-control" type="text" id="txtSky">
                                    </div>
                                </div>
                            </div>

                        </div>

                        <div class="row">
                            <div class="col-sm-4">
                                <div class="input-block mb-3">
                                    <div class="input-block mb-3">
                                        <div class="checkbox">
                                            <label class="col-form-label">
                                                <input type="checkbox" name="checkbox" id="ckbGrass"> Grass
                                            </label>
                                        </div>
                                        <input class="form-control" type="text" id="txtGrass">
                                    </div>
                                </div>
                            </div>

                            <div class="col-sm-4">
                                <div class="input-block mb-3">
                                    <label class="col-form-label">National Style</label>
                                    <select id="slNationalStyles"></select>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="input-block mb-3">
                                    <label class="col-form-label">Cloud</label>
                                    <select id="slClouds"></select>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-sm-12">
                                <div class="input-block mb-3">
                                    <label class="col-form-label">Style remark</label>
                                    <div id="divStyleRemark" style="min-height: 100px;"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>





                <div class="submit-section">
                    <button class="btn btn-sm btn-primary cancel-btn" data-bs-dismiss="modal"
                        aria-label="Close">Cancel</button>
                    <button class="btn btn-primary submit-btn" id="btnSubmitCustomer">Submit</button>
                </div>


            </div>
        </div>
    </div>
</div>
<!-- /Add Or Update Customer Modal -->