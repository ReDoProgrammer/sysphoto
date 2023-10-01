$(document).ready(function () {
    getTasksList();
    getTaskLevels();
})

$('#slLevels').on('change',function(){
    LoadEditorsByLevel($(this).val());
    LoadQAsByLevel($(this).val());
})

function LoadEditorsByLevel(level){
    $.ajax({
        url:'../user/getEditors',
        type:'get',
        data:{level},
        success:function(data){
            try {
                console.log(data);
            } catch (error) {
                
            }
        }
    })
}

function LoadQAsByLevel(level){

}


function getTaskLevels(){
    $.ajax({
        url:'../level/getList',
        type:'get',
        success:function(data){
            try {
                let content = $.parseJSON(data);
                $('#slLevels').append(` <option value="" disabled selected>Vui lòng chọn option</option>`);
                if(content.code == 200){
                    content.levels.forEach(lv=>{
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
    var url = new URL(window.location.href);

    // Lấy giá trị của tham số "id" từ URL
    var idValue = url.searchParams.get("id");

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
                                                            <td>${t.note?t.note:''}</td>
                                                            <td>${t.editor?t.editor:''}</td>
                                                            <td>${t.qa?t.qa:''}</td>
                                                            <td>${t.got_time}</td>
                                                            <td><span class="${t.status_bg}">${t.status?t.status:''}</span></td>
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
    placeholder: "Enter project's description here...",
    // Đặt chiều cao cho trình soạn thảo
    // Ví dụ: Chiều cao 300px
    height: '300px'
    // Hoặc chiều cao 5 dòng
    // height: '10em'
});