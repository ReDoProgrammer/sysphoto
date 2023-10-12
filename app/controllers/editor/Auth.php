<?php
    class Auth extends   Controller{
        private $__employee_model;
        private $__role; //editor
        function __construct(){
            $this->__employee_model = $this->model("EmployeeModel");
            $this->__role = 6;
        }
        public function login(){
            $this->render('editor/user/login');
        }
        public function AuthLogin(){
            $email = $_POST['email'];
            $pwd = $_POST['password'];
            $result = $this->__employee_model->Login($email, $pwd, $this->__role);
            $data = json_decode($result, true);
            echo $data['code'];
            // echo '<pre>';
            // print_r($result);
            // // echo $result['result']['fullname'];

            // echo '</pre>';
            // echo json_encode($this->__employee_model->Login($email, $pwd, $this->__role));
        }
    }