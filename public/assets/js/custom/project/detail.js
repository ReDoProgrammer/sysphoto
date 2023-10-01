$(document).ready(function () {
    getTasksList();
    getTaskLevels();
    getTaskStatuses();
})

$('#btnSubmitTask').click(function () {
    let description = qDescription.getText();
    let level = $('#slLevels option:selected').val();
    let editor = $('#slEditors option:selected').val();
    let qa = $('#slQAs option:selected').val();
    let quantity = $('#txtQuantity').val();
    let status = $('#slTaskStatuses option:selected').val();

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

    $.ajax({
        url: '../task/create',
        type: 'post',
        data: {
            prjId:idValue,
            description,
            level,
            editor:editor?editor:0,
            qa:qa?qa:0,
            quantity: parseInt(quantity),
            status
        },
        success:function(data){
            try {
                let content = $.parseJSON(data);
                $.toast({
                    heading: content.heading,
                    text: content.msg,
                    icon: content.icon,
                    loader: true,        // Change it to false to disable loader
                    loaderBg: '#9EC600'  // To change the background
                })

                if(content.code == 201){                   
                    $('#add_task_modal').modal('hide');
                    getTasksList();
                }
            } catch (error) {
                console.log(data,error);
            }
        }
    })

})

$('#slLevels').on('change', function () {
    LoadEditorsByLevel($(this).val());
    LoadQAsByLevel($(this).val());
})


function getTaskStatuses() {
    $.ajax({
        url: '../taskstatus/list',
        type: 'get',
        success: function (data) {
            try {
                let content = $.parseJSON(data);

                if (content.code == 200) {
                    content.statuses.forEach(t => {
                        $('#slTaskStatuses').append(`<option value="${t.id}">${t.stt_task_name}</option>`);
                    })
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}


function LoadEditorsByLevel(level) {
    var selectize = $selectizeEditors[0].selectize;
    selectize.clearOptions();
    $.ajax({
        url: '../employee/getEditors',
        type: 'get',
        data: { level },
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                if (content.code == 200) {

                    content.editors.forEach(e => {
                        selectize.addOption({ value: `${e.id}`, text: `${e.viettat}` });
                    })
                }
            } catch (error) {

            }
        }
    })
}

function LoadQAsByLevel(level) {
    var selectize = $selectizeQAs[0].selectize;
    selectize.clearOptions();
    $.ajax({
        url: '../employee/getQAs',
        type: 'get',
        data: { level },
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                if (content.code == 200) {

                    content.qas.forEach(e => {
                        selectize.addOption({ value: `${e.id}`, text: `${e.viettat}` });
                    })
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
                                                            <td>${t.note ? t.note : ''}</td>
                                                            <td>${t.editor ? t.editor : ''}</td>
                                                            <td>${t.qa ? t.qa : ''}</td>
                                                            <td>${t.got_time}</td>
                                                            <td><span class="${t.status_bg}">${t.status ? t.status : ''}</span></td>
                                                            <td>
                                                                <div class="dropdown action-label">
                                                                    <a class="btn btn-outline-primary btn-sm dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                                                    <i class="fas fa-cog"></i>								</a>	
                                                                    <div class="dropdown-menu dropdown-menu-right">
                                                                        <a class="dropdown-item" href="" ><i class="fa fa-eye" aria-hidden="true"></i> View</a>
                                                                        <a class="dropdown-item" href="javascript:void(0)"><i class="fas fa-pencil-alt"></i>  Update</a>
                                                                        <a class="dropdown-item" href="javascript:void(0)"><i class="fas fa-trash-alt"></i>  Delete</a>
                                                                        
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


var $selectizeEditors = $('#slEditors');
$selectizeEditors.selectize({
    sortField: 'text', // Sắp xếp mục theo văn bản,
    placeholder: 'Vui lòng chọn editor'
});

var $selectizeQAs = $('#slQAs');
$selectizeQAs.selectize({
    sortField: 'text', // Sắp xếp mục theo văn bản,
    placeholder: 'Vui lòng chọn Q.A'
});

var url = new URL(window.location.href);

// Lấy giá trị của tham số "id" từ URL
var idValue = url.searchParams.get("id");