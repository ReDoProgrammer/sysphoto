var page = 1,
    limit = 10,
    cId = 0;
$(document).ready(function () {
    GetCustomerGroups();
    $('#btnSearch').click();

    LoadColorModes();
    LoadOutputs();
    LoadNationalStyles();
    LoadClouds();
})

$('input[type="checkbox"]').change(function () {
    let ckbId = $(this).attr('id');
    if ($(this).is(':checked')) {
        $(`#txt${ckbId.slice(3)}`).attr("disabled", false);
    } else {
        $(`#txt${ckbId.slice(3)}`).attr("disabled", true);
        $(`#txt${ckbId.slice(3)}`).val('');
    }

});

$("#modal_customer").on('shown.bs.modal', function () {
    if (cId < 1) {
        var modal = $("#modal_customer");
        var checkboxes = modal.find("input[type='checkbox']");
        var textinputs = modal.find("input[type='text']");
        var selects = modal.find("select");

        selects.each(function () {
            $(this).selectedIndex = -1;
        });


        textinputs.each(function () {
            $(this).val('');
        })


        checkboxes.each(function () {
            let ckbId = $(this).attr('id');
            $(`#${ckbId}`).prop("checked", false);
            $(`#txt${ckbId.slice(3)}`).attr("disabled", true);
            $(`#txt${ckbId.slice(3)}`).val('');
        });



    }
});

$("#modal_customer").on("hidden.bs.modal", function () {
    cId = 0;
    fetch();
    $('#CustomerModalTitle').text('Add New Customer');
    $('#btnSubmitCustomer').text('Submit');
});

async function createOrUpdateCustomer() {
    try {
        await Promise.all([CheckAcronym(cId, acronym), CheckEmail(cId, email)]);

        const url = cId < 1 ? 'customer/create' : 'customer/update';
        const data = {
            id: cId,
            group_id,
            name,
            acronym,
            email,
            password,
            customer_url,
            color_mode,
            output,
            size,
            is_straighten,
            straighten_remark,
            tv,
            fire,
            sky,
            grass,
            nationtal_style,
            cloud,
            style_remark
        };

        const response = await $.ajax({
            url: url,
            type: 'post',
            data: data
        });

        const content = $.parseJSON(response);
        if (content.code === (cId < 1 ? 201 : 200)) {
            $('#modal_customer').modal('hide');
            $('#btnSearch').click();
        }

        $.toast({
            heading: content.heading,
            text: content.msg,
            icon: content.icon,
            loader: true,
            loaderBg: '#9EC600'
        });
    } catch (error) {
        console.log(error);
    }
}

function handleResponse(response) {
    const content = $.parseJSON(response);
    if (content.code === (cId < 1 ? 201 : 200)) {
        $('#modal_customer').modal('hide');
        $('#btnSearch').click();
    }

    $.toast({
        heading: content.heading,
        text: content.msg,
        icon: content.icon,
        loader: true,
        loaderBg: '#9EC600'
    });
}


