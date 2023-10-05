var page = 1,
    limit = 10;
$(document).ready(function () {
    GetCustomerGroups();
    $('#btnSearch').click();
})


$('#btnSearch').click(function(){
    fetch();
})

function fetch(){
    $('#pagination').empty();
    $('#tblCustomers').empty();
    $.ajax({
        url:'customer/getlist',
        type:'get',
        data:{
            page,
            limit,
            group: $('#slCustomerGroups option:selected').val(),
            search: $('#txtSearch').val()
        },
        success:function(data){
            try {
                let content = $.parseJSON(data);
                console.log(content);
                let pages = content.data.pages;
                let customers = content.data.customers;
                for (i = 1; i <= pages; i++) {
                    if (i == page) {
                        $('#pagination').append(`<li class="page-item active" aria-current="page">
                                                <a class="page-link" href="#">${i}</a>
                                            </li>`);
                    } else {
                        $('#pagination').append(`<li class="page-item"><a class="page-link" href="#">${i}</a></li>`);
                    }
                }


                let idx = (page - 1) * limit;
                customers.forEach(c=>{
                    $('#tblCustomers').append(`
                        <tr id = "${c.id}">     
                            <td>${++idx}</td>                       
                            <td class="fw-bold text-info">${c.group_name}</td>
                            <td class="fw-bold">${c.fullname}</td>
                            <td class="">${c.acronym}</td>
                            <td>${c.email}</td>
                            <td>${c.company}</td>
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
                console.log(data,error);
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
