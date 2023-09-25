<?php
class Dashboard  extends Controller
{
    public $home_model;
    function __construct()
    {
        $this->home_model = $this->model('JobModel');
    }
    public function index()
    {
      
        $data = $this->home_model->getList();       
        $this->data['title'] = 'Admin Dashboard';
        $this->data['sub_content']['product'] = $data;
         $this->data['content'] ='admin/dashboard';
        $this->render('__layouts/admin_layout',$this->data);
    }
}