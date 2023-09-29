var page;
$(document).ready(function () {
    LoadJobStatus();

    LoadComboes();
    LoadTemplates();
    LoadCustomers();


    page = 1;
    $('#btnSearch').click();
})

$('#btnSubmitJob').click(function () {
    let customer = $('#slCustomers option:selected').val();
    let name = $('#txtProjectName').val();
    let start_date = $('#txtBeginDate').val();
    let duration = $('#txtDuration').val();
    let end_date = $('#txtEndDate').val();
    let combo = $('#slComboes option:selected').val();
    let templates = $('#slTemplates').val() ? $.map($('#slTemplates').val(), function (value) {
        return parseInt(value, 10); // Chuyển đổi thành số nguyên với cơ số 10
    }) : [];

    let urgent = $('#ckbPriority').is(':checked');
    let description = $('#divDescription').html();
    let intruction = $('#txaIntruction').val();


    console.log({description});

    // console.log({ customer, name, start_date, duration, end_date, combo, templates, urgent, intruction });


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
    var $selectizeInput = $('#slCustomers');
    $selectizeInput.selectize({
        sortField: 'text' // Sắp xếp mục theo văn bản
    });
    var selectize = $selectizeInput[0].selectize;

    $.ajax({
        url: 'customer/getlist',
        type: 'get',
        success: function (data) {
            let content = $.parseJSON(data);
            if (content.code == 200) {
                content.customers.forEach(c => {
                    selectize.addOption({ value: `${c.id}`, text: `${c.name_ct}` });
                })
            }
        }
    })
}

function LoadComboes() {
    var $selectizeInput = $('#slComboes');
    $selectizeInput.selectize({
        sortField: 'text' // Sắp xếp mục theo văn bản
    });
    var selectize = $selectizeInput[0].selectize;
    $.ajax({
        url: 'combo/getlist',
        type: 'get',
        success: function (data) {
            let content = $.parseJSON(data);
            if (content.code == 200) {
                content.comboes.forEach(c => {
                    selectize.addOption({ value: `${c.id}`, text: `${c.ten_combo}` });
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
    let limit = $('#slPageSize option:selected').val();
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
                                    <a class="dropdown-item" href="javascript:void(0)"><i class="fa fa-eye" aria-hidden="true"></i> Detail</a>
                                    <a class="dropdown-item" href="javascript:void(0)"><i class="fas fa-plus-circle"></i>  Add a task</a>
                                    <a class="dropdown-item" href="javascript:void(0)"><i class="far fa-closed-captioning"></i>  Add a CC</a>
                                    <a class="dropdown-item" href="javascript:void(0)"><i class="fas fa-pencil-alt"></i>  Update</a>
                                    <a class="dropdown-item" href="javascript:void(0)"><i class="fas fa-trash-alt"></i>  Destroy</a>
                                    
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
                $('#slJobStatus').append(`<option value="${s.id}">${s.stt_job_name.toUpperCase()}</option>`);
            })
        }
    })
}
















