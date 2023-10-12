$(document).ready(function(){
    GetOwnTasks();
})
$('#btnGetTask').click(function(){
    $.ajax({
        url:'task/gettask',
        type:'get',
        success:function(data){
            console.log(data);
            GetOwnTasks();
        }
    })
})

function GetOwnTasks(){

}