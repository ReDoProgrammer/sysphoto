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
        function All(){          
            echo json_encode([
                'code'=>200,
                'icon'=>'success',
                'heading'=>'SUCCESSFULLY',
                'msg'=>'Load all Project statuses successfully!',
                'ps'=>$this->prjectstatus_model->AllProjectStatuses()
            ]);    
        }
    }