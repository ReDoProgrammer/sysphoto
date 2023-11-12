$(document).ready(function () {
    getTaskLevels();
    LoadTaskStatuses();
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
                            GetProjectDetail();
                            GetLogs();
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
        url: '../task/detail',
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

function viewTask(id) {
    $.ajax({
        url: '../task/detail',
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
    }

    $.toast({
        heading: content.heading,
        text: content.msg,
        icon: content.icon,
        loader: true,
        loaderBg: '#9EC600'
    });
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
                    content.statuses.forEach(t => {
                        // selectizeTaskStatus.addOption({ value: `${t.id}`, text: `${t.name}` });
                        // if (t.id != 7) {
                        //     $('#slRejectIntoStatus').append(`<option value="${t.id}">${t.name}</option>`);
                        // }
                    })
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}


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

