<?php

class Employee extends Controller
{
    public $employee_model;
    private $__role = [1];
    function __construct()
    {
        $this->employee_model = $this->model('EmployeeModel');
    }

    function login()
    {
        $this->render('admin/employee/login');
    }
    function profile(){
        
    }

    function authLogin()
    {
        $email = $_POST['email'];
        $password = $_POST['password'];
        echo $this->employee_model->Login($email, $password, $this->__role);

    }
    public function index()
    {
        //renderview          
        $data = $this->employee_model->getList();


        //renderview
        $this->data['title'] = 'Employee list';
        $this->data['sub_content']['employee'] = $data;
        $this->data['content'] = 'admin/employee/index';
        $this->render('__layouts/admin_layout', $this->data);
    }

    private function get_client_ip()
    {
        if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
            return 'IP address = ' . $_SERVER['HTTP_CLIENT_IP'];
        }
        //if user is from the proxy  
        elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            return 'IP address = ' . $_SERVER['HTTP_X_FORWARDED_FOR'];
        }
        //if user is from the remote address  
        else {
            return 'IP address = ' . $_SERVER['REMOTE_ADDR'];
        }
    }
}