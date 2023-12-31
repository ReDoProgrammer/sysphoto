$('#btnLogin').click(function () {
    let email = $('#txtEmail').val();
    let password = $('#txtPassword').val();
    if (!isEmail(email)) {
        $.toast({
            heading: 'Error',
            text: 'Email address is not valid!',
            showHideTransition: 'fade',
            icon: 'error'
        })
        return;
    }
    if (password.trim().length == 0) {
        $.toast({
            heading: 'Error',
            text: 'Password can not be empty!',
            showHideTransition: 'fade',
            icon: 'error'
        })
        return;
    }


    $.ajax({
        url: 'auth/authLogin',
        type: 'post',
        data: { email, password },
        success: function (data) {
            try {
                let auth = JSON.parse(data);
                console.log(auth);
                if (auth.code == 200) {
                    $(location).prop('href', 'home')
                }
                $.toast({
                    heading: auth.heading,
                    text: auth.msg,
                    showHideTransition: 'fade',
                    icon: auth.icon
                })
            } catch (error) {
                console.log(data, error);
            }
        }
    })

})