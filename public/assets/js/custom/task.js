$('#btnSubmitCreating').click(function(e){
    e.preventDefault();
    $.ajax({
        url:"Task/addTask",
        type:'post',
        success:function(data){
            console.log(data);
        }
    })
})

$(document).ready(function(){
    LoadTasks();
})

function LoadTasks(){
    $.ajax({
        url:'Task/getTaskList',       
        type:'get',        
        success:function(data){
            var tasks = $.parseJSON(data);
           console.log(tasks)
            tasks.forEach(t => {
               let tr = `<tr>`;
                    tr+= `<td>`;
                    tr += t.name;
                    tr+= `</td>`
               tr+= '</tr>'; 
               $('#tblTasks').append(tr);
            });
        }
    })
}
$('#btnSearch').click(function(e){
    e.preventDefault();
    $.ajax({
        url:'Task/getTaskList',        
        type:'post',
        data:{
            employee:$('#txtEmployee').val(),
            project: $('#txtProject').val()
        },
        success:function(data){
            console.log(data);
        }
    })
})