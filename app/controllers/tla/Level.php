<?php

class Level extends TLAController
{
    public $level_model;
    function __construct()
    {
        parent::__construct();
        $this->level_model = $this->model('LevelModel');
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