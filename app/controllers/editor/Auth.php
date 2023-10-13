<?php
class Auth extends Controller
{
    private $__employee_model;
    private $__role; //editor
    function __construct()
    {
        $this->__employee_model = $this->model("EmployeeModel");
        $this->__role = 6;
    }
    public function login()
    {
        $this->render('editor/user/login');
    }
    public function AuthLogin()
    {
        $email = $_POST['email'];
        $pwd = $_POST['password'];
        $result = ($this->__employee_model->Login($email, $pwd, $this->__role))["result"];
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
            $_SESSION['user']= serialize($user);
        }
        echo $result;
    }
}