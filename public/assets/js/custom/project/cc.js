$('#btnSubmitCC').click(function(){
    let begin_date = $('#txtCCBeginDate').val();
    let end_date = $('#txtCCEndDate').val();
    let description = qCCDescription.getText();
    let instruction = qCCInstruction.getText();

    console.log({begin_date,end_date,description,instruction});

})

function AddNewCC(pId){
    console.log(pId);
    $('#modal_cc').modal('show');
}

var qCCDescription = new Quill('#divCCDescription', {
    theme: 'snow', // Chọn giao diện "snow"
    modules: {
        toolbar: [
            ['bold', 'italic', 'underline'],
            [{ 'list': 'ordered' }, { 'list': 'bullet' }],
            ['link'], // Thêm nút chèn liên kết
            [{ 'color': ['#F00', '#0F0', '#00F', '#000', '#FFF', 'color-picker'] }], // Thêm nút chọn màu
        ]
    },
    placeholder: "Enter CC description here...",
    // Đặt chiều cao cho trình soạn thảo
    // Ví dụ: Chiều cao 300px
    height: '300px'
    // Hoặc chiều cao 5 dòng
    // height: '10em'
});
var qCCInstruction = new Quill('#divCCInstruction', {
    theme: 'snow', // Chọn giao diện "snow"
    modules: {
        toolbar: [
            ['bold', 'italic', 'underline'],
            [{ 'list': 'ordered' }, { 'list': 'bullet' }],
            ['link'], // Thêm nút chèn liên kết
            [{ 'color': ['#F00', '#0F0', '#00F', '#000', '#FFF', 'color-picker'] }], // Thêm nút chọn màu
        ]
    },
    placeholder: "Enter CC intruction for Editor here...",
});
