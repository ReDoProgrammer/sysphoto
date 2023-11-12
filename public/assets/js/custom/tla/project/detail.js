var taskId = 0;
var ccId = 0;
var prjId = 0;

$(document).ready(function () {
    // Lấy URL hiện tại
    var currentUrl = window.location.href;
    // Sử dụng regex để tìm giá trị của tham số "id"
    var match = currentUrl.match(/[?&]id=([^&]*)/);

    // Kiểm tra xem tham số có tồn tại không
    if (match) {
        prjId = decodeURIComponent(match[1]);
        GetProjectDetail(prjId);
        GetLogs(prjId);
        GetCCs(prjId);
        getTaskLevels();
        LoadTaskStatuses();
    }

})



function AddCCTask(id) {
    ccId = id;
    $("#task_modal").modal('show');
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
                                    <div class="col-sm-12 text-end">                                   
                                        <button class="accordion-button collapsed float-right" type="button" data-bs-toggle="collapse"
                                            data-bs-target="#collapse${c.c_id}" aria-expanded="true" aria-controls="collapseOne1">
                                            <i class="fa-regular fa-clock text-info" style="margin-right:20px;"></i>  ${c.start_date} - ${c.end_date} - [${tasks_list.length} tasks]
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
function viewTask(id) {
    $.ajax({
        url: '../task/ViewDetail',
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
                        styles+=    `<div class="row">
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
                        
                    styles+=     `</div>
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
function deleteTask(id) {
    Swal.fire({
        title: 'Are you sure want to delete this task?',
        text: "You won't be able to revert this!",
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!'
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url: '../task/delete',
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
                            GetProjectDetail(prjId);
                            GetLogs(prjId);
                            GetCCs(prjId);
                        }
                    } catch (error) {
                        console.log(data, error);
                    }
                }
            })
        }
    })
}
function editTask(id) {
    $.ajax({
        url: '../task/viewdetail',
        type: 'get',
        data: { id },
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                if (content.code == 200) {
                    let t = content.task;
                    
                    CKEDITOR.instances['txaTaskDescription'].setData(t.task_description);
                    $('#slLevels').val(t.level_id);
                    LoadEditorsByLevel(t.level_id, t.editor_id);
                    LoadQAsByLevel(t.level_id, t.qa_id);
                    $('#txtQuantity').val(t.quantity)
                }
                taskId = id;
                $('#task_modal').modal('show');
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}

function getTaskLevels() {
    $('#slLevels').append(` <option value="" disabled selected>Please choose a task level</option>`);
    $.ajax({
        url: '../level/getList',
        type: 'get',
        success: function (data) {
            try {
                let content = $.parseJSON(data);

                if (content.code == 200) {
                    content.levels.forEach(lv => {
                        $('#slLevels').append(`<option value="${lv.id}">${lv.name}</option>`)
                    })
                    $('#slLevels').selectedIndex(-1);
                }
            } catch (error) {

            }
        }
    })
}

function LoadTaskStatuses() {
    $.ajax({
        url: '../taskstatus/all',
        type: 'get',
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                if (content.code == 200) {
                    // content.statuses.forEach(t => {
                    //     // selectizeTaskStatus.addOption({ value: `${t.id}`, text: `${t.name}` });
                    //     // if (t.id != 7) {
                    //     //     $('#slRejectIntoStatus').append(`<option value="${t.id}">${t.name}</option>`);
                    //     // }
                    // })
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}
function LoadEditorsByLevel(level, selected = null) {

    selectizeEditor.clearOptions();
    $.ajax({
        url: '../employee/getEditors',
        type: 'get',
        data: { level },
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                if (content.code == 200) {

                    content.editors.forEach(e => {
                        selectizeEditor.addOption({ value: `${e.id}`, text: `${e.acronym}` });
                    })

                    if (selected != null) {
                        selectizeEditor.setValue(selected);
                    }
                }
            } catch (error) {

            }
        }
    })
}

function LoadQAsByLevel(level, selected = null) {
    var selectizeQA = selectizeQAs[0].selectize;
    selectizeQA.clearOptions();
    $.ajax({
        url: '../employee/getQAs',
        type: 'get',
        data: { level },
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                if (content.code == 200) {
                    content.qas.forEach(e => {
                        selectizeQA.addOption({ value: `${e.id}`, text: `${e.acronym}` });
                    })

                    if (selected != null) {
                        selectizeQA.setValue(selected);
                    }
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}

async function createOrUpdateTask(id, prjId, description, level, cc, editor, qa, quantity) {
    try {

        const url = id < 1 ? '../task/create' : '../task/update';
        const data = {id, prjId, description, level, cc, editor, qa, quantity};

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
    if (content.code === (taskId < 1 ? 201 : 200)) {
        $('#task_modal').modal('hide');
        GetProjectDetail(prjId);
        GetLogs(prjId);
        GetCCs(prjId);
    }

    $.toast({
        heading: content.heading,
        text: content.msg,
        icon: content.icon,
        loader: true,
        loaderBg: '#9EC600'
    });
}




$('#btnSubmitTask').click(function () {
    var currentUrl = window.location.href;
    // Sử dụng regex để tìm giá trị của tham số "id"
    var match = currentUrl.match(/[?&]id=([^&]*)/);

    // Kiểm tra xem tham số có tồn tại không
    if (match) {
        var prjId = decodeURIComponent(match[1]);
        let description = CKEDITOR.instances['txaTaskDescription'].getData();
        let level = $('#slLevels option:selected').val();
        let editor = 0;
        if (selectizeEditor.items && selectizeEditor.items.length > 0) {
            editor = parseInt(selectizeEditor.items[0]);
        }
        let qa = 0;
        if (selectizeQA.items && selectizeQA.items.length > 0) {
            qa = parseInt(selectizeQA.items[0]);
        }
        let quantity = $('#txtQuantity').val();

        // validation
        if (!level) {
            $.toast({
                heading: `Task level can not be null`,
                text: `Please chose one level`,
                icon: 'warning',
                loader: true,        // Change it to false to disable loader
                loaderBg: '#9EC600'  // To change the background
            })
            return;
        }

        if (quantity.trim().length == 0) {
            $.toast({
                heading: `Quantity is not valid`,
                text: `Please enter a number`,
                icon: 'warning',
                loader: true,        // Change it to false to disable loader
                loaderBg: '#9EC600'  // To change the background
            })
            return;
        }

        if (parseInt(quantity) < 1) {
            $.toast({
                heading: `Quantity is not valid`,
                text: `Quantity must be larger than 0`,
                icon: 'warning',
                loader: true,        // Change it to false to disable loader
                loaderBg: '#9EC600'  // To change the background
            })
            return;
        }

        //end validation

        createOrUpdateTask(taskId, prjId, description, level, ccId, editor, qa, quantity);
    }

})

$("#task_modal").on('shown.bs.modal', function (e) {
    if (taskId < 1) {
        $('#taskModalTitle').text("Add new task");
        $('#btnSubmitTask').text('Submit creating');
    } else {
        $('#taskModalTitle').text("Update task");
        $('#btnSubmitTask').text('Save changes');
    }
});
$("#task_modal").on("hidden.bs.modal", function () {
    taskId = 0;
    ccId = 0;
    var currentUrl = window.location.href;
    // Sử dụng regex để tìm giá trị của tham số "id"
    var match = currentUrl.match(/[?&]id=([^&]*)/);
    if (match) {
        var id = decodeURIComponent(match[1]);
        GetCCs(id);
        GetLogs(id);
    }
});

$('#slLevels').on('change', function () {
    LoadEditorsByLevel($(this).val());
    LoadQAsByLevel($(this).val());
})

$('#slEditors').on('change', function () {
    var selectedValue = $(this).val();

    // Kiểm tra xem giá trị đã chọn có rỗng không
    if (selectedValue === null || selectedValue === '') {
        selectizeQA.disable();
        selectizeQA.setValue(null);
    } else {
        selectizeQA.enable();
    }
})

CKEDITOR.replace('txaTaskDescription');


var selectizeEditors = $('#slEditors');
selectizeEditors.selectize({
    sortField: 'text', // Sắp xếp mục theo văn bản,
    placeholder: 'Please choose a Editor'
});
var selectizeEditor = selectizeEditors[0].selectize;

var selectizeQAs = $('#slQAs');
selectizeQAs.selectize({
    sortField: 'text', // Sắp xếp mục theo văn bản,
    placeholder: 'Please choose a Q.A'
});
var selectizeQA = selectizeQAs[0].selectize;