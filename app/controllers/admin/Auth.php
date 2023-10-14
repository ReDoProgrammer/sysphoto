<?php
    class Auth extends Controller{
        private $__employee_model;
        private $__role;
        function __construct(){
            $this->__employee_model = "EmployeeModel";
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
            echo $this->__employee_model->Login($email, $password, $this->__role);
    
        }
    }