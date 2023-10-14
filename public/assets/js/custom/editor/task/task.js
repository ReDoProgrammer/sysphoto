var page = 1;
var limit = 0;
$(document).ready(function () {
    LoadOwnTasks();
    LoadTaskStatuses();
})
$('#btnGetTask').click(function () {
    $.ajax({
        url: 'task/gettask',
        type: 'get',
        success: function (data) {

            try {
                let content = $.parseJSON(data);
                $.toast({
                    heading: content.heading,
                    text: content.msg,
                    showHideTransition: 'fade',
                    icon: content.icon
                })
                if (content.code == 200) {
                    fetch();
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })
})

$('#btnSearch').click(function (e) {
    e.preventDefault();
    LoadOwnTasks();
})
function ViewTaskDetail(id){
    $.ajax({
        url:'task/viewdetail',
        type:'get',
        data:{id},
        success:function(data){
            try {
                let content = $.parseJSON(data);
                console.log(content);
                $('#divCC').hide();
                let t = content.task;
                $('#level').addClass(t.level_color);
                $('#level').text(t.level);

                $('#quantity').text(t.quantity);

                $('#status').addClass(t.status_color);
                $('#status').text(t.status);
                
                $('#pDescription').html(t.description);

                let instructions = $.parseJSON(t.instructions_list);
                $('#divInstructions').empty();
                instructions.forEach(i=>{
                    $('#divInstructions').append(`<p class="mt-2" style="padding-left:20px;">${i.content}</p> <hr>`)
                })
                if(t.cc_id>0){
                    $('#divCC').show();
                    $('#divCC').empty();
                    $('#divCC').append('<card-header class="text-secondary">CC description</card-header>');
                    $('#divCC').append(`<div class="card-body">${t.feeback}</div>`)
                }
                $('#editor').text(t.editor?t.editor:'-');
                $('#qa').text(t.qa?t.qa:'-');
                $('#dc').text(t.dc?t.dc:'-');

                $('#task_modal').modal('show');
            } catch (error) {
                console.log(data,error);
            }
        }
    })
}

function SubmitTask(id){
    console.log(id);
}

function LoadTaskStatuses() {
    $.ajax({
        url: 'taskstatus/all',
        type: 'get',
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                if (content.code == 200) {
                    content.taskstatuses.forEach(t => {
                        selectizeTaskStatus.addOption({ value: `${t.id}`, text: `${t.name}` });
                    })
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}
function LoadOwnTasks() {
    let from_date = $('#txtFromDate').val();
    let to_date = $('#txtToDate').val();
    let status = selectizeTaskStatus.getValue() ? selectizeTaskStatus.getValue() : 0;
    let limit = $('#slPageSize option:selected').val();

    $('#tblTasks').empty();

    $.ajax({
        url: 'task/fectch',
        type: 'get',
        data: {
            from_date,
            to_date,
            status,
            page,
            limit
        },
        success: function (data) {
            try {
                let content = JSON.parse(data);
                let tasks = content.tasks;
                let idx = (page - 1) * limit;
                tasks.forEach(t => {
                    $('#tblTasks').append(`
                        <tr id="${t.id}">
                            <td>${++idx}</td>
                            <td class="text-center"> <span class="fw-bold">${t.project_name}</span> <br/> [${t.customer}]</td>                            
                            <td>${t.cc_id > 0 ? '<i class="fa-regular fa-closed-captioning text-danger"></i>' : ''}<span class="fw-bold ${t.level_color}">${t.level}</span></td>
                            <td><span class="text-danger fw-bold">${(t.start_date.split(' '))[1]}</span> <br/>${(t.start_date.split(' '))[0]}</td>
                            <td><span class="text-danger fw-bold">${(t.end_date.split(' '))[1]}</span> <br/>${(t.end_date.split(' '))[0]}</td>
                            <td class="text-center">${t.quantity}</td>
                            <td><span class="${t.status_color}">${t.status}</span></td>
                            <td class="text-center">${t.editor ? t.editor : '-'}</td>
                            <td class="text-center">${t.qa ? t.qa : '-'}</td>
                            <td class="text-center">${t.dc ? t.dc : '-'}</td>
                            <td class="text-center">${t.pay == 1 ? '<i class="fa-regular fa-square-check"></i>' : '<i class="fa-regular fa-square"></i>'}</td>
                            <td class="text-end">
                            <div class="dropdown action-label">
                                <a class="btn btn-outline-primary btn-sm dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-cog"></i>								</a>	
                                <div class="dropdown-menu dropdown-menu-right">
                                    <a class="dropdown-item" href="javascript:void(0)" onClick="ViewTaskDetail(${t.id})"><i class="fa fa-eye" aria-hidden="true"></i> Detail</a>                                    
                                    ${(t.id == 0 || t.id ==2 || t.id == 5)?'<a class="dropdown-item" href="javascript:void(0)" onClick="SubmitTask('+t.id+')"><i class="fa-solid fa-cloud-arrow-up"></i>  Submit task</a>':''}
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


var $selectizeTaskStatuses = $('#slTaskStatuses');
$selectizeTaskStatuses.selectize({
    sortField: 'text', // Sắp xếp mục theo văn bản
    placeholder: 'Task Status'
});
var selectizeTaskStatus = $selectizeTaskStatuses[0].selectize;