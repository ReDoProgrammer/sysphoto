<?php

class Employee extends Controller
{
    public $employee_model;
    function __construct()
    {
        $this->employee_model = $this->model('EmployeeModel');
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
}