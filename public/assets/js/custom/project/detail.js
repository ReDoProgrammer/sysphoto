var taskId = 0;
$(document).ready(function () {
    GetTasksList();
    GetLogs();
    GetCCs();
})
function GetLogs() {
    $('#ulProjectLogs').empty();
    if (idValue !== null) {
        $.ajax({
            url: '../projectlog/list',
            type: 'get',
            data: { projectId: idValue },
            success: function (data) {
                try {
                    let content = $.parseJSON(data);
                    let logs = content.logs;
                    logs.forEach(l => {
                        $('#ulProjectLogs').append(`
                            <li>
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
                } catch (error) {
                    console.log(data, error);
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
                                                            <td>${t.dc ? t.dc : '-'}</td>
                                                            <td><span class="${t.status_color ? t.status_color : ''}">${t.status ? t.status : ''}</span></td>
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
                    console.log(data);
                }
            }
        })
    }
}
function GetCCs() {
    if (idValue !== null) {
        $.ajax({
            url: '../cc/getccs',
            type: 'get',
            data: {
                project_id: idValue
            },
            success: function (data) {
                console.log(data);
                // try {
                //     let content = $.parseJSON(data);
                //     content.ccs.forEach(c => {
                //         console.log({ c });
                //         $('#accordionFeedbacksAndCCs').append(`
                //             <div class="accordion-item">
                //                 <h2 class="accordion-header">
                //                     <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
                //                         data-bs-target="#collapse${c.id}" aria-expanded="true" aria-controls="collapseOne1">
                //                         <i class="fa-regular fa-clock text-warning" style="margin-right:5px;"></i>  ${c.start_date} - ${c.end_date}
                //                     </button>
                //                 </h2>
                //                 <div id="collapse${c.id}" class="accordion-collapse collapse" data-bs-parent="#accordionExample">
                //                     <div class="accordion-body">
                //                         <p>${c.feedback}</p>
                //                         <table class="table table-hover mb-0">
                //                             <thead>
                //                                 <tr>
                //                                     <th>#</th>
                //                                     <th>Level</th>
                //                                     <th>Q.ty</th>
                //                                     <th>Editor</th>
                //                                     <th>Q.A</th>
                //                                     <th>DC</th>
                //                                     <th>Status</th>
                //                                     <th>Action</th>
                //                                 </tr>
                //                             </thead>
                //                             <tbody id="tblCCTasksList"></tbody>
                //                         </table>
                //                     </div>
                //                 </div>
                //             </div>
                //         `);
                //     })
                // } catch (error) {
                //     console.log(data, error);
                // }
            }
        })
    }
}

