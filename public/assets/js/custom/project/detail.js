var taskId = 0;
$(document).ready(function () {
    GetTasksList();  
    GetLogs(); 
})
function GetLogs(){
    $('#ulProjectLogs').empty();
    if (idValue !== null) {
        $.ajax({
            url:'../projectlog/list',
            type:'get',
            data:{projectId:idValue},
            success:function(data){
                try {
                    let content = $.parseJSON(data);
                    let logs = content.logs;
                    logs.forEach(l=>{
                        $('#ulProjectLogs').append(`
                        <li>
                            <div class="row">                                
                                <div class="col-sm-1 align-middle pt-2">                               
                                    <i class="fa-regular fa-clock align-middle pl-2 text-warning"></i>
                                </div>
                                <div class="col-sm-11">                                  
                                        <span class="text-info">${l.content}</span>
                                        <span class="time">${l.timestamp}</span>                                    
                                </div>
                            </div>                           
                        </li>
                        `);
                    })
                } catch (error) {
                    console.log(data,error);
                }
            }
        })
    }
}
function GetTasksList() {
    $('#tblTasksList').empty();

    // Kiểm tra xem tham số "id" có tồn tại hay không
    if (idValue !== null) {
        $.ajax({
            url: '../task/ListByProject',
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
                                                            <td><span class="text-info">${t.level}</span></td>
                                                            <td class="text-center">${t.quantity}</td>
                                                            <td>${t.editor ? t.editor : '-'}</td>
                                                            <td>${t.qa ? t.qa : '-'}</td>
                                                            <td>${t.dc?t.dc:'-'}</td>
                                                            <td><span class="${t.status_color?t.status_color:''}">${t.status ? t.status : ''}</span></td>
                                                            <td>
                                                                <div class="dropdown action-label">
                                                                    <a class="btn btn-outline-primary btn-sm dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                                                    <i class="fas fa-cog"></i>								</a>	
                                                                    <div class="dropdown-menu dropdown-menu-right">
                                                                        <a class="dropdown-item" href="javascript:void(0)" onClick="viewTask(${t.id})"><i class="fa fa-eye" aria-hidden="true"></i> View</a>
                                                                        <a class="dropdown-item" href="javascript:void(0)" onClick="editTask(${t.id})"><i class="fas fa-pencil-alt"></i>  Update</a>
                                                                        ${t.status_id == 0?'<a class="dropdown-item" href="javascript:void(0)" onClick="deleteTask('+t.id+')"><i class="fas fa-trash-alt"></i>  Delete</a>':''}
                                                                        
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

