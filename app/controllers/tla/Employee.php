<?php

class Employee extends TLAController
{
    public $employee_model;
    
    function __construct()
    {
        parent::__construct();
        $this->employee_model = $this->model('EmployeeModel');
    }


    function getEditors()
    {
        $level = $_GET['level'];
        $employees = $this->employee_model->getEditors($level);
        $data = array(
            'code' => 200,
            'msg' => 'Get editors based on task level successfully!',
            'editors' => $employees
        );
        echo json_encode($data);
    }

    function getQAs(){
        $level = $_GET['level'];
        $employees = $this->employee_model->getQAs($level);
        $data = array(
            'code' => 200,
            'msg' => 'Get QAs based on task level successfully!',
            'qas' => $employees
        );
        echo json_encode($data);
    }


   
    function profile()
    {

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