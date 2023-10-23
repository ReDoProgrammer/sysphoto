<?php

class EmployeeGroup extends AdminController
{
    public $employee_group_model;
    
    function __construct()
    {
        parent::__construct();
        $this->employee_group_model = $this->model('EmployeeGroupModel');
    }

    public function List(){
        $data = [
            'code'=>200,
            'heading'=>'SUCCESSFULLY',
            'icon'=>'success',
            'msg'=>'Load all employee groups',
            'groups' => $this->employee_group_model->All()
        ]; 
        echo json_encode($data);
    }

}