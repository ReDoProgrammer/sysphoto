<?php
    class Home extends  DCController{
        function __construct(){
            parent::__construct();
        }
        public function index()
        {
            $this->data['title'] = 'DC Dashboard';
            $this->data['sub_content']['product'] = [];
             $this->data['content'] ='dc/dashboard/index';
            $this->render('__layouts/dc_layout', $this->data);
        }
    
    }