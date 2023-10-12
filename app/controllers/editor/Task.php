<?php
    class Task extends Controller{
        private $__task_model;

        function  __construct(){
            $this->__task_model = "TaskModel";
        }
        public function index(){
            $this->data['title'] = 'Tasks List';
            $this->data['sub_content']['product'] = [];
             $this->data['content'] ='editor/task/index';
            $this->render('__layouts/editor_layout', $this->data);
        }
        public function GetTask(){
            $result = $this->__task_model->EditorGetTask();
            $data = ['msg'=>$result['msg']];
            echo json_encode($data);
        }
    }