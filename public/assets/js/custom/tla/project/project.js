var page, limit;
var pId = 0;


$(document).ready(function () {
    LoadProjectStatuses();
    page = 1;
    limit = $('#slPageSize option:selected').val();
    $('#btnSearch').click();
    setInterval(fetch, 100000);// gọi hàm load lại dữ liệu sau mỗi 1p
})


function UploadProject(id) {
    pId = id;
    $('#project_submit_modal').modal('show');
}


function AddNewTask(id) {
    pId = id;
    $('#task_modal').modal('show');
}

function ApplyTemplates(id){
    $.ajax({
        url:'project/ApplyTemplates',
        type:'post',
        data:{id},
        success:function(data){
            
           try {
            let content = $.parseJSON(data);
             if(content.code == 200){
                $.toast({
                    heading: content.heading,
                    text: content.msg,
                    icon: content.icon,
                    loader: true,        // Change it to false to disable loader
                    loaderBg: '#9EC600'  // To change the background
                })
                fetch();
             }
           } catch (error) {
                console.log(data,error);
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
                        <td class="fw-bold text-info">${p.templates}</td>
                        <td class="text-center">
                            <span class="badge ${p.status_color?p.status_color:'text-info'}">${p.status_name?p.status_name:'Initial'}</span>
                        </td>                       
                        <td class="text-center">
                            <div class="dropdown action-label">
                                <a class="btn btn-outline-primary btn-sm dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-cog"></i></a>	
                                <div class="dropdown-menu dropdown-menu-right">
                                    <a class="dropdown-item" href="../tla/project/detail?id=${p.id}" ><i class="fa fa-eye text-info" aria-hidden="true"></i> Detail</a>
                                    ${p.gen_number > 0 ?``
                                    :`<a class="dropdown-item" href="javascript:void(0)" onClick="ApplyTemplates(${p.id})"><i class="fa-solid fa-hammer text-success"></i> Apply templates</a>`}
                                   
                                    ${p.status_id < 3 ?
                                `<a class="dropdown-item" href="javascript:void(0)" onClick="AddNewTask(${p.id})"><i class="fas fa-plus-circle text-primary"></i>  Add new task</a>`:
                                `
                                ${p.status_id == 3 ? `
                                <a class="dropdown-item" href="javascript:void(0)" onClick="UploadProject(${p.id})"><i class="fa-solid fa-cloud-arrow-up text-success"></i>  Submit</a>
                                `: ``}
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




$(document).on("click", "#pagination li a.page-link", function (e) {
    e.preventDefault();
    $("#pagination li").removeClass("active");
    $(this).closest("li.page-item").addClass("active");
    page = $(this).text();
    fetch();
});


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