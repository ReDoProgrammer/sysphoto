var page = 1;
var limit = 0;
var taskId = 0;
var roleId = 0;
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
                    LoadOwnTasks();
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
$('#btnSubmitTask').click(function () {
    let content = $('#txtContent').val();
    let read_instructions = $('#ckbReadInstruction').is(':checked') ? 1 : 0;
    // let qa = $('tbody#tblTasks').find(`tr#${taskId} td:eq(10)`).text();

    $.ajax({
        url: 'task/submit',
        type: 'post',
        data: {
            id: taskId,
            content,
            read_instructions,
            role: 5
        },
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
                    $("#task_submit_modal").modal('hide');
                    LoadOwnTasks();
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })
})
$('#btnSubmitRejectingTask').click(function () {
    let remark = CKEDITOR.instances['txaRejectRemark'].getData();
    let read_instructions = $('#ckbRejectReadInstructions').is(':checked') ? 1 : 0;

    $.ajax({
        url: 'task/reject',
        type: 'post',
        data: { id: taskId, remark, read_instructions },
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
                    $('#task_reject_modal').modal('hide');
                    LoadOwnTasks();
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })
})

$('#ckbReadInstruction').on('change', function () {
    $('#btnSubmitTask').prop('disabled', !this.checked);
});
$('#ckbRejectReadInstructions').on('change', function () {
    $('#btnSubmitRejectingTask').prop('disabled', !this.checked);
});

$("#task_submit_modal").on('shown.bs.modal', function () {
    $('#btnSubmitTask').prop('disabled', true);
    $('#ckbReadInstruction').prop('checked', false);
    $('#txtUrl').val('');
});

$("#task_submit_modal").on("hidden.bs.modal", function () {
    taskId = 0;
});

$("#task_reject_modal").on('shown.bs.modal', function () {
    $('#btnSubmitRejectingTask').prop('disabled', true);
    $('#ckbRejectReadInstructions').prop('checked', false);

    qTaskRejectingRemark.setText('');
});

$("#task_reject_modal").on("hidden.bs.modal", function () {
    taskId = 0;
    CKEDITOR.instances['txaRejectRemark'].setData('');
});


