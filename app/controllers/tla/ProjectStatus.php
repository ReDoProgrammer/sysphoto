<?php
    class ProjectStatus extends TLAController{
        public $prjectstatus_model;
        function __construct()
        {
            parent::__construct();
            $this->prjectstatus_model = $this->model('ProjectStatusModel');
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
        function GetInvisibleStatuses(){          
            echo json_encode([
                'code'=>200,
                'icon'=>'success',
                'heading'=>'SUCCESSFULLY',
                'msg'=>'Load invisible statuses successfully!',
                'ps'=>$this->prjectstatus_model->GetInvisibleStatuses()
            ]);    
        }
    }