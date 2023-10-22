var page, limit;


$(document).ready(function () {
    LoadProjectStatuses();
    page = 1;
    limit = $('#slPageSize option:selected').val();
    $('#btnSearch').click();
    setInterval(fetch, 100000);// gọi hàm load lại dữ liệu sau mỗi 1p
})

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
                        <td>
                            ${isURL(p.product_url) ? `<a href="${p.product_url}" class="text-info" target="_blank"><i class="fa-solid fa-link"></i> Link</a>` : `-`}
                        </td>
                        <td class="text-center">
                      
                                    <span class="badge ${p.status_color}">${p.status_name}</span>
                        </td>                       
                        <td class="text-center">
                            <div class="dropdown action-label">
                                <a class="btn btn-outline-primary btn-sm dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-cog"></i>								</a>	
                                <div class="dropdown-menu dropdown-menu-right">
                                    <a class="dropdown-item" href="../tla/project/detail?id=${p.id}" ><i class="fa fa-eye text-info" aria-hidden="true"></i> Detail</a>
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



