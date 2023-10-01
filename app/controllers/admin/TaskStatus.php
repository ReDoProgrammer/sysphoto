<?php
    class TaskStatus extends Controller{
        public $taskstatus_model;
        function __construct()
        {
            $this->taskstatus_model = $this->model('TaskStatusModel');
        }
        

        public function list(){
            $statuses = $this->taskstatus_model->getList();       
            $data = array(
                'code'=>200,
                'msg'=>'Get task status list successfully!',
                'statuses'=>$statuses
            );
            echo json_encode($data);          
        }
    }