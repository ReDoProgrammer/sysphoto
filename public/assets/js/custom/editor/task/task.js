var page = 1;
var limit = 10;
$(document).ready(function () {
    LoadOwnTasks();
    LoadTaskStatuses();
})
$('#btnGetTask').click(function () {
    $.ajax({
        url: 'task/gettask',
        type: 'get',
        success: function (data) {
            console.log(data);
            GetOwnTasks();
        }
    })
})

$('#btnSearch').click(function(e){
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
    let status = parseInt(selectizeTaskStatus.getValue()?selectizeTaskStatus.getValue():0);
    let limit = parseInt($('#slPageSize option:selected').val());


    $.ajax({
        url:'task/filter',
        type:'get',
        data:{
            from_date,
            to_date,
            status,           
            page,
            limit
        },
        success:function(data){
            console.log(data);
        }
    })
}


var $selectizeTaskStatuses = $('#slTaskStatuses');
$selectizeTaskStatuses.selectize({
    sortField: 'text', // Sắp xếp mục theo văn bản
    placeholder: 'Task Status'
});
var selectizeTaskStatus = $selectizeTaskStatuses[0].selectize;