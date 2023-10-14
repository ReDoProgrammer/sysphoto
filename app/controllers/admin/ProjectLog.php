<?php

class ProjectLog extends AdminController
{
    public $projectlog_model;
    function __construct()
    {
        parent::__construct();
        $this->projectlog_model = $this->model('ProjectLogModel');
    }



    public function list()
    {
        $projectId = intval($_GET['projectId']);
        echo json_encode([
            'code' => 200,
            'msg' => 'Get project logs successfully!',
            'icon' => 'success',
            'heading' => 'SUCCESSFULLY',
            'logs' => $this->projectlog_model->GetLogs($projectId)
        ]);
    }
}