$('#btnSubmitCustomer').click(function () {
    let group_id = $('#slMDCustomerGroups option:selected').val();
    let name = $('#txtCustomerName').val();
    let acronym = $('#txtAcronym').val();
    let email = $('#txtCustomerEmail').val();
    let password = $('#txtCustomerPassword').val();
    let confirm_password = $('#txtConfirmCustomerPassword').val();
    let customer_url = $('#txtCustomerUrl').val();

    let color_mode = $('#slColorModes option:selected').val() ? $('#slColorModes option:selected').val() : 0;
    let output = $('#slOutputs option:selected').val() ? $('#slOutputs option:selected').val() : 0;
    let size = $('#txtSize').val();
    let is_straighten = $('#ckbStraighten').is('checked');
    let straighten_remark = $('#txtStraighten').val();
    let tv = $('#txtTV').val();
    let fire = $('#txtFire').val();
    let sky = $('#txtSky').val();
    let grass = $('#txtGrass').val();
    let nationtal_style = $('#slNationalStyles option:selected').val() ? $('#slNationalStyles option:selected').val() : 0;
    let cloud = $('#slClouds option:selected').val() ? $('#slClouds option:selected').val() : 0;
    let style_remark = qStyleRemark.getText();



    if ($.trim(name) === "") {
        $.toast({
            heading: `Customer name can not be null`,
            text: `Please enter customer name`,
            icon: 'warning',
            loader: true,        // Change it to false to disable loader
            loaderBg: '#9EC600'  // To change the background
        })
        return;
    }
    if ($.trim(acronym) === "") {
        $.toast({
            heading: `Customer acronym can not be null`,
            text: `Please enter customer acronym`,
            icon: 'warning',
            loader: true,        // Change it to false to disable loader
            loaderBg: '#9EC600'  // To change the background
        })
        return;
    }

    if (!isEmail(email)) {
        $.toast({
            heading: `Email is not valid`,
            text: `Please check email address`,
            icon: 'warning',
            loader: true,        // Change it to false to disable loader
            loaderBg: '#9EC600'  // To change the background
        })
        return;
    }

    if (password != confirm_password) {
        $.toast({
            heading: `Password not match`,
            text: `Please check password on twice inputs`,
            icon: 'warning',
            loader: true,        // Change it to false to disable loader
            loaderBg: '#9EC600'  // To change the background
        })
        return;
    }

    Promise.all[CheckAcronym(cId, acronym), CheckEmail(cId, email)]
        .then(_ => {
            if (cId < 1) {
                $.ajax({
                    url: 'customer/create',
                    type: 'post',
                    data: {
                        group_id, name, acronym, email, password, customer_url,
                        color_mode, output, size, is_straighten, straighten_remark, tv,
                        fire, sky, grass, nationtal_style, cloud, style_remark
                    },
                    success: function (data) {
                        try {
                            let content = $.parseJSON(data);
                            if (content.code == 201) {
                                $('#modal_customer').modal('hide');
                                $('#btnSearch').click();
                            }
                            $.toast({
                                heading: content.heading,
                                text: content.msg,
                                icon: content.icon,
                                loader: true,        // Change it to false to disable loader
                                loaderBg: '#9EC600'  // To change the background
                            })
                        } catch (error) {
                            console.log(data, error);
                        }

                    }
                })

            } else {
                $.ajax({
                    url: 'customer/update',
                    type: 'post',
                    data: {
                        id: cId, group_id, name, acronym, email, password, customer_url,
                        color_mode, output, size, is_straighten, straighten_remark, tv,
                        fire, sky, grass, nationtal_style, cloud, style_remark
                    },
                    success: function (data) {
                        try {
                            let content = $.parseJSON(data);
                            if (content.code == 200) {
                                $('#modal_customer').modal('hide');
                                $('#btnSearch').click();
                            }
                            $.toast({
                                heading: content.heading,
                                text: content.msg,
                                icon: content.icon,
                                loader: true,        // Change it to false to disable loader
                                loaderBg: '#9EC600'  // To change the background
                            })
                        } catch (error) {
                            console.log(data, error);
                        }

                    }
                })
            }
        })
        .catch(err => {
            console.log(err);
        })






})


$('#btnSearch').click(function () {
    fetch();
})
$('#slPageSize').on('change', function () {
    limit = $(this).val();
    page = 1;
    fetch();
});


$(document).on("click", "#pagination li a.page-link", function (e) {
    e.preventDefault();
    $("#pagination li").removeClass("active");
    $(this).closest("li.page-item").addClass("active");
    page = $(this).text();
    fetch();
});


