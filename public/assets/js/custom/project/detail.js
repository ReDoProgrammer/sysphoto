var taskId = 0;
$(document).ready(function () {
    getTasksList();
    getTaskLevels();
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
});

function deleteTask(id){
    Swal.fire({
        title: 'Are you sure want to delete this task?',
        text: "You won't be able to revert this!",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!'
      }).then((result) => {
        if (result.isConfirmed) {
          $.ajax({
            url:'../task/delete',
            type:'post',
            data:{id},
            success:function(data){
                try {
                    let content = $.parseJSON(data);
                    if(content.code == 200){
                        $.toast({
                            heading: content.heading,
                            text: content.msg,
                            icon: content.icon,
                            loader: true,        // Change it to false to disable loader
                            loaderBg: '#9EC600'  // To change the background
                        })
                        getTasksList();
                    }
                } catch (error) {
                    console.log(data,error);
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
                    qDescription.setText(t.note?t.note:'');
                    $('#slLevels').val(t.lId);
                    LoadEditorsByLevel(t.lId, t.eId);
                    LoadQAsByLevel(t.lId, t.qaId);
                    $('#txtQuantity').val(t.qty)
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
                if (content.code == 200) {
                    $('#pDescription').html(content.task.note?content.task.note:'');
                }
                $('#view_task_modal').modal('show');
            } catch (error) {
                console.log(data, error);
            }
        }
    })

}


$('#btnSubmitTask').click(function () {
    let description = qDescription.getText();
    let level = $('#slLevels option:selected').val();
    let editor = $('#slEditors option:selected').val();
    let qa = $('#slQAs option:selected').val();
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

    if (taskId < 1) {
        $.ajax({
            url: '../task/create',
            type: 'post',
            data: {
                prjId: idValue,
                description,
                level,
                editor: editor ? editor : 0,
                qa: qa ? qa : 0,
                quantity: parseInt(quantity)
            },
            success: function (data) {
                try {
                    let content = $.parseJSON(data);
                    $.toast({
                        heading: content.heading,
                        text: content.msg,
                        icon: content.icon,
                        loader: true,        // Change it to false to disable loader
                        loaderBg: '#9EC600'  // To change the background
                    })

                    if (content.code == 201) {
                        $('#task_modal').modal('hide');
                        getTasksList();
                    }
                } catch (error) {
                    console.log(data, error);
                }
            }
        })
    } else {
        $.ajax({
            url: '../task/update',
            type: 'post',
            data: {
                id: taskId,
                prjId: idValue,
                description,
                level,
                editor: editor ? editor : 0,
                qa: qa ? qa : 0,
                quantity: parseInt(quantity)
            },
            success: function (data) {
                try {
                    let content = $.parseJSON(data);
                    $.toast({
                        heading: content.heading,
                        text: content.msg,
                        icon: content.icon,
                        loader: true,        // Change it to false to disable loader
                        loaderBg: '#9EC600'  // To change the background
                    })

                    if (content.code == 200) {
                        $('#task_modal').modal('hide');
                        getTasksList();
                    }
                } catch (error) {
                    console.log(data, error);
                }
            }
        })
    }
})

$('#slLevels').on('change', function () {
    LoadEditorsByLevel($(this).val());
    LoadQAsByLevel($(this).val());
})

$('#slEditors').on('change', function() {
    var selectedValue =  $(this).val();

    // Kiểm tra xem giá trị đã chọn có rỗng không
    if (selectedValue === null || selectedValue === '') {
        selectizeQA.disable();
        selectizeQA.setValue(null);
    }else{
        selectizeQA.enable();
    }
})




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
                        selectizeEditor.addOption({ value: `${e.id}`, text: `${e.viettat}` });
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
                        selectizeQA.addOption({ value: `${e.id}`, text: `${e.viettat}` });
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
    $('#slLevels').append(` <option value="" disabled selected>Vui lòng chọn level</option>`);
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

function getTasksList() {
    $('#tblTasksList').empty();

    // Kiểm tra xem tham số "id" có tồn tại hay không
    if (idValue !== null) {
        $.ajax({
            url: '../task/getTasksByProject',
            type: 'get',
            data: { id: idValue },
            success: function (data) {
                try {
                    let content = $.parseJSON(data)
                    if (content.code == 200) {
                        let idx = 1;
                        content.tasks.forEach(t => {
                            
                            $('#tblTasksList').append(`
                                                        <tr id = "${t.id}">
                                                            <td>${idx++}</td>
                                                            <td><span class="${t.level_bg}">${t.level}</span></td>
                                                            <td class="text-center">${t.qty}</td>
                                                            <td>${t.editor ? t.editor : ''}</td>
                                                            <td>${t.qa ? t.qa : ''}</td>
                                                            <td>${t.got_time}</td>
                                                            <td><span class="${t.status_bg}">${t.status ? t.status : ''}</span></td>
                                                            <td>
                                                                <div class="dropdown action-label">
                                                                    <a class="btn btn-outline-primary btn-sm dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                                                    <i class="fas fa-cog"></i>								</a>	
                                                                    <div class="dropdown-menu dropdown-menu-right">
                                                                        <a class="dropdown-item" href="javascript:void(0)" onClick="viewTask(${t.id})"><i class="fa fa-eye" aria-hidden="true"></i> View</a>
                                                                        <a class="dropdown-item" href="javascript:void(0)" onClick="editTask(${t.id})"><i class="fas fa-pencil-alt"></i>  Update</a>
                                                                        ${t.tStatus == 0?'<a class="dropdown-item" href="javascript:void(0)" onClick="deleteTask('+t.id+')"><i class="fas fa-trash-alt"></i>  Delete</a>':''}
                                                                        
                                                                    </div> 
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    `);
                        })
                    }
                } catch (error) {
                    console.log(data);
                }
            }
        })
    }
}


var qDescription = new Quill('#divDescription', {
    theme: 'snow', // Chọn giao diện "snow"
    modules: {
        toolbar: [
            ['bold', 'italic', 'underline'],
            [{ 'list': 'ordered' }, { 'list': 'bullet' }],
            ['link'], // Thêm nút chèn liên kết
            [{ 'color': ['#F00', '#0F0', '#00F', '#000', '#FFF', 'color-picker'] }], // Thêm nút chọn màu
        ]
    },
    placeholder: "Enter task description here...",
    // Đặt chiều cao cho trình soạn thảo
    // Ví dụ: Chiều cao 300px
    height: '300px'
    // Hoặc chiều cao 5 dòng
    // height: '10em'
});


var selectizeEditors = $('#slEditors');
selectizeEditors.selectize({
    sortField: 'text', // Sắp xếp mục theo văn bản,
    placeholder: 'Vui lòng chọn editor'
});
var selectizeEditor = selectizeEditors[0].selectize;

var selectizeQAs = $('#slQAs');
selectizeQAs.selectize({
    sortField: 'text', // Sắp xếp mục theo văn bản,
    placeholder: 'Vui lòng chọn Q.A'
});
var selectizeQA = selectizeQAs[0].selectize;



var url = new URL(window.location.href);

// Lấy giá trị của tham số "id" từ URL
var idValue = url.searchParams.get("id");