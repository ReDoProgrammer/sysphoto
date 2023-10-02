var page, limit;
var pId = 0;


$(document).ready(function () {
    LoadJobStatus();
    LoadComboes();
    LoadTemplates();
    LoadCustomers();
    page = 1;
    limit = $('#slPageSize option:selected').val();
    $('#btnSearch').click();
    setInterval(fetch, 10000);// gọi hàm load lại dữ liệu sau mỗi 10s
})

function UpdateProject(id) {
    $.ajax({
        url: 'project/getdetail',
        type: 'get',
        data: { id },
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                if (content.code == 200) {
                    pId = id;
                    $('#modal_project').modal('show');
                    let p = content.project;
                    $('#txtProjectName').val(p.name);
                    $('#txtBeginDate').val(convertDateTime(p.start_date));
                    $('#txtEndDate').val(convertDateTime(p.end_date));
                    qDescription.setText(p.description);
                    qInstruction.setText(p.instruction);
                    selectizeCustomer.setValue(p.idkh);
                    selectizeCombo.setValue(p.idcb);
                    let templates = p.idlevels.split(',');
                    $("#slTemplates").select2("val", templates);
                    $('#ckbPriority').prop('checked', p.urgent == 1);
                    $('#slStatuses').val(p.status);
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}

function DestroyProject(id) {

}

function AddNewTask(id) {
    pId = id;
    $('#task_modal').modal('show');
}

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

$('#btnSubmitJob').click(function () {
    let customer = $('#slCustomers option:selected').val();
    let name = $('#txtProjectName').val();
    let start_date = $('#txtBeginDate').val();
    let end_date = $('#txtEndDate').val();
    let status = $('#slStatuses option:selected').val();
    let combo = $('#slComboes option:selected').val();
    let templates = $('#slTemplates').val() ? $.map($('#slTemplates').val(), function (value) {
        return parseInt(value, 10); // Chuyển đổi thành số nguyên với cơ số 10
    }) : [];
    let urgent = $('#ckbPriority').is(':checked')?1:0;
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
                customer, name, start_date, end_date, status,
                combo, templates, urgent,
                description, instruction
            },
            success: function (data) {
                content = $.parseJSON(data);
                if (content.code == 201) {
                    $.toast({
                        heading: content.heading,
                        text: content.msg,
                        icon: 'success',
                        loader: true,        // Change it to false to disable loader
                        loaderBg: '#9EC600'  // To change the background
                    })
                    $('#modal_project').modal('hide');
                    $('#btnSearch').click();
                }
            }
        })
    } else {
        $.ajax({
            url: 'project/update',
            type: 'post',
            data: {
                id: pId,
                customer, name, start_date, end_date, status,
                combo, templates, urgent,
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
                    console.log(data,error);
                }
            }
        })
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

function LoadCustomers() {
    $.ajax({
        url: 'customer/getlist',
        type: 'get',
        success: function (data) {
            let content = $.parseJSON(data);
            if (content.code == 200) {
                content.customers.forEach(c => {
                    selectizeCustomer.addOption({ value: `${c.id}`, text: `${c.name_ct}` });
                })
            }
        }
    })
}

function LoadComboes() {
    $.ajax({
        url: 'combo/getlist',
        type: 'get',
        success: function (data) {
            let content = $.parseJSON(data);
            if (content.code == 200) {
                content.comboes.forEach(c => {
                    selectizeCombo.addOption({ value: `${c.id}`, text: `${c.ten_combo}` });
                })
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

$(document).on("click", "#pagination li a.page-link", function (e) {
    e.preventDefault();
    $("#pagination li").removeClass("active");
    $(this).closest("li.page-item").addClass("active");
    page = $(this).text();
    fetch();
});

function fetch() {
    let from_date = $('#txtFromDate').val();
    let to_date = $('#txtToDate').val();
    let stt = $('#slJobStatus').val() ? $.map($('#slJobStatus').val(), function (value) {
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
                        <td class="fw-bold">${p.name_ct_mh}</td>
                        <td>${p.name}</td>
                        <td>${p.start_date}</td>
                        <td>${p.end_date}</td>
                        <td class="text-center">
                      
                                    <span class="badge ${p.color_sttj}">${p.stt_job_name}</span>
                        </td>                       
                        <td class="text-center">
                            <div class="dropdown action-label">
                                <a class="btn btn-outline-primary btn-sm dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-cog"></i>								</a>	
                                <div class="dropdown-menu dropdown-menu-right">
                                    <a class="dropdown-item" href="../admin/project/detail?id=${p.id}" ><i class="fa fa-eye" aria-hidden="true"></i> Detail</a>
                                    <a class="dropdown-item" href="javascript:void(0)" onClick="AddNewTask(${p.id})"><i class="fas fa-plus-circle"></i>  Add new task</a>
                                    <a class="dropdown-item" href="javascript:void(0)" onClick="AddNewCC(${p.id})"><i class="far fa-closed-captioning"></i>  Add new CC</a>
                                    <a class="dropdown-item" href="javascript:void(0)" onClick="UpdateProject(${p.id})"><i class="fas fa-pencil-alt"></i>  Update</a>
                                    <a class="dropdown-item" href="javascript:void(0)" onClick="DestroyProject(${p.id})"><i class="fas fa-trash-alt"></i>  Destroy</a>
                                    
                                </div> 
                            </div>
                        </td>
                    </tr>
                `);
                })
            }


        },
        error: function (jqXHR, textStatus, errorThrown) {
            console.error("Lỗi AJAX:", textStatus, errorThrown);
            console.log("Mã lỗi HTTP:", jqXHR.status);
        }
    })
}

function LoadJobStatus() {
    $.ajax({
        url: 'JobStatus/list',
        type: 'get',
        success: function (data) {
            var stt = $.parseJSON(data);
            stt.forEach(s => {
                $('#slStatuses').append(`<option value="${s.id}">${s.stt_job_name.toUpperCase()}</option>`);
                $('#slJobStatus').append(`<option value="${s.id}">${s.stt_job_name.toUpperCase()}</option>`);
            })
        }
    })
}

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
















