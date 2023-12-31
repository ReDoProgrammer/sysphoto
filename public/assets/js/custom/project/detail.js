var taskId = 0;
var ccId = 0;

$(document).ready(function () {
    // Lấy URL hiện tại
    var currentUrl = window.location.href;
    // Sử dụng regex để tìm giá trị của tham số "id"
    var match = currentUrl.match(/[?&]id=([^&]*)/);

    // Kiểm tra xem tham số có tồn tại không
    if (match) {
        var id = decodeURIComponent(match[1]);
        GetProjectDetail(id);
        GetLogs(id);
        GetCCs(id);
    }

})



function AddCCTask(id) {
    ccId = id;
    $("#task_modal").modal('show');
}
function DeleteCC(id) {
    Swal.fire({
        title: 'Are you sure want to delete this task?',
        text: "When this CC is deleted, its associated tasks will also be deleted. \n You won't be able to revert this!",
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!'
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url: '../cc/delete',
                type: 'post',
                data: { id },
                success: function (data) {
                    try {
                        let content = $.parseJSON(data);
                        if (content.code == 200) {
                            $.toast({
                                heading: content.heading,
                                text: content.msg,
                                icon: content.icon,
                                loader: true,        // Change it to false to disable loader
                                loaderBg: '#9EC600'  // To change the background
                            })
                            GetProjectDetail();
                            GetLogs();
                            GetCCs();
                        }
                    } catch (error) {
                        console.log(data, error);
                    }
                }
            })
        }
    })
}
function GetLogs(id) {
    $('#ulProjectLogs').empty();

    $.ajax({
        url: '../projectlog/list',
        type: 'get',
        data: { projectId: id },
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                let logs = content.logs;
                logs.forEach(l => {
                    $('#ulProjectLogs').append(`
                            <li id="${l.id}">
                                <p class="mb-0">${l.action}</p>
                                <div>
                                    <span class="res-activity-time">
                                        <i class="fa-regular fa-clock"></i>
                                        ${l.timestamp}
                                    </span>
                                </div>
                            </li>
                        `);
                })
            } catch (error) {
                console.log(data, error);
            }
        }
    })

}
function GetProjectDetail(id) {
    $('#tblTasksList').empty();

    // Kiểm tra xem tham số "id" có tồn tại hay không

    $.ajax({
        url: '../project/getdetail',
        type: 'get',
        data: { id },
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                console.log(content);
                let descriptions = content.descriptions;
                descriptions.forEach(d => {
                    $('#DescriptionAndInstructions').append(d.content);
                    $('#DescriptionAndInstructions').append('<hr/>');
                })



                if (content.code == 200) {
                    let idx = 1;
                    let p = content.project;
                    $('#project_name').text(p.project_name);

                    const result = $.map(content.stats, function (item) {
                        return `${item.count} ${item.status} ${item.count > 1 ? `tasks` : `task`}`
                    }).join(', ');

                    $('#ProjectTasksAndStatus').empty();
                    $('#ProjectTasksAndStatus').append(result);



                    $('#tdStartDate').text(p.start_date);
                    $('#tdEndDate').text(p.end_date);
                    $('#tdPriority').html(`${p.priority == 1 ? '<i class="fa fa-dot-circle-o text-danger">URGEN</i>' : '<i class="fa fa-dot-circle-o">NORMAL</i>'}`);
                    $('#tdCombo').html(`<i class="fa fa-dot-circle-o ${p.combo_color}">${p.combo ? p.combo : ''}</i>`);
                    $('#tdStatus').html(`<i class="fa fa-dot-circle-o ${p.status_color}">${p.status}</i>`);
                    let tasks = $.parseJSON(p.tasks_list);
                    tasks.forEach(t => {
                        $('#tblTasksList').append(`
                                                        <tr id = "${t.id}">
                                                            <td>${idx++}</td>
                                                            <td><span class="text-info">${t.cc_id > 0 ? '<i class="fa-regular fa-closed-captioning text-danger" style="margin-right:5px;"></i>' : ""}${t.level}</span></td>
                                                            <td class="text-center">${t.quantity}</td>
                                                            <td>${t.editor ? t.editor : '-'}</td>
                                                            <td>${t.qa ? t.qa : '-'}</td>
                                                            <td>${t.dc ? t.dc : '-'}</td>
                                                            <td class="text-center"><span class="${t.status_color ? t.status_color : ''}">${t.status ? t.status : 'Init'}</span></td>
                                                            <td>
                                                                <div class="dropdown action-label">
                                                                    <a class="btn btn-outline-primary btn-sm dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                                                    <i class="fas fa-cog"></i>								</a>	
                                                                    <div class="dropdown-menu dropdown-menu-right">
                                                                        <a class="dropdown-item" href="javascript:void(0)" onClick="viewTask(${t.id})"><i class="fa fa-eye" aria-hidden="true"></i> View</a>
                                                                        <a class="dropdown-item" href="javascript:void(0)" onClick="editTask(${t.id})"><i class="fas fa-pencil-alt"></i>  Update</a>
                                                                        ${t.status_id == 0 ? '<a class="dropdown-item" href="javascript:void(0)" onClick="deleteTask(' + t.id + ')"><i class="fas fa-trash-alt"></i>  Delete</a>' : ''}
                                                                        
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
        }
    })

}
function GetCCs(id) {
   
        $.ajax({
            url: '../cc/getccs',
            type: 'get',
            data: {
                project_id: id
            },
            success: function (data) {
                try {
                    let content = $.parseJSON(data);
                    $('#accordionFeedbacksAndCCs').empty();
                    content.ccs.forEach(c => {
                        let tasks_list = $.parseJSON(c.tasks_list);
                        let item = `
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <div class="row">
                                    <div class="col-sm-3">
                                        <button class="btn btn-secondary btn-sm mt-2" onClick="DeleteCC(${c.c_id})">
                                            <i class="fa-solid fa-trash text-danger"></i> 
                                            Delete CC
                                        </button>
                                    </div>
                                    <div class="col-sm-9 text-end">
                                        <button class="accordion-button collapsed float-right" type="button" data-bs-toggle="collapse"
                                            data-bs-target="#collapse${c.c_id}" aria-expanded="true" aria-controls="collapseOne1">
                                            <i class="fa-regular fa-clock text-warning" style="margin-right:20px;"></i>  ${c.start_date} - ${c.end_date} - [${tasks_list.length} tasks]
                                        </button>
                                    </div>
                                </div>
                            </h2>
                            <div id="collapse${c.c_id}" class="accordion-collapse collapse" data-bs-parent="#accordionExample">
                                <div class="accordion-body">
                                    <p>${c.feedback}</p>
                                    <div class="submit-section text-end mb-3">
                                        <button class="btn btn-sm btn-success" onClick="AddCCTask(${c.c_id})" id="btnAddCCTask">
                                        <i class="fa-solid fa-plus"></i> Add New Task
                                        </button>
                                    </div>
                                    <table class="table table-hover mb-0">
                                        <thead>
                                            <tr>
                                                <th>#</th>
                                                <th>Level</th>
                                                <th>Q.ty</th>
                                                <th>Editor</th>
                                                <th>Q.A</th>
                                                <th>DC</th>
                                                <th>Status</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tblCCTasksList">`;

                        let idx = 1;
                        tasks_list.forEach(t => {
                            item += `<tr id="${t.task_id}">
                                                        <td>${idx++}</td>
                                                        <td><span class="${t.level_color}">${t.level}</span></td>
                                                        <td>${t.quantity}</td>
                                                        <td>${t.editor ? t.editor : '-'}</td>
                                                        <td>${t.qa ? t.qa : '-'}</td>
                                                        <td>${t.dc ? t.dc : '-'}</td>
                                                        <td><span class="${t.status_color}">${t.status ? t.status : '-'}</span></td>
                                                        <td>
                                                            <div class="dropdown action-label">
                                                                <a class="btn btn-outline-primary btn-sm dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                                                <i class="fas fa-cog"></i>								</a>	
                                                                <div class="dropdown-menu dropdown-menu-right">
                                                                    <a class="dropdown-item" href="javascript:void(0)" onClick="viewTask(${t.task_id})"><i class="fa fa-eye" aria-hidden="true"></i> View</a>
                                                                    <a class="dropdown-item" href="javascript:void(0)" onClick="editTask(${t.task_id})"><i class="fas fa-pencil-alt"></i>  Update</a>
                                                                    ${t.status_id == 0 ? '<a class="dropdown-item" href="javascript:void(0)" onClick="deleteTask(' + t.task_id + ')"><i class="fas fa-trash-alt"></i>  Delete</a>' : ''}
                                                                    
                                                                </div> 
                                                            </div>
                                                        </td>
                                                    </td>`;
                        });
                        item += ` </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        `
                        $('#accordionFeedbacksAndCCs').append(item);
                    })
                } catch (error) {
                    console.log(data, error);
                }
            }
        })
    
}

