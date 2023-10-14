<?php

class Combo extends AdminController
{
    public $combo_model;
    function __construct()
    {
        parent::__construct();
        $this->combo_model = $this->model('ComboModel');
    }
    public function index()
    {
        //renderview
        $this->data['title'] = 'Comboes list';
        $this->data['content'] = 'admin/combo/index';
        $this->data['sub_content'] = [];
        $this->render('__layouts/admin_layout', $this->data);
    }

    public function getList()
    {
        $data = $this->combo_model->getList();   
        echo $data;    
    }
}