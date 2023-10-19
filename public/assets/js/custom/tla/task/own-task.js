$(document).ready(function(){
    LoadTaskStatuses();
    LoadOwnTasks();
})
$('#btnSearch').click(function (e) {
    e.preventDefault();
    LoadOwnTasks();
})

function LoadTaskStatuses() {
    $.ajax({
        url: '../taskstatus/all',
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
                            <td><span class="text-danger fw-bold">${(t.commencement_date.split(' '))[1]}</span> <br/>${(t.commencement_date.split(' '))[0]}</td>
                            <td class="text-center">${t.quantity}</td>
                            <td><span class="${t.status_color}">${t.status ? t.status : '-'}</span></td>
                            <td class="text-center">${t.editor ? t.editor : '-'}</td>
                            <td class="text-center">
                                ${(t.status_id != 0 && t.editor_url.trim().length > 0) ?
                            '<a href="' + t.editor_url + '" target="_blank"><i class="fa-solid fa-link text-info"></i></a>' :
                            '-'}
                            </td>
                            <td class="text-center">${t.qa ? t.qa : '-'}</td>
                            <td class="text-center">${t.dc ? t.dc : '-'}</td>
                            <td class="text-end">
                            <div class="dropdown action-label">
                                <a class="btn btn-outline-primary btn-sm dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-cog"></i>								</a>	
                                <div class="dropdown-menu dropdown-menu-right">
                                    <a class="dropdown-item" href="javascript:void(0)" onClick="ViewTaskDetail(${t.id})"><i class="fa fa-eye" aria-hidden="true"></i> Detail</a>                                    
                                    ${(t.status_id == 1 || t.status_id == 3) ? `<a class="dropdown-item" href="javascript:void(0)" onClick="SubmitTask(${t.id},5)"><i class="fa-solid fa-cloud-arrow-up"></i>  Submit task</a>` : ``} 
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

var $selectizeTaskStatuses = $('#slTaskStatuses');
$selectizeTaskStatuses.selectize({
    sortField: 'text', // Sắp xếp mục theo văn bản
    placeholder: 'Task Status'
});