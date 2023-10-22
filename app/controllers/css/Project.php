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
        
    }