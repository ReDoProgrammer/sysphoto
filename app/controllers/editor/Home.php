<?php
    class Home extends  EditorController{
        function __construct(){
            parent::__construct();
        }
        public function index()
        {
            $this->data['title'] = 'Editor Dashboard';
            $this->data['sub_content']['product'] = [];
             $this->data['content'] ='editor/dashboard/index';
            $this->render('__layouts/editor_layout', $this->data);
        }
    
    }