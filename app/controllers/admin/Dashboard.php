<?php
class Dashboard  extends Controller
{
    public $home_model;
    function __construct()
    {
        $this->home_model = $this->model('ProjectModel');
    }
    public function index()
    {
      
      
        $this->data['title'] = 'Admin Dashboard';
        $this->data['sub_content']['product'] = [];
         $this->data['content'] ='admin/dashboard';
        $this->render('__layouts/admin_layout', $this->data);
    }
}