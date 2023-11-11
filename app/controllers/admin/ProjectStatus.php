<?php
    class ProjectStatus extends AdminController{
        public $prjectstatus_model;
        function __construct()
        {
            parent::__construct();
            $this->prjectstatus_model = $this->model('ProjectStatusModel');
        }
        public function index()
        {
            //renderview
            $this->data['title'] = 'Project status list';
            $this->data['content'] = 'admin/project_status/index';
            $this->data['sub_content'] = [];
            $this->render('__layouts/admin_layout', $this->data);
        }

        public function add(){
            $name = $_POST['name'];
            $color = $_POST['color'];
            $description = $_POST['description'];
            $visible = $_POST['visible'];
            $result = $this->prjectstatus_model->add($name, $color, $description, $visible);    
            if($result){
                $data = [
                    'code'=>201,
                    'icon'=>'success',
                    'heading'=> 'SUCCESSFULLY',
                    'msg'=>'The project status has been inserted'
                ];
            }else{
                $data = [
                    'code'=>500,
                    'icon'=>'error',
                    'heading'=> 'FAILED',
                    'msg'=>'Insert project status failed due to an error: '+ $result
                ];
            }
            echo json_encode($data);
        }
        public function edit(){
            $id = $_POST['id'];
            $name = $_POST['name'];
            $color = $_POST['color'];
            $description = $_POST['description'];
            $visible = $_POST['visible'];
            $result = $this->prjectstatus_model->edit($id,$name, $color, $description, $visible);    
            if($result){
                $data = [
                    'code'=>200,
                    'icon'=>'success',
                    'heading'=> 'SUCCESSFULLY',
                    'msg'=>'The project status has been updated'
                ];
            }else{
                $data = [
                    'code'=>500,
                    'icon'=>'error',
                    'heading'=> 'FAILED',
                    'msg'=>'Update project status failed due to an error: '+ $result
                ];
            }
            echo json_encode($data);
        }
        public function delete(){   
            $id = $_POST['id'];
            $result = $this->prjectstatus_model->destroy($id);
            if($result ){
                $data = [
                    'code'=>200,
                    'icon'=>'success',
                    'heading'=> 'SUCCESSFULLY',
                    'msg'=>'The project status has been deleted'
                ];
            }else{
                $data = [
                    'code'=>500,
                    'icon'=>'error',
                    'heading'=> 'FAILED',
                    'msg'=>'Delete project status failed due to an error: '+ $result
                ];
            }
            echo json_encode($data);
        }

        public function detail(){
            $id = $_GET['id'];
            $result = $this->prjectstatus_model->detail($id);
            if($result){
                $data = [
                    'code'=> 200,
                    'icon'=> 'success',
                    'msg'=> 'Get project status detail successfully',
                    'stt'=> $result[0]
                ];
            }else{
                $data = [
                    'code'=> 500,
                    'icon'=> 'error',
                    'msg'=>'Can not get project status detail due error: '.$result
                ];                    
            }
            echo json_encode($data);
        }
        function All(){          
            echo json_encode([
                'code'=>200,
                'icon'=>'success',
                'heading'=>'SUCCESSFULLY',
                'msg'=>'Load all Project statuses successfully!',
                'ps'=>$this->prjectstatus_model->AllProjectStatuses()
            ]);    
        }

        function InitStatus(){
            echo json_encode([
                'code'=>200,
                'icon'=>'success',
                'heading'=>'SUCCESSFULLY',
                'msg'=>'Load init Project statuses successfully!',
                'ps'=>$this->prjectstatus_model->InitStatuses()
            ]);    
        }
    }