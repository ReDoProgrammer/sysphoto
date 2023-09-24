<?php
    class JobStatus extends Controller{
        public $jobstatus_model;
        function __construct()
        {
            $this->jobstatus_model = $this->model('JobStatusModel');
        }
        function list(){
            $status = $this->jobstatus_model->getList();   
            echo json_encode($status);    
        }
    }