var taskId = 0;
$(document).ready(function () {
    getTasksList();   
})

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

