var page = 1,
    limit = 10,
    cId = 0;
$(document).ready(function () {
    GetCustomerGroups();
    $('#btnSearch').click();
})

$('#btnSubmitCustomer').click(function () {
    let group_id = $('#slMDCustomerGroups option:selected').val();
    let name = $('#txtCustomerName').val();
    let email = $('#txtCustomerEmail').val();
    let password = $('#txtCustomerPassword').val();
    let confirm_password = $('#txtConfirmCustomerPassword').val();
    let customer_url = $('#txtCustomerUrl').val();

    if ($.trim(name) === "") {
        $.toast({
            heading: `Customer name can not be null`,
            text: `Please enter customer name`,
            icon: 'warning',
            loader: true,        // Change it to false to disable loader
            loaderBg: '#9EC600'  // To change the background
        })
        return;
    }

    if (!isEmail(email)) {
        $.toast({
            heading: `Email is not valid`,
            text: `Please check email address`,
            icon: 'warning',
            loader: true,        // Change it to false to disable loader
            loaderBg: '#9EC600'  // To change the background
        })
        return;
    }

    if (password != confirm_password) {
        $.toast({
            heading: `Password not match`,
            text: `Please check password on twice inputs`,
            icon: 'warning',
            loader: true,        // Change it to false to disable loader
            loaderBg: '#9EC600'  // To change the background
        })
        return;
    }

    if (cId < 1) {
        //check mail is available
        // $.ajax({
        //     url: 'customer/checkmailexists',
        //     type: 'get',
        //     data: { email },
        //     success: function (data) {
        //         console.log(data);
        //         let content = $.parseJSON(data);
        //         if (content.code == 409) {
        //             $.toast({
        //                 heading: content.heading,
        //                 text: content.msg,
        //                 icon: content.icon,
        //                 loader: true,        // Change it to false to disable loader
        //                 loaderBg: '#9EC600'  // To change the background
        //             })
        //             return;
        //         }
        //     }
        // })

        $.ajax({
            url: 'customer/create',
            type: 'post',
            data: {
                group_id,
                name,
                email,
                password,
                customer_url
            },
            success: function (data) {
                try {
                    let content = $.parseJSON(data);
                    if (content.code == 201) {
                        $('#modal_customer').modal('hide');
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

    }
})


$('#btnSearch').click(function () {
    fetch();
})
$('#slPageSize').on('change', function () {
    limit = $(this).val();
    page = 1;
    fetch();
});


$(document).on("click", "#pagination li a.page-link", function (e) {
    e.preventDefault();
    $("#pagination li").removeClass("active");
    $(this).closest("li.page-item").addClass("active");
    page = $(this).text();
    fetch();
});

function fetch() {
    $('#pagination').empty();
    $('#tblCustomers').empty();
    $.ajax({
        url: 'customer/getlist',
        type: 'get',
        data: {
            page,
            limit,
            group: $('#slCustomerGroups option:selected').val(),
            search: $('#txtSearch').val()
        },
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                console.log(content);
                let pages = content.data.pages;
                let customers = content.data.customers;
                if (pages > 1) {
                    for (i = 1; i <= pages; i++) {
                        if (i == page) {
                            $('#pagination').append(`<li class="page-item active" aria-current="page">
                                                    <a class="page-link" href="#">${i}</a>
                                                </li>`);
                        } else {
                            $('#pagination').append(`<li class="page-item"><a class="page-link" href="#">${i}</a></li>`);
                        }
                    }
                }


                let idx = (page - 1) * limit;
                customers.forEach(c => {
                    $('#tblCustomers').append(`
                        <tr id = "${c.id}">     
                            <td>${++idx}</td>                       
                            <td class="fw-bold text-info">${c.group_name}</td>
                            <td class="fw-bold">${c.fullname}</td>
                            <td class="">${c.acronym}</td>
                            <td>${c.email}</td>
                            <td>${c.company ? c.company : ''}</td>
                            <td><a href="${c.url}" target="_blank">Link</a></td>
                            <td class="text-end">
                                <div class="dropdown action-label">
                                    <a class="btn btn-outline-primary btn-sm dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                    <i class="fas fa-cog"></i>								</a>	
                                    <div class="dropdown-menu dropdown-menu-right">
                                        <a class="dropdown-item" href="../admin/customer/detail?id=${c.id}" ><i class="fa fa-eye" aria-hidden="true"></i> Detail</a>
                                        <a class="dropdown-item" href="javascript:void(0)" onClick="UpdateCustomer(${c.id})"><i class="fas fa-pencil-alt"></i>  Update</a>
                                        <a class="dropdown-item" href="javascript:void(0)" onClick="DestroyCustomer(${c.id})"><i class="fas fa-trash-alt"></i>  Delete</a>
                                    </div> 
                                </div>
                            </td>
                        </tr>
                    `);
                })
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}

function GetCustomerGroups() {
    $.ajax({
        url: 'customergroup/list',
        'type': 'get',
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                content.groups.forEach(g => {
                    selectizeCustomerGroup.addOption({ value: `${g.id}`, text: `${g.name}` });
                    $('#slMDCustomerGroups').append(`<option value="${g.id}">${g.name}</option>`)
                })
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}



var $selectizeCustomerGroups = $('#slCustomerGroups');
$selectizeCustomerGroups.selectize({
    sortField: 'text' // Sắp xếp mục theo văn bản
});
var selectizeCustomerGroup = $selectizeCustomerGroups[0].selectize;