function ViewTaskDetail(id) {
    $.ajax({
        url: 'task/viewdetail',
        type: 'get',
        data: { id },
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                let t = content.task;

                $('#level').addClass(t.level_color);
                $('#level').text(t.level);

                $('#quantity').text(t.quantity);

                $('#status').addClass(t.status_color);
                $('#status').text(t.status ? t.status : '-');



                $('#start_date').html(`<span class="text-danger fw-bold">${(t.start_date.split(' ')[1])}</span> <br/>${(t.start_date.split(' ')[0])}`);
                $('#end_date').html(`<span class="text-danger fw-bold">${(t.end_date.split(' ')[1])}</span> <br/>${(t.end_date.split(' ')[0])}`);

                $('#divTaskDescription').empty();

                if (t.cc_id > 0) {
                    $('#divTaskDescription').append(`<span class="text-secondary fw-bold">CC description:</span>`);
                    $('#divTaskDescription').append(`<div class="mt-2" style="padding-left:20px;">${t.cc_content}</div>`)
                }

                $('#divTaskDescription').append(`<span class="text-secondary fw-bold">Task description:</span>`);
                $('#divTaskDescription').append(`<div class="mt-2" style="padding-left:20px;">${t.task_description}</div>`);

                let instructions = $.parseJSON(t.instructions_list);
                $('#divTaskDescription').append(`<span class="text-secondary fw-bold">Instructions:</span>`);
                instructions.forEach(i => {
                    $('#divTaskDescription').append(`<div class="mt-2" style="padding-left:20px;">${i.content}</div>`)
                })

                let styles = `
                    <div class="card mb-3 bg-light">
                        <div class="card-header bg-light fw-bold pt-3"> Customer styles</div>
                        <div class="card-body"><hr/>`;
                let s = $.parseJSON(t.styles);
                styles += `<div class="row">
                                        <div class="col-sm-4">Color mode: <span class="fw-bold">${s.color ? s.color : ''}</span></div>
                                        <div class="col-sm-4">Output: <span class="fw-bold">${s.output ? s.output : ''}</span></div>
                                        <div class="col-sm-4">Size: <span class="fw-bold">${s.size}</span></div>
                                    </div>
                                    <div class="row mt-3">
                                        <div class="col-sm-4">National style: <span class="fw-bold">${s.style ? s.style : ''}</span></div>
                                        <div class="col-sm-4">Cloud: <span class="fw-bold">${s.cloud ? s.cloud : ''}</span></div>
                                        <div class="col-sm-4">TV: <span class="fw-bold">${s.tv}</span></div>                        
                                    </div>
                                    <div class="row mt-3">                        
                                        <div class="col-sm-4">Sky: <span class="fw-bold">${s.sky}</span></div>
                                        <div class="col-sm-4">Fire: <span class="fw-bold">${s.fire}</span></div>
                                        <div class="col-sm-4">Grass: <span class="fw-bold">${s.grass}</span></div>
                                    </div>
                                    <div class="row mt-3">
                                        <div class="col-sm-12">Straighten: ${s.is_straighten == 1 ? '<i class="fa-regular fa-square-check"></i>' : '<i class="fa-regular fa-square"></i>'}
                                        <span class="fw-bold">${s.straighten_remark}</span></div>
                                    </div>
                                    `;

                styles += `</div>
                    </div>
                `;
                $('#divTaskDescription').append(styles);





                let logs = $.parseJSON(t.task_logs);
                $('#ulTaskLogs').empty();
                logs.forEach(l => {
                    $('#ulTaskLogs').append(`
                            <li class="mb-2">
                                <p class="mb-0">${l.content}</p>
                                <div>
                                    <span class="res-activity-time">
                                        <i class="fa-regular fa-clock"></i>
                                        ${l.timestamp}
                                    </span>
                                </div>
                            </li>
                        `);
                })
                $('#editor').text(t.editor ? t.editor : '-');
                $('#qa').text(t.qa ? t.qa : '-');
                $('#dc').text(t.dc ? t.dc : '-');
                $('#task_detail_modal').modal('show');
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}

function SubmitTask(id, role) {
    taskId = id;
    roleId = role;

    $('#SubmitingModalTitle').text(`Submiting task as ${role == 6 ? `Editor` : `QA`}`);
    if (role == 5) {
        $('#divSubmitTaskContent').hide();
    } else {
        $('#divSubmitTaskContent').show();
    }
    $('#txtContent').val('');
    $('#task_submit_modal').modal('show');

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
        url: 'task/fetch',
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
                console.log(content);
                let tasks = content.tasks;
                let idx = (page - 1) * limit;
                tasks.forEach(t => {
                    $('#tblTasks').append(`
                        <tr id="${t.id}">
                            <td>${++idx}</td>
                            <td class="text-center"> <span class="fw-bold">${t.project_name}</span> <br/> [${t.customer}]</td>                            
                            <td><span class="fw-bold ${t.level_color}">${t.level}</span> ${t.cc_id > 0 ? '<i class="fa-regular fa-closed-captioning text-danger"></i>' : ''}</td>
                            <td><span class="text-danger fw-bold">${(t.start_date.split(' '))[1]}</span> <br/>${(t.start_date.split(' '))[0]}</td>
                            <td><span class="text-danger fw-bold">${(t.end_date.split(' '))[1]}</span> <br/>${(t.end_date.split(' '))[0]}</td>
                            <td> <span class="text-danger fw-bold">
                                ${t.commencement_date ? `${(t.commencement_date.split(' '))[1]}</span> <br/>${(t.commencement_date.split(' '))[0]}` : ``}
                            </td>
                            <td class="text-center">${t.quantity}</td>
                            <td><span class="${t.status_color}">${t.status ? t.status : '-'}</span></td>
                            <td class="text-center">${t.editor ? t.editor : '-'}</td>
                            <td class="text-center">
                                ${(t.status_id != 0 && t.editor_url.trim().length > 0) ?
                            '<a href="' + t.editor_url + '" target="_blank"><i class="fa-solid fa-link text-info"></i></a>' :
                            ''}
                            </td>
                            <td class="text-center">${t.qa ? t.qa : ''}</td>
                            <td class="text-center">${t.dc ? t.dc : ''}</td>
                            <td class="text-end">
                            <div class="dropdown action-label">
                                <a class="btn btn-outline-primary btn-sm dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-cog"></i>								</a>	
                                <div class="dropdown-menu dropdown-menu-right">
                                    <a class="dropdown-item" href="javascript:void(0)" onClick="ViewTaskDetail(${t.id})"><i class="fa fa-eye" aria-hidden="true"></i> Detail</a>                                    
                                    ${(t.status_id == 1 || t.status_id == 3 || t.status_id == 5) ? `<a class="dropdown-item" href="javascript:void(0)" onClick="SubmitTask(${t.id},5)"><i class="fa-solid fa-cloud-arrow-up"></i>  Submit task</a>` : ``} 
                                    ${(t.status_id == 0) ? `<a class="dropdown-item" href="javascript:void(0)" onClick="SubmitTask(${t.id},6)"><i class="fa-solid fa-cloud-arrow-up"></i>  Submit task</a>` : ``} 
                                    ${(t.status_id == 1 || t.status_id == 3 || t.status_id == 5) ? `<a class="dropdown-item" href="javascript:void(0)" onClick="RejectTask(${t.id})"><i class="fa-regular fa-circle-xmark text-danger"></i> Reject</a> ` : ``}
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

function RejectTask(id) {
    taskId = id;
    $('#task_reject_modal').modal('show');
}


var $selectizeTaskStatuses = $('#slTaskStatuses');
$selectizeTaskStatuses.selectize({
    sortField: 'text', // Sắp xếp mục theo văn bản
    placeholder: 'Task Status'
});
var selectizeTaskStatus = $selectizeTaskStatuses[0].selectize;

CKEDITOR.replace('txaRejectRemark');

