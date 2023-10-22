var page, limit;
var pId = 0;


$(document).ready(function () {
    // LoadComboes();
    // LoadTemplates();
    //LoadCustomers();
    LoadProjectStatuses();
    page = 1;
    limit = $('#slPageSize option:selected').val();
    $('#btnSearch').click();
    setInterval(fetch, 100000);// gọi hàm load lại dữ liệu sau mỗi 1p
})

function SendProject(id) {
    Swal.fire({
        title: 'Do you want to send this project?',
        showDenyButton: true,
        showCancelButton: true,
        confirmButtonText: 'Submit',
        denyButtonText: `Cancel`,
    }).then((result) => {       
        if (result.isConfirmed) {
           
        } 
    })
}

function UploadProject(id) {
    pId = id;
    $('#project_submit_modal').modal('show');
}

function UpdateProject(id) {
    $.ajax({
        url: 'project/getdetail',
        type: 'get',
        data: { id },
        success: function (data) {
            ;
            try {
                let content = $.parseJSON(data);
                if (content.code == 200) {
                    pId = id;
                    $('#modal_project').modal('show');
                    let p = content.project;
                    console.log(p);
                    $('#txtProjectName').val(p.project_name);
                    $('#txtBeginDate').val(p.start_date);
                    $('#txtEndDate').val(p.end_date);
                    qDescription.setText(p.description ? p.description : '');
                    qInstruction.setText(p.instruction ? p.instruction : '');
                    selectizeCustomer.setValue(p.customer_id);
                    selectizeCombo.setValue(p.combo_id);
                    let templates = p.levels.split(',');
                    $("#slTemplates").select2("val", templates);
                    $('#ckbPriority').prop('checked', p.priority == 1);
                    $('#slStatuses').val(p.status_id);
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}

function DestroyProject(id) {
    Swal.fire({
        title: 'Are you sure want to delete this project?',
        text: "You won't be able to revert this!",
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!'
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url: 'project/delete',
                type: 'post',
                data: { id },
                success: function (data) {
                    try {
                        let content = $.parseJSON(data);
                        $.toast({
                            heading: content.heading,
                            text: content.msg,
                            icon: content.icon,
                            loader: true,        // Change it to false to disable loader
                            loaderBg: '#9EC600'  // To change the background
                        })
                        if (content.code == 200) {

                            $('#btnSearch').click();
                        }
                    } catch (error) {
                        console.log(data, error);
                    }
                }
            })
        }
    })
}

function AddNewTask(id) {
    pId = id;
    $('#task_modal').modal('show');
}

function AddNewInstruction(id) {
    pId = id;
    $('#modal_instruction').modal('show');
}

function AddNewCC(pId) {
    project_id = pId;
    $('#modal_cc').modal('show');
}
function LoadCustomers() {
    $.ajax({
        url: 'customer/all',
        type: 'get',
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                if (content.code == 200) {
                    content.customers.forEach(c => {
                        selectizeCustomer.addOption({ value: `${c.id}`, text: `${c.fullname}` });
                    })
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}

function LoadComboes() {
    $.ajax({
        url: 'combo/getlist',
        type: 'get',
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                if (content.code == 200) {
                    content.comboes.forEach(c => {
                        selectizeCombo.addOption({ value: `${c.id}`, text: `${c.name}` });
                    })
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}
function LoadTemplates() {
    $.ajax({
        url: 'level/getList',
        type: 'get',
        success: function (data) {
            let content = $.parseJSON(data);
            if (content.code == 200) {
                content.levels.forEach(l => {
                    $('#slTemplates').append(`<option value="${l.id}">${l.name}</option>`);
                })
            }
        }
    })
}

function LoadProjectStatuses() {
    $.ajax({
        url: 'projectstatus/all',
        type: 'get',
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                content.ps.forEach(p => {
                    $('#slProjectStatuses').append(`<option value="${p.id}">${p.name}</option>`);
                })
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}

function fetch() {
    let from_date = $('#txtFromDate').val();
    let to_date = $('#txtToDate').val();
    let stt = $('#slProjectStatuses').val() ? $.map($('#slProjectStatuses').val(), function (value) {
        return parseInt(value, 10); // Chuyển đổi thành số nguyên với cơ số 10
    }) : [];
    let search = $('#txtSearch').val();
    limit = $('#slPageSize option:selected').val();
    $('#tblProjects').empty();
    $('#pagination').empty();
    $.ajax({
        url: 'project/getList',
        type: 'get',
        data: {
            from_date,
            to_date,
            stt,
            search,
            page,
            limit
        },
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                if (content.code == 200) {

                    for (i = 1; i <= content.pages; i++) {
                        if (i == page) {
                            $('#pagination').append(`<li class="page-item active" aria-current="page">
                                                    <a class="page-link" href="#">${i}</a>
                                                </li>`);
                        } else {
                            $('#pagination').append(`<li class="page-item"><a class="page-link" href="#">${i}</a></li>`);
                        }
                    }


                    let idx = (page - 1) * limit;
                    content.projects.forEach(p => {
                        $('#tblProjects').append(`
                    <tr id="${p.id}">
                        <td>${++idx}</td>
                        <td class="fw-bold">${p.acronym}</td>
                        <td>${p.name}</td>
                        <td>${p.start_date}</td>
                        <td>${p.end_date}</td>
                        <td class="text-center">
                      
                                    <span class="badge ${p.status_color}">${p.status_name}</span>
                        </td>                       
                        <td class="text-center">
                            <div class="dropdown action-label">
                                <a class="btn btn-outline-primary btn-sm dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-cog"></i>								</a>	
                                <div class="dropdown-menu dropdown-menu-right">
                                    <a class="dropdown-item" href="../tla/project/detail?id=${p.id}" ><i class="fa fa-eye" aria-hidden="true"></i> Detail</a>
                                    ${p.status_id < 3 ?
                                `
                                    <a class="dropdown-item" href="javascript:void(0)" onClick="AddNewTask(${p.id})"><i class="fas fa-plus-circle"></i>  Add new task</a>
                                    <a class="dropdown-item" href="javascript:void(0)" onClick="AddNewCC(${p.id})"><i class="far fa-closed-captioning"></i>  Add new CC</a>
                                    <a class="dropdown-item" href="javascript:void(0)" onClick="AddNewInstruction(${p.id})"><i class="fa-regular fa-comment"></i>  Add new Instruction</a>
                                    <a class="dropdown-item" href="javascript:void(0)" onClick="UpdateProject(${p.id})"><i class="fas fa-pencil-alt"></i>  Update</a>
                                    ${p.status == 1 ? '<a class="dropdown-item" href="javascript:void(0)" onClick="DestroyProject(' + p.id + ')"><i class="fas fa-trash-alt"></i>  Destroy</a>' : ''}
                                    `:
                                `
                                <a class="dropdown-item" href="javascript:void(0)" onClick="UploadProject(${p.id})"><i class="fa-solid fa-cloud-arrow-up text-success"></i>  Submit</a>
                                <a class="dropdown-item" href="javascript:void(0)" onClick="SendProject(${p.id})"><i class="fa-solid fa-paper-plane text-primary"></i>  Send</a>
                                `
                            }
                                    
                                    
                                </div> 
                            </div>
                        </td>
                    </tr>
                `);
                    })
                }
            } catch (error) {
                console.log(data, error);
            }


        },
        error: function (jqXHR, textStatus, errorThrown) {
            console.error("Lỗi AJAX:", textStatus, errorThrown);
            console.log("Mã lỗi HTTP:", jqXHR.status);
        }
    })
}

$('#btnSubmitUploadProject').click(function () {
    let url = $('#txtUrl').val();
    if (!isURL(url)) {
        $.toast({
            heading: `Project Url is invalid`,
            text: `Please check project url again`,
            icon: 'warning',
            loader: true,        // Change it to false to disable loader
            loaderBg: '#9EC600'  // To change the background
        })
        return;
    }

    $.ajax({
        url: 'project/upload',
        type: 'post',
        data: { id: pId, url },
        success: function (data) {
            try {
                content = $.parseJSON(data);
                if (content.code == 200) {
                    $('#project_submit_modal').modal('hide');
                }
                $.toast({
                    heading: content.heading,
                    text: content.msg,
                    icon: content.icon,
                    loader: true,        // Change it to false to disable loader
                    loaderBg: '#9EC600'  // To change the background
                })
            } catch (error) {
                console.log(data, error);
            }
        }
    })
})


$('#btnSubmitNewInstruction').click(function () {
    let instruction = qNewDescription.getText();
    if (instruction.trim().length == 0) {
        $.toast({
            heading: `Instruction can not be null`,
            text: `Please enter instruction content`,
            icon: 'warning',
            loader: true,        // Change it to false to disable loader
            loaderBg: '#9EC600'  // To change the background
        })
        return;
    }

    $.ajax({
        url: 'project/addinstruction',
        type: 'post',
        data: {
            id: pId,
            instruction
        },
        success: function (data) {
            try {
                content = $.parseJSON(data);
                if (content.code == 201) {
                    $('#modal_instruction').modal('hide');
                }
                $.toast({
                    heading: content.heading,
                    text: content.msg,
                    icon: content.icon,
                    loader: true,        // Change it to false to disable loader
                    loaderBg: '#9EC600'  // To change the background
                })
            } catch (error) {
                console.log(data, error);
            }
        }
    })
})
$('#btnSubmitJob').click(function () {
    let customer = $('#slCustomers option:selected').val();
    let name = $('#txtProjectName').val();
    let start_date = $('#txtBeginDate').val() + ":00";
    let end_date = $('#txtEndDate').val() + ":00";
    let combo = $('#slComboes option:selected').val();
    let templates = $('#slTemplates').val() ? $.map($('#slTemplates').val(), function (value) {
        return parseInt(value, 10); // Chuyển đổi thành số nguyên với cơ số 10
    }) : [];
    let priority = $('#ckbPriority').is(':checked') ? 1 : 0;
    let description = qDescription.getText();
    let instruction = qInstruction.getText();


    // validate inputs
    if ($.trim(customer) === "") {
        $.toast({
            heading: `Customer can not be null`,
            text: `Please choose a customer from list`,
            icon: 'warning',
            loader: true,        // Change it to false to disable loader
            loaderBg: '#9EC600'  // To change the background
        })
        return;
    }
    if ($.trim(name) === "") {
        $.toast({
            heading: `Project name can not be null`,
            text: `Please enter project name`,
            icon: 'warning',
            loader: true,        // Change it to false to disable loader
            loaderBg: '#9EC600'  // To change the background
        })
        return;
    }

    let sd = strToDateTime($('#txtBeginDate').val());
    let td = strToDateTime($('#txtEndDate').val());
    if (td < sd) {
        $.toast({
            heading: `End date can not be less than start date!`,
            text: `Please choose another value`,
            icon: 'warning',
            loader: true,        // Change it to false to disable loader
            loaderBg: '#9EC600'  // To change the background
        })
        return;
    }
    // end validating inputs



    if (pId < 1) {
        $.ajax({
            url: 'project/create',
            type: 'post',
            data: {
                customer, name, start_date, end_date,
                combo, templates, priority,
                description, instruction
            },
            success: function (data) {
                try {
                    content = $.parseJSON(data);
                    if (content.code == 201) {
                        $('#modal_project').modal('hide');
                        $('#btnSearch').click();
                    }
                    $.toast({
                        heading: content.heading,
                        text: content.msg,
                        icon: content.icon,
                        loader: true,        // Change it to false to disable loader
                        loaderBg: '#9EC600'  // To change the background
                    })
                } catch (error) {
                    console.log(data, error);
                }
            }
        })
    } else {
        $.ajax({
            url: 'project/update',
            type: 'post',
            data: {
                id: pId,
                customer, name, start_date, end_date,
                combo, templates, priority,
                description, instruction
            },
            success: function (data) {
                try {
                    content = $.parseJSON(data);
                    console.log(content);
                    $.toast({
                        heading: content.heading,
                        text: content.msg,
                        icon: content.icon,
                        loader: true,        // Change it to false to disable loader
                        loaderBg: '#9EC600'  // To change the background
                    })

                    $('#modal_project').modal('hide');
                    $('#btnSearch').click();

                } catch (error) {
                    console.log(data, error);
                }
            }
        })
    }
})

$(document).on("click", "#pagination li a.page-link", function (e) {
    e.preventDefault();
    $("#pagination li").removeClass("active");
    $(this).closest("li.page-item").addClass("active");
    page = $(this).text();
    fetch();
});

$('#btnSubmitCC').click(function () {
    let start_date = $('#txtCCBeginDate').val() + ":00";
    let end_date = $('#txtCCEndDate').val() + ":00";
    let feedback = qCCDescription.getText();

    let sd = strToDateTime($('#txtBeginDate').val());
    let td = strToDateTime($('#txtEndDate').val());
    if (td < sd) {
        $.toast({
            heading: `End date can not be less than start date!`,
            text: `Please choose another value`,
            icon: 'warning',
            loader: true,        // Change it to false to disable loader
            loaderBg: '#9EC600'  // To change the background
        })
        return;
    }


    if (ccId < 1) {
        $.ajax({
            url: 'cc/insert',
            type: 'post',
            data: {
                project_id,
                feedback,
                start_date, end_date
            },
            success: function (data) {
                try {
                    let content = $.parseJSON(data);
                    if (content.code == 201) {
                        $('#modal_cc').modal('hide');
                    }
                    $.toast({
                        heading: content.heading,
                        text: content.msg,
                        icon: content.icon,
                        loader: true,        // Change it to false to disable loader
                        loaderBg: '#9EC600'  // To change the background
                    })
                } catch (error) {
                    console.log(data, error);
                }
            }
        })
    }

})


$("#modal_project").on('shown.bs.modal', function (e) {
    if (pId < 1) {
        $('#slStatuses').attr("disabled", true);
        $('#modal_project_title').text('Create a new project');
        $('#btnSubmitJob').text('Submit creating');
    } else {
        $('#slStatuses').removeAttr('disabled');
        $('#modal_project_title').text('Update project');
        $('#btnSubmitJob').text('Save changes');
    }
});

$("#modal_project").on("hidden.bs.modal", function () {
    pId = 0;
    qDescription.setText('');
    qInstruction.setText('');
});
$("#modal_instruction").on("hidden.bs.modal", function () {
    pId = 0;
    qNewDescription.setText('');
});



$('#txtDuration').keyup(function () {
    if ($(this).val().length != 0) {
        let sd = strToDateTime($('#txtBeginDate').val());
        let durationHours = parseInt($(this).val()); // Chuyển đổi giá trị nhập thành số nguyên

        if (!isNaN(durationHours)) { // Kiểm tra nếu giá trị nhập là một số
            let td = new Date(sd); // Tạo một bản sao của ngày bắt đầu
            td.setHours(sd.getHours() + durationHours); // Thêm giờ vào ngày bắt đầu
            $('#txtEndDate').val(moment(td).format('DD/MM/YYYY HH:mm'));
        } else {
            console.log("Giá trị nhập không phải là số.");
        }
    }
})


$('#btnSearch').click(function (e) {
    e.preventDefault();
    fetch();
})
$('#slPageSize').on('change', function () {
    limit = $(this).val();
    page = 1;
    fetch();
});




var qDescription = new Quill('#divDescription', {
    theme: 'snow', // Chọn giao diện "snow"
    modules: {
        toolbar: [
            ['bold', 'italic', 'underline'],
            [{ 'list': 'ordered' }, { 'list': 'bullet' }],
            ['link'], // Thêm nút chèn liên kết
            [{ 'color': ['#F00', '#0F0', '#00F', '#000', '#FFF', 'color-picker'] }], // Thêm nút chọn màu
        ]
    },
    placeholder: "Enter project's description here...",
    // Đặt chiều cao cho trình soạn thảo
    // Ví dụ: Chiều cao 300px
    height: '300px'
    // Hoặc chiều cao 5 dòng
    // height: '10em'
});
var qInstruction = new Quill('#divInstruction', {
    theme: 'snow', // Chọn giao diện "snow"
    modules: {
        toolbar: [
            ['bold', 'italic', 'underline'],
            [{ 'list': 'ordered' }, { 'list': 'bullet' }],
            ['link'], // Thêm nút chèn liên kết
            [{ 'color': ['#F00', '#0F0', '#00F', '#000', '#FFF', 'color-picker'] }], // Thêm nút chọn màu
        ]
    },
    placeholder: "Enter intruction for Editor here...",
});

var $selectizeCustomers = $('#slCustomers');
$selectizeCustomers.selectize({
    sortField: 'text' // Sắp xếp mục theo văn bản
});
var selectizeCustomer = $selectizeCustomers[0].selectize;

var $selectizeComboes = $('#slComboes');
$selectizeComboes.selectize({
    sortField: 'text' // Sắp xếp mục theo văn bản
});
var selectizeCombo = $selectizeComboes[0].selectize;



var ccId = 0;
var project_id = 0;

var qCCDescription = new Quill('#divCCDescription', {
    theme: 'snow', // Chọn giao diện "snow"
    modules: {
        toolbar: [
            ['bold', 'italic', 'underline'],
            [{ 'list': 'ordered' }, { 'list': 'bullet' }],
            ['link'], // Thêm nút chèn liên kết
            [{ 'color': ['#F00', '#0F0', '#00F', '#000', '#FFF', 'color-picker'] }], // Thêm nút chọn màu
        ]
    },
    placeholder: "Enter CC description here...",
    // Đặt chiều cao cho trình soạn thảo
    // Ví dụ: Chiều cao 300px
    height: '300px'
    // Hoặc chiều cao 5 dòng
    // height: '10em'
});


var qNewDescription = new Quill('#divNewInstruction', {
    theme: 'snow', // Chọn giao diện "snow"
    modules: {
        toolbar: [
            ['bold', 'italic', 'underline'],
            [{ 'list': 'ordered' }, { 'list': 'bullet' }],
            ['link'], // Thêm nút chèn liên kết
            [{ 'color': ['#F00', '#0F0', '#00F', '#000', '#FFF', 'color-picker'] }], // Thêm nút chọn màu
        ]
    },
    placeholder: "Enter Instruction here...",
    // Đặt chiều cao cho trình soạn thảo
    // Ví dụ: Chiều cao 300px
    height: '300px'
    // Hoặc chiều cao 5 dòng
    // height: '10em'
});