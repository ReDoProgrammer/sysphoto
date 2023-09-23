<?php

class Project extends Controller
{
    public $project_model;
    function __construct()
    {
        $this->project_model = $this->model('ProjectModel');
    }
    public function index()
    {
        //renderview          
        $data = $this->project_model->getList();

        echo '<pre>';
        print_r($data);
        echo '</pre>';


        //renderview
        $this->data['title'] = 'Danh sách dự án';
        $this->data['sub_content']['project'] = [];
        $this->data['content'] = 'admin/project/index';
        $this->render('__layouts/admin_layout', $this->data);
    }
}