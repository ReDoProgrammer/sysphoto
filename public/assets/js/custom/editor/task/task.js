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
                if(content.code == 200){
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
                            <td class="text-end"><button class="btn  btn-sm  btn-success btn-add-emp" onClick="SubmitTask(${t.id})">Submit</button></td>
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