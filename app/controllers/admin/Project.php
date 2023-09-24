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
        $projects = $this->project_model->getList();       


        //renderview
        $this->data['title'] = 'Danh sách dự án';
        $this->data['sub_content']['projects'] = $projects;
        $this->data['content'] = 'admin/project/index';
        $this->render('__layouts/admin_layout', $this->data);
    }
}