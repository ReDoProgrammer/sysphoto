$(document).ready(function () {
    getTaskLevels();
    LoadTaskStatuses();
})

$("#task_modal").on('shown.bs.modal', function () {
    $('#taskModalTitle').text("Add new task");
    $('#btnSubmitTask').text('Submit creating');
});


$("#task_modal").on("hidden.bs.modal", function () {
    pId = 0;
    ccId = 0;
    fetch();
});



$('#btnSubmitTask').click(function () {
    let description = CKEDITOR.instances['txaTaskDescription'].getData();
    let level = $('#slLevels option:selected').val();
    let status = (selectizeTaskStatus.items && selectizeTaskStatus.items.length>0)?parseInt(selectizeTaskStatus.items[0]):0;

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

    $.ajax({
        url: 'task/create',
        type: 'post',
        data: {
            prjId: pId,
            description,
            level, 
            status,
            cc:ccId,
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
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })


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

function LoadEditorsByLevel(level, selected = null) {

    selectizeEditor.clearOptions();
    $.ajax({
        url: 'employee/getEditors',
        type: 'get',
        data: { level },
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                if (content.code == 200) {

                    content.editors.forEach(e => {
                        console.log(e);
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
        url: 'employee/getQAs',
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
        url: 'level/getList',
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
        url: 'taskstatus/all',
        type: 'get',
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                if (content.code == 200) {
                    content.statuses.forEach(t => {
                        selectizeTaskStatus.addOption({value:t.id,text:t.name})
                    })
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}


CKEDITOR.replace('txaTaskDescription');

var selectizeTaskStatuses = $('#slTaskStatuses');
selectizeTaskStatuses.selectize({
    sortField: 'text', // Sắp xếp mục theo văn bản,
    placeholder: 'Choose a status'
});
var selectizeTaskStatus = selectizeTaskStatuses[0].selectize;


var selectizeEditors = $('#slEditors');
selectizeEditors.selectize({
    sortField: 'text', // Sắp xếp mục theo văn bản,
    placeholder: 'Choose an editor'
});
var selectizeEditor = selectizeEditors[0].selectize;

var selectizeQAs = $('#slQAs');
selectizeQAs.selectize({
    sortField: 'text', // Sắp xếp mục theo văn bản,
    placeholder: 'Choose a Q.A'
});
var selectizeQA = selectizeQAs[0].selectize;


