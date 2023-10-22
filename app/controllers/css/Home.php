<?php
    class Home extends  CSSController{
        function __construct(){
            parent::__construct();
        }
        public function index()
        {
            $this->data['title'] = 'CSS Dashboard';
            $this->data['sub_content']['product'] = [];
             $this->data['content'] ='css/dashboard/index';
            $this->render('__layouts/css_layout', $this->data);
        }
    
    }