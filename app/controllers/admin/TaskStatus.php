<?php
    class TaskStatus extends AdminController{
        public $taskstatus_model;
        function __construct()
        {
            parent::__construct();
            $this->taskstatus_model = $this->model('TaskStatusModel');
        }
        

        public function all(){
            $statuses = $this->taskstatus_model->AllTaskStatuses();       
            $data = array(
                'code'=>200,
                'msg'=>'Get task status list successfully!',
                'statuses'=>$statuses
            );
            echo json_encode($data);          
        }
    }