function UpdateCustomer(id) {
    $.ajax({
        url: 'customer/GetDetail',
        type: 'get',
        data: { id },
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                if (content.code == 200) {
                    cId = id;
                    $('#CustomerModalTitle').text('Update Customer');
                    $('#btnSubmitCustomer').text('Save changes');

                    $('#modal_customer').modal('show');
                    let c = content.customer;
                    $('#txtCustomerName').val(c.name);
                    $('#txtCustomerEmail').val(c.email);
                    $('#txtCustomerUrl').val(c.customer_url);
                    selectizeColorMode.setValue(c.color_mode_id);
                    selectizeOutput.setValue(c.output_id);
                    $('#txtSize').val(c.size);

                    $('#ckbStraighten').prop('checked', c.is_straighten == 1);
                    $('#txtStraighten').prop('disabled', c.is_straighten == 0);
                    $('#txtStraighten').val(c.straighten_remark);

                    $('#ckbTV').prop('checked', c.tv.trim().length > 0);
                    $('#txtTV').prop('disabled', c.tv.length.trim == 0);
                    $('#txtTV').val(c.tv);

                    $('#ckbFire').prop('checked', c.fire.trim().length > 0);
                    $('#txtFire').prop('disabled', c.fire.length.trim == 0);
                    $('#txtFire').val(c.fire);

                    $('#ckbSky').prop('checked', c.sky.trim().length > 0);
                    $('#txtSky').prop('disabled', c.sky.length.trim == 0);
                    $('#txtSky').val(c.sky);


                    $('#ckbGrass').prop('checked', c.grass.trim().length > 0);
                    $('#txtGrass').prop('disabled', c.grass.length.trim == 0);
                    $('#txtGrass').val(c.grass);

                    selectizeNationalStyle.setValue(c.national_style_id);
                    selectizeCloud.setValue(c.cloud_id);


                    qStyleRemark.setText(c.style_remark);
                }
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}


function LoadClouds() {
    $.ajax({
        url: 'cloud/all',
        type: 'get',
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                content.clouds.forEach(c => {
                    selectizeCloud.addOption({ value: `${c.id}`, text: `${c.name}` });
                })

            } catch (error) {
                console.log(error, data);
            }

        }
    })
}

function LoadNationalStyles() {
    $.ajax({
        url: 'nationalstyle/all',
        type: 'get',
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                content.styles.forEach(s => {
                    selectizeNationalStyle.addOption({ value: `${s.id}`, text: `${s.name}` });
                })

            } catch (error) {
                console.log(error, data);
            }

        }
    })
}
function LoadOutputs() {
    $.ajax({
        url: 'output/all',
        type: 'get',
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                content.outputs.forEach(o => {
                    selectizeOutput.addOption({ value: `${o.id}`, text: `${o.name}` });
                })

            } catch (error) {
                console.log(error, data);
            }

        }
    })
}

function LoadColorModes() {
    $.ajax({
        url: 'colormode/all',
        type: 'get',
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                content.colormodes.forEach(m => {
                    selectizeColorMode.addOption({ value: `${m.id}`, text: `${m.name}` });
                })

            } catch (error) {
                console.log(error, data);
            }

        }
    })
}

