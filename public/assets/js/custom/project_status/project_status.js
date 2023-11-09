$(document).ready(function () {
    LoadData();
})

var sttId = 0;

$('#btnSubmit').click(function () {
    let name = $('#txtName').val().trim();
    let color = $('#txtColor').val().trim();
    let description = $('#txaDescription').val().trim();
    let visible = $('#switch_visible').is(':checked')?1:0;



    if (name.length == 0) {
        ShowWarningMsg("Please enter status name", "Invalid name");
    }
    createOrUpdateStatus(sttId, name, color, description, visible);

})

function UpdateStatus(id){
    sttId = id;
    $.ajax({
        url:'projectstatus/detail',
        type:'get',
        data:{id},
        success:function(data){
            let content = $.parseJSON(data);
            if(content.code == 200){
                $('#modal_status').modal('show');
                let stt = content.stt;
                $('#txtName').val(stt.name);
                $('#txtColor').val(stt.color);
                $('#txaDescription').val(stt.description);
                $('#switch_visible').prop("checked",stt.visible==1)
            }
        }
    })
}

function DeleteStatus(id){
    Swal.fire({
        title: "Are you sure you want to delete this status?",
        text: "You won't be able to revert this!",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
        confirmButtonText: "Yes, delete it!"
      }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url:'projectstatus/delete',
                type:'post',
                data:{id},
                success:function(data){
                    let content = $.parseJSON(data);
                    if(content.code == 200){
                        LoadData();
                        $.toast({
                            heading: content.heading,
                            text: content.msg,
                            icon: content.icon,
                            loader: true,
                            loaderBg: '#9EC600'
                        });
                    }
                }
            })
        }
      });
}

function ShowWarningMsg(text = "", title = "") {
    Swal.fire({
        icon: "error",
        title: title,
        text: text
    });
    return;
}

async function createOrUpdateStatus(id, name, color, description, visible) {
    try {
        const url = id < 1 ? 'projectstatus/add' : 'projectstatus/edit';
        const data = { id, name, color, description, visible };
        const response = await $.ajax({
            url: url,
            type: 'post',
            data: data
        });
        const content = $.parseJSON(response);
        if (content.code === (id < 1 ? 201 : 200)) {
            handleResponse(content);
        }
    } catch (error) {
        console.log(error);
    }
}
function handleResponse(content) {
    if (content.code === (sttId < 1 ? 201 : 200)) {
        $('#modal_status').modal('hide');
        LoadData();
    }

    $.toast({
        heading: content.heading,
        text: content.msg,
        icon: content.icon,
        loader: true,
        loaderBg: '#9EC600'
    });
}


function LoadData() {
    $('#tblProjectStatuses').empty();
    $.ajax({
        url: 'projectstatus/all',
        type: 'get',
        success: function (data) {
            let content = $.parseJSON(data);
            if (content.code == 200) {
                let idx = 1;
                content.ps.forEach(s => {
                    $('#tblProjectStatuses').append(`
                        <tr id = "${s.id}">
                            <td>${idx++}</td>
                            <td class="fw-bold ${s.color}">${s.name}</td>
                            <td class="text-info">${s.description}</td>
                            <td class="text-center">
                                ${s.visible == 0 ? `<i class="fa-regular fa-square"></i>` : `<i class="fa-solid fa-square-check"></i>`}
                            </td>
                            <td class="text-end">
                                <button class="btn btn-sm" onClick="UpdateStatus(${s.id})"><i class="fa-solid fa-pen-to-square text-warning"></i></button>
                                <button class="btn btn-sm" onClick="DeleteStatus(${s.id})"><i class="far fa-trash-alt text-danger"></i></button>
                            </td>
                        </tr>
                    `);
                })
            }
        }
    })
}


$("#modal_status").on("hidden.bs.modal", function () {
    sttId = 0;
    $('#txtName').val('');
    $('#txtColor').val('');
    $('#txaDescription').val('');
    $('#switch_visible').prop("checked",false)
})