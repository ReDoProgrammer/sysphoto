<?php

class Customer extends Controller
{
    public $customer_model;
    function __construct()
    {
        $this->customer_model = $this->model('CustomerModel');
    }
    public function index()
    {
        //renderview          



        //renderview
        $this->data['title'] = 'Cutomers list';
        $this->data['content'] = 'admin/customer/index';
        $this->data['sub_content'] = [];
        $this->render('__layouts/admin_layout', $this->data);
    }

    public function getList()
    {
        $data = $this->customer_model->getList();   
        echo $data;    
    }
}