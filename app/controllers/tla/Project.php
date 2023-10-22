<?php
    class Project extends TLAController{
        private $__project_model;

        function  __construct(){
            parent::__construct();
            $this->__project_model = $this->model("ProjectModel");
        }
        public function index(){
            $this->data['title'] = 'Projects List';
            $this->data['sub_content']['product'] = [];
             $this->data['content'] ='tla/project/index';
            $this->render('__layouts/tla_layout', $this->data);
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