<?php
    class Task extends EditorController{
        private $__task_model;

        function  __construct(){
            parent::__construct();
            $this->__task_model = $this->model("TaskModel");
        }
        public function index(){
            $this->data['title'] = 'Tasks List';
            $this->data['sub_content']['product'] = [];
             $this->data['content'] ='editor/task/index';
            $this->render('__layouts/editor_layout', $this->data);
        }
        public function GetTask(){
            $result = $this->__task_model->EditorGetTask();        
            echo $result['msg'];
        }

        public function ViewDetail(){
            $id = $_GET['id'];
            $result = $this->__task_model->GetDetail($id);
            if(!empty($result)){
                $data = [
                    'code'=>200,
                    'icon'=>'success',
                    'heading'=>'SUCCESSFULLY',
                    'msg'=>'Get task detail successfully.',
                    'task'=>$result[0]
                ];
            }else{
                $data = [
                    'code'=>404,
                    'icon'=>'warning',
                    'heading'=>'Not Found',
                    'msg'=>'Task not found.'
                ];
            }
            echo json_encode($data);
        }
        public function fectch(){           
            $from_date =  (DateTime::createFromFormat('d/m/Y H:i:s', $_GET['from_date'].":00"))->format('Y-m-d H:i:s');
            $to_date =  (DateTime::createFromFormat('d/m/Y H:i:s', $_GET['to_date'].":00"))->format('Y-m-d H:i:s');
            $status = $_GET['status'];           
            $page = $_GET['page'];
            $limit = $_GET['limit'];
            echo json_encode([
                'code'=>200,
                'msg'=>'Successfully fetch the tasks.',
                'icon'=>'success',
                'heading'=>'SUCCESSFULLY',
                'tasks'=>$this->__task_model->GetOwnerTasks($from_date,$to_date,$status,$page,$limit)
            ]);
        }
    }