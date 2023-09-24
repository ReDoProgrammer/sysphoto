$(document).ready(function(){ 
    LoadJobStatus(); 
    $('#btnSearch').click();
})

function LoadJobStatus(){
    $.ajax({
        url:'JobStatus/list',
        type:'get',
        success:function(data){
            var stt = $.parseJSON(data);
            stt.forEach(s=>{
                $('#slJobStatus').append(`<option value="${s.id}">${s.stt_job_name.toUpperCase()}</option>`);
            })            
        }
    })
}



$('#btnSearch').click(function(e){
    e.preventDefault();
    let from_date = $('#txtFromDate').val();
    let to_date = $('#txtToDate').val();
    let stt = $('#slJobStatus').val() ?$.map($('#slJobStatus').val(), function(value) {
        return parseInt(value, 10); // Chuyển đổi thành số nguyên với cơ số 10
    }) : [];
    let search = $('#txtSearch').val();
    console.log({from_date,to_date,stt,search});
    $('#tblProjects').empty();
    $.ajax({
        url:'project/getList',
        type:'get',
        data:{
            from_date,
            to_date,
            stt,
            search
        },
        success:function(data){
            // console.log(data);
            let projects = $.parseJSON(data);
            console.log(projects);
            
            projects.forEach(p=>{
                $('#tblProjects').append(`
                    <tr id="${p.id}">
                        <td>${p.id}</td>
                        <td class="fw-bold">${p.name_ct_mh}</td>
                        <td>${p.name}</td>
                        <td>${p.start_date}</td>
                        <td>${p.end_date}</td>
                        <td><div class="${p.color_sttj}">${p.stt_job_name}</div></td>
                    </tr>
                `);
            })
        },
        error: function(jqXHR, textStatus, errorThrown) {
            console.error("Lỗi AJAX:", textStatus, errorThrown);
            console.log("Mã lỗi HTTP:", jqXHR.status);
        }
    })
})
