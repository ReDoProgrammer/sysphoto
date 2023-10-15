<?php
    class Home extends  QAController{
        function __construct(){
            parent::__construct();
        }
        public function index()
        {
            $this->data['title'] = 'QA Dashboard';
            $this->data['sub_content']['product'] = [];
             $this->data['content'] ='qa/dashboard/index';
            $this->render('__layouts/qa_layout', $this->data);
        }
    
    }