$(document).ready(function(data){
    LoadData();
})

function LoadData(){
    $.ajax({
        url:'projectstatus/all',
        type:'get',
        success:function(data){
            let content = $.parseJSON(data);
            if(content.code == 200){
                let idx = 1;
                content.ps.forEach(s=>{
                    $('#tblProjectStatuses').append(`
                        <tr id = "${s.id}">
                            <td>${idx++}</td>
                            <td class="fw-bold ${s.color}">${s.name}</td>
                            <td class="text-info">${s.description}</td>
                            <td class="text-center">
                                ${s.visible==0?`<i class="fa-regular fa-square"></i>`:`<i class="fa-solid fa-square-check"></i>`}
                            </td>
                            <td><button class="btn btn-sm" onClick="UpdateStatus(${s.id})"><i class="fa-solid fa-pen-to-square text-danger"></i></button></td>
                        </tr>
                    `);
                })
            }
        }
    })
}