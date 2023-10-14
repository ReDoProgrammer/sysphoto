<?php
class Auth extends Controller
{
    private $__employee_model;
    private $__role;
    function __construct()
    {
        $this->__employee_model = $this->model("EmployeeModel");
        $this->__role = 1;
    }
    function login()
    {
        $this->render('admin/employee/login');
    }
    function authLogin()
    {
        $email = $_POST['email'];
        $password = $_POST['password'];
        $result = ($this->__employee_model->Login($email, $password, $this->__role))["result"];
        $js = json_decode($result, true);
        if ($js['code'] == 200) {
            $user = new User(
                $id = $js['id'],
                $fullname = $js['fullname'],
                $acronym = $js['acronym'],
                $email = $js['email'],
                $role_id = $js['role_id'],
                $role_name = $js['role_name'],
                $task_getable = $js['task_getable']
            );
            $_SESSION['user'] = serialize($user);
        }
        echo $result;
    }
}