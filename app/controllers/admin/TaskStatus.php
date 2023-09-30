<?php
    class TaskStatus extends Controller{
        public $taskstatus_model;
        function __construct()
        {
            $this->taskstatus_model = $this->model('status_task');
        }
        

        public function getTaskStatusesList(){
            $tasks = $this->taskstatus_model->getList();       
    
            echo json_encode($tasks);
        }
    }