function fetch() {
    $('#pagination').empty();
    $('#tblCustomers').empty();
    $.ajax({
        url: 'customer/getlist',
        type: 'get',
        data: {
            page,
            limit,
            group: $('#slCustomerGroups option:selected').val(),
            search: $('#txtSearch').val()
        },
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                console.log(content);
                let pages = content.data.pages;
                let customers = content.data.customers;
                if (pages > 1) {
                    for (i = 1; i <= pages; i++) {
                        if (i == page) {
                            $('#pagination').append(`<li class="page-item active" aria-current="page">
                                                    <a class="page-link" href="#">${i}</a>
                                                </li>`);
                        } else {
                            $('#pagination').append(`<li class="page-item"><a class="page-link" href="#">${i}</a></li>`);
                        }
                    }
                }


                let idx = (page - 1) * limit;
                customers.forEach(c => {
                    $('#tblCustomers').append(`
                        <tr id = "${c.id}">     
                            <td>${++idx}</td>                       
                            <td class="fw-bold text-info">${c.group_name}</td>
                            <td class="fw-bold">${c.fullname}</td>
                            <td class="text-warning fw-bold">${c.acronym}</td>
                            <td>${c.email}</td>
                            <td>${c.company ? c.company : ''}</td>
                            <td><a href="${c.url}" target="_blank">Link</a></td>
                            <td class="text-end">
                                <div class="dropdown action-label">
                                    <a class="btn btn-outline-primary btn-sm dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">
                                    <i class="fas fa-cog"></i>								</a>	
                                    <div class="dropdown-menu dropdown-menu-right">
                                        <a class="dropdown-item" href="../admin/customer/detail?id=${c.id}" ><i class="fa fa-eye" aria-hidden="true"></i> Detail</a>
                                        <a class="dropdown-item" href="javascript:void(0)" onClick="UpdateCustomer(${c.id})"><i class="fas fa-pencil-alt"></i>  Update</a>
                                        <a class="dropdown-item" href="javascript:void(0)" onClick="DestroyCustomer(${c.id})"><i class="fas fa-trash-alt"></i>  Delete</a>
                                    </div> 
                                </div>
                            </td>
                        </tr>
                    `);
                })
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}

function GetCustomerGroups() {
    $.ajax({
        url: 'customergroup/list',
        'type': 'get',
        success: function (data) {
            try {
                let content = $.parseJSON(data);
                content.groups.forEach(g => {
                    selectizeCustomerGroup.addOption({ value: `${g.id}`, text: `${g.name}` });
                    $('#slMDCustomerGroups').append(`<option value="${g.id}">${g.name}</option>`)
                })
            } catch (error) {
                console.log(data, error);
            }
        }
    })
}

function CheckAcronym(id, acronym) {
    return new Promise((resolve, reject) => {
        //check acronym is available
        $.ajax({
            url: 'customer/CheckAcronymAvailable',
            type: 'get',
            data: { acronym, id },
            success: function (data) {
                let content = $.parseJSON(data);
                if (content.code == 409) {
                    return reject(content);
                }
                return resolve();
            }
        })

    })
}

function CheckEmail(id, email) {
    return new Promise((resolve, reject) => {
        //check mail is available
        $.ajax({
            url: 'customer/CheckMailAvailable',
            type: 'get',
            data: { email, id },
            success: function (data) {
                let content = $.parseJSON(data);
                if (content.code == 409) {
                    $.toast({
                        heading: content.heading,
                        text: content.msg,
                        icon: content.icon,
                        loader: true,        // Change it to false to disable loader
                        loaderBg: '#9EC600'  // To change the background
                    })
                    return reject(content);
                }
                return resolve();
            }
        })
    })
}

var $selectizeCustomerGroups = $('#slCustomerGroups');
$selectizeCustomerGroups.selectize({
    sortField: 'text' // Sắp xếp mục theo văn bản
});
var selectizeCustomerGroup = $selectizeCustomerGroups[0].selectize;


var qStyleRemark = new Quill('#divStyleRemark', {
    theme: 'snow', // Chọn giao diện "snow"
    modules: {
        toolbar: [
            ['bold', 'italic', 'underline'],
            [{ 'list': 'ordered' }, { 'list': 'bullet' }],
            ['link'], // Thêm nút chèn liên kết
            [{ 'color': ['#F00', '#0F0', '#00F', '#000', '#FFF', 'color-picker'] }], // Thêm nút chọn màu
        ]
    },
    placeholder: "Enter style remark here..."
});

var $selectizeColorModes = $('#slColorModes');
$selectizeColorModes.selectize({
    sortField: 'text' // Sắp xếp mục theo văn bản
});
var selectizeColorMode = $selectizeColorModes[0].selectize;

var $selectizeOutputs = $('#slOutputs');
$selectizeOutputs.selectize({
    sortField: 'text' // Sắp xếp mục theo văn bản
});
var selectizeOutput = $selectizeOutputs[0].selectize;

var $selectizeNationalStyles = $('#slNationalStyles');
$selectizeNationalStyles.selectize({
    sortField: 'text' // Sắp xếp mục theo văn bản
});
var selectizeNationalStyle = $selectizeNationalStyles[0].selectize;

var $selectizeClouds = $('#slClouds');
$selectizeClouds.selectize({
    sortField: 'text' // Sắp xếp mục theo văn bản
});
var selectizeCloud = $selectizeClouds[0].selectize;
