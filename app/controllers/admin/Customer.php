<?php

class Customer extends Controller
{
    public $customer_model;

    function __construct()
    {
        $this->customer_model = $this->model('CustomerModel');
        $this->customer_group_model = $this->model('CustomerGroupModel');
    }
    public function index()
    {
        //renderview
        $this->data['title'] = 'Customers list';
        $this->data['content'] = 'admin/customer/index';
        $this->data['sub_content']['customer_groups'] = $this->customer_group_model->getList();
        $this->render('__layouts/admin_layout', $this->data);
    }

    public function getList()    
    {
        $page = $_GET['page'];
        $limit = $_GET['limit'];
        $group = $_GET['group']?intval($_GET['group']):'';
        $search = $_GET['search'];
        $data = $this->customer_model->getList($page,$limit,$group,$search);   
        echo json_encode(array(
            'code'=>200,
            'msg'=>'Get customers list successfully!',
            'data'=>$data
        ));    
    }
}