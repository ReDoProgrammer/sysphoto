<?php
    class ProjectStatus extends Controller{
        public $prjectstatus_model;
        function __construct()
        {
            $this->prjectstatus_model = $this->model('ProjectStatusModel');
        }
        function list(){
            $status = $this->prjectstatus_model->getList();   
            echo json_encode($status);    
        }
    }