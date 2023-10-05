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
        $this->data['sub_content'] = [];
        $this->render('__layouts/admin_layout', $this->data);
    }

    public function checkmailexists()
    {
        $email = $_GET['email'];
        if ($this->customer_model->CheckMailExists($email)) {
            $data = [
                'code' => 100,
                'msg' => 'Email is available',
                'icon' => 'info',
                'heading' => 'Available email address'
            ];
        }else{
            $data = [
                'code' => 409,
                'msg' => 'Email address already exists!',
                'icon' => 'warning',
                'heading' => 'Conflig email address'
            ];
        }
        echo json_encode($data);
    }
    public function create()
    {
        $group_id = $_POST['group_id'];
        $name = $_POST['name'];
        $email = $_POST['email'];
        $password = $_POST['password'];
        $customer_url = $_POST['customer_url'];
        $result = $this->customer_model->InsertCustomer($group_id, $name, $email, $password, $customer_url);
        if (is_int($result)) {
            $data = array(
                'code' => 201,
                'msg' => 'Customer has been inserted',
                'heading' => 'SUCCESSFULLY!',
                'icon' => 'success',
                'lastedid' => $result
            );
        } else {
            $data = array(
                'code' => 204,
                'msg' => 'Inserted new customer failed with error: ' . $result,
                'heading' => 'FAILED!',
                'icon' => 'danger'
            );
        }
        echo json_encode($data);
    }


    public function all(){
        $data = $this->customer_model->AllCustomer();
        echo json_encode(
            array(
                'code' => 200,
                'msg' => 'Get customers list successfully!',
                'customers' => $data
            )
        );
    }

    public function getList()
    {
        $page = $_GET['page'];
        $limit = $_GET['limit'];
        $group = $_GET['group'] ? intval($_GET['group']) : '';
        $search = $_GET['search'];
        $data = $this->customer_model->getList($page, $limit, $group, $search);
        echo json_encode(
            array(
                'code' => 200,
                'msg' => 'Get customers list successfully!',
                'data' => $data
            )
        );
    }
}