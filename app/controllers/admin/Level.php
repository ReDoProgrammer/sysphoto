<?php

class Level extends Controller
{
    public $level_model;
    function __construct()
    {
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
        $data = $this->level_model->getList();   
        echo $data;    
    }
}