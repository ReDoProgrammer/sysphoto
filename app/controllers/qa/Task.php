<?php
    class Task extends QAController{
        private $__task_model;

        function  __construct(){
            parent::__construct();
            $this->__task_model = $this->model("TaskModel");
        }
        public function index(){
            $this->data['title'] = 'Tasks List';
            $this->data['sub_content']['product'] = [];
             $this->data['content'] ='qa/task/index';
            $this->render('__layouts/qa_layout', $this->data);
        }
        public function GetTask(){
            $role = $_GET['role'];
            $result = $this->__task_model->GetTask($role);        
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
        public function fetch(){           
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

        public function Submit(){
            $id = $_POST['id'];
            $url = $_POST['url'];
            $result = $this->__task_model->EditorSubmitTask($id,$url);

            if($result['updated_rows']>0){
                $data =[
                    'code'=>200,
                    'icon'=>'success',
                    'heading'=>'SUCCESSFULLY',
                    'msg'=>'You have submitted the task successfully.'
                ];
            }else{
                $data =[
                    'code'=>204,
                    'icon'=>'warning',
                    'heading'=>'WARNING',
                    'msg'=>'The task submission failed.'
                ];
            }
            echo json_encode($data);
        }
        public function Reject(){
            $id = $_POST['id'];
            $remark = $_POST['remark'];
            $read_instructions = $_POST['read_instructions'];

            $result = $this->__task_model->RejectTask($id,$remark,$read_instructions);
            if($result['updated_rows']>0){
                $data =[
                    'code'=>200,
                    'icon'=>'success',
                    'heading'=>'SUCCESSFULLY',
                    'msg'=>'You have submitted the task successfully.'
                ];
            }else{
                $data =[
                    'code'=>204,
                    'icon'=>'warning',
                    'heading'=>'WARNING',
                    'msg'=>'The task submission failed.'
                ];
            }
            echo json_encode($data);

        }
    }