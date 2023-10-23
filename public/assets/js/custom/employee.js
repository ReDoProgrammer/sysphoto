var page = 1, empId = 0, limit = 10;

$(document).ready(function(){
    LoadEmployeeGroups();
    FetchEmployees();
})

$('#btnLogin').click(function () {
    let email = $('#txtEmail').val();
    let password = $('#txtPassword').val();
    if (!isEmail(email)) {
        $.toast({
            heading: 'Error',
            text: 'Email address is not valid!',
            showHideTransition: 'fade',
            icon: 'error'
        })
        return;
    }
    if (password.trim().length == 0) {
        $.toast({
            heading: 'Error',
            text: 'Password can not be empty!',
            showHideTransition: 'fade',
            icon: 'error'
        })
        return;
    }


    $.ajax({
        url: 'auth/authLogin',
        type: 'post',
        data: { email, password },
        success: function (data) {
            try {
                let auth = $.parseJSON(data);
                console.log(auth);
                if (auth.code == 200) {
                    $(location).prop('href', 'dashboard')
                } else {
                    Swal.fire(
                        'OPP..!',
                        auth.msg,
                        'error'
                    )
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })

})

$('#btnSearch').click(function(){
    FetchEmployees();
})

function LoadEmployeeGroups(){
    $('#slEmployeeGroups').empty();
    $.ajax({
        url:'employeegroup/List',
        type:'get',
        success:function(data){
            try {
                let content = $.parseJSON(data);
                console.log(content);
                content.groups.forEach(g=>{
                    selectizeEmployeeGroup.addOption({ value: `${g.id}`, text: `${g.name}` });
                })
            } catch (error) {
                console.log(data,error);
            }
        }
    })
}

function FetchEmployees(){
    let group = $('#slEmployeeGroups option:selected').val();
    let search = $('#txtSearch').val();
    
    $.ajax({
        url:'employee/filter',
        type:'get',
        data:{group,search,page,limit},
        success:function(data){
            console.log(data);
        }
    })

}

var $selectizeEmployeeGroups = $('#slEmployeeGroups');
$selectizeEmployeeGroups.selectize({
    sortField: 'text' // Sắp xếp mục theo văn bản
});
var selectizeEmployeeGroup = $selectizeEmployeeGroups[0].selectize;