<?php

class Level extends AdminController
{
    public $level_model;
    function __construct()
    {
        parent::__construct();
        $this->level_model = $this->model('LevelModel');
    }
    public function index()
    {
        //renderview          



        //renderview
        $this->data['title'] = 'Levels list';
        $this->data['content'] = 'admin/level/index';
        $this->data['sub_content'] = [];
        $this->render('__layouts/admin_layout', $this->data);
    }

    public function getList()
    {
        $data = array(
            'code' => 200,
            'msg' => 'Get all task levels list successfully!',
            'levels' => $this->level_model->getList()
        );
        echo json_encode($data);

    }
}