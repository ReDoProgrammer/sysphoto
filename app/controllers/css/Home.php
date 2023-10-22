<?php
    class Home extends  CSSController{
        function __construct(){
            parent::__construct();
        }
        public function index()
        {
            $this->data['title'] = 'TLA Dashboard';
            $this->data['sub_content']['product'] = [];
             $this->data['content'] ='tla/dashboard/index';
            $this->render('__layouts/tla_layout', $this->data);
        }
    
    }