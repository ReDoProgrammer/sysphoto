<?php
    class Project extends CSSController{
        private $__project_model;

        function  __construct(){
            parent::__construct();
            $this->__project_model = $this->model("ProjectModel");
        }
        public function index(){
            $this->data['title'] = 'Projects List';
            $this->data['sub_content']['product'] = [];
             $this->data['content'] ='css/project/index';
            $this->render('__layouts/css_layout', $this->data);
        }
        public function Eject(){
            $id = $_POST['id'];           
            $rs = $this->__project_model->Submit($id,'',5);
            if($rs['rows_changed']>0){
                $data = array(
                    'code' => 200,
                    'msg' => 'The project has been Sent!',
                    'icon'=>'success',
                    'heading'=>'SUCCESSFULLY'               
                );
            }else{
                $data = array(
                    'code' => 204,
                    'msg' => 'Send project failed!',
                    'icon' => 'success',
                    'heading' => 'NO CONTENT!!'
                );
            }
            echo json_encode($data);
        }

        public function Send(){
            $id = $_POST['id'];           
            $rs = $this->__project_model->Submit($id,'',5);
            if($rs['rows_changed']>0){
                $data = array(
                    'code' => 200,
                    'msg' => 'The project has been Sent!',
                    'icon'=>'success',
                    'heading'=>'SUCCESSFULLY'               
                );
            }else{
                $data = array(
                    'code' => 204,
                    'msg' => 'Send project failed!',
                    'icon' => 'success',
                    'heading' => 'NO CONTENT!!'
                );
            }
            echo json_encode($data);
        }

        public function getList()
        {
            $from_date = $_GET['from_date'];
            $to_date = $_GET['to_date'];
            if (isset($_GET['stt'])) {
                $stt = $_GET['stt'];
            } else {
                $stt = [];
            }
            $search = $_GET['search'];
            $page = $_GET['page'];
            $limit = $_GET['limit'];
    
            $data = $this->__project_model->getList($from_date, $to_date, $stt, $search, $page, $limit);
            echo $data;
        }
    
        
    }