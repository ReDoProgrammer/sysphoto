var page, limit, pId = 0;


$(document).ready(function () {
    LoadProjectStatuses();
    LoadComboes();
    LoadCustomers();
    LoadTemplates();
    page = 1;
    limit = $('#slPageSize option:selected').val();
    $('#btnSearch').click();
    setInterval(fetch, 100000);// gọi hàm load lại dữ liệu sau mỗi 1p
})
function CheckName(id, name) {
    return new Promise((resolve, reject) => {
        $.ajax({
            url: 'project/checkname',
            type: 'get',
            data: { id, name },
            success: function (data) {
                return resolve(data);
            },
            error: function (jqXHR, exception) {
                return reject(jqXHR);
            }
        })
    })
}
function SendProject(id) {
    Swal.fire({
        title: 'Do you want to send this project?',
        showCancelButton: true,
        confirmButtonText: 'Yes, send it!!'
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url: 'project/send',
                type: 'post',
                data: { id },
                success: function (data) {
                    try {
                        content = $.parseJSON(data);
                        $.toast({
                            heading: content.heading,
                            text: content.msg,
                            icon: content.icon,
                            loader: true,        // Change it to false to disable loader
                            loaderBg: '#9EC600'  // To change the background
                        })
                        fetch();
                    } catch (error) {
                        console.log(data, error);
                    }
                }
            })
        }
    })
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
                    CKEDITOR.instances['txaDescription'].setData(p.description);
                    CKEDITOR.instances['txaInstruction'].setData(p.instruction);
                    selectizeCustomer.setValue(p.customer_id);
                    selectizeCombo.setValue(p.combo_id);
                    selectizeStatus.setValue(p.status_id);
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
    CKEDITOR.instances['txaNewInstruction'].setData('');
    $('#modal_instruction').modal('show');
}

function AddNewCC(pId) {
    project_id = pId;
    CKEDITOR.instances['txaCCDescription'].setData('');
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
                    selectizeStatus.addOption({ value: p.id, text: `${p.name} - ${p.description}` })
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
                        <td>
                            <span class="text-info fw-bold">${p.name}</span><br/>
                            <span>[${p.acronym}]</span>
                        </td>
                        <td>
                            <span>${p.start_date.split(' ')[1]}</span><br/>
                            ${p.start_date.split(' ')[0]}
                        </td>
                        <td>
                            <span class="text-danger fw-bold">${p.end_date.split(' ')[1]}</span><br/>
                            ${p.end_date.split(' ')[0]}
                        </td>
                        <td class="text-end">${p.task_count}</td>
                        <td>
                            ${isURL(p.product_url) ? `<a href="${p.product_url}" class="text-info" target="_blank"><i class="fa-solid fa-link"></i> Link</a>` : `-`}
                        </td>
                        <td class="text-center">                      
                            <span class="badge ${p.status_color ? p.status_color : 'text-info fw-bold'}">${p.status_name ? p.status_name : 'Initial'}</span>
                        </td>                       
                        <td class="text-center">
                            <div class="dropdown action-label">
                                <a class="btn btn-outline-primary btn-sm dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-cog"></i>								</a>	
                                <div class="dropdown-menu dropdown-menu-right">
                                    <a class="dropdown-item" href="../css/project/detail?id=${p.id}" ><i class="fa fa-eye text-info" aria-hidden="true"></i> Detail</a>
                                    <a class="dropdown-item" href="javascript:void(0)" onClick="AddNewCC(${p.id})"><i class="far fa-closed-captioning text-danger"></i>  Add new CC</a>
                                    <a class="dropdown-item" href="javascript:void(0)" onClick="AddNewInstruction(${p.id})"><i class="fa-regular fa-comment text-info"></i>  Add new Instruction</a>
                                    <a class="dropdown-item" href="javascript:void(0)" onClick="UpdateProject(${p.id})"><i class="fas fa-pencil-alt text-warning"></i>  Update</a>
                                    ${p.task_count == 0 ? '<a class="dropdown-item" href="javascript:void(0)" onClick="DestroyProject(' + p.id + ')"><i class="fas fa-trash-alt text-danger"></i>  Destroy</a>' : ''}
                                    ${p.status_id == 4 ? `<a class="dropdown-item" href="javascript:void(0)" onClick="SendProject(${p.id})"><i class="fa-solid fa-paper-plane text-success"></i>  Send</a>` : ``}        
                                    
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

async function createOrUpdateProject(id, customer, name, start_date, end_date, status,
    combo, templates, priority, description, instruction) {
    try {

        const url = id < 1 ? 'project/create' : 'project/update';
        const data = {
            id, customer, name, start_date, end_date, status,
            combo, templates, priority, description, instruction
        };

        const response = await $.ajax({
            url: url,
            type: 'post',
            data: data
        });

        const content = $.parseJSON(response);
        if (content.code === (pId < 1 ? 201 : 200)) {
            handleResponse(content);
        }
    } catch (error) {
        console.log(error);
    }
}
function handleResponse(content) {
    if (content.code === (pId < 1 ? 201 : 200)) {
        $('#modal_project').modal('hide');
        $('#btnSearch').click();
    }

    $.toast({
        heading: content.heading,
        text: content.msg,
        icon: content.icon,
        loader: true,
        loaderBg: '#9EC600'
    });
}


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
    let status = 0;
    if (selectizeStatus.items && selectizeStatus.items.length > 0) {
        status = parseInt(selectizeStatus.items[0]);
    }
    let description = CKEDITOR.instances['txaDescription'].getData();
    let instruction = CKEDITOR.instances['txaInstruction'].getData();


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

    CheckName(pId, name)
        .then(rs => {
            let content = $.parseJSON(rs);
            if (content.code == 409) {
                Swal.fire({
                    title: `${pId < 1 ? "Are you sure you want to create project with this name?" : "Are you sure you want to update project with this name?"}`,
                    text: content.msg,
                    icon: "warning",
                    showCancelButton: true,
                    confirmButtonColor: "#3085d6",
                    cancelButtonColor: "#d33",
                    confirmButtonText: "Yes, do it!"
                }).then((result) => {
                    if (result.isConfirmed) {
                        createOrUpdateProject(pId, customer, name, start_date, end_date, status,
                            combo, templates, priority, description, instruction);
                    }

                });
            } else {
                createOrUpdateProject(pId, customer, name, start_date, end_date, status,
                    combo, templates, priority, description, instruction);
            }
        })
        .catch(err => {
            console.log(err);
        })

})
$('#btnSubmitNewInstruction').click(function () {
    let instruction = CKEDITOR.instances['txaNewInstruction'].getData();
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
$('#btnSubmitCC').click(function () {
    let start_date = $('#txtCCBeginDate').val() + ":00";
    let end_date = $('#txtCCEndDate').val() + ":00";
    let feedback = CKEDITOR.instances['txaCCDescription'].getData();

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


})
$(document).on("click", "#pagination li a.page-link", function (e) {
    e.preventDefault();
    $("#pagination li").removeClass("active");
    $(this).closest("li.page-item").addClass("active");
    page = $(this).text();
    fetch();
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


var $selectizeStatuses = $('#slStatuses');
$selectizeStatuses.selectize({
    sortField: 'text' // Sắp xếp mục theo văn bản
});
var selectizeStatus = $selectizeStatuses[0].selectize;




var ccId = 0;
var project_id = 0;



CKEDITOR.replace('txaDescription');
CKEDITOR.replace('txaInstruction');
CKEDITOR.replace('txaNewInstruction');
CKEDITOR.replace('txaCCDescription');