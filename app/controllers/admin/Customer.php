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

    public function CheckMailAvailable()
    {
        $email = $_GET['email'];
        $id = $_GET['id'];
        if ($this->customer_model->CheckMailExists($email, $id)) {
            $data = [
                'code' => 100,
                'msg' => 'Email is available',
                'icon' => 'info',
                'heading' => 'Available email address'
            ];
        } else {
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

        $color_mode = $_POST['color_mode'];
        $output = $_POST['output'];
        $size = $_POST['size'];
        $is_straighten = $_POST['is_straighten'] ? 1 : 0;
        $straighten_remark = $_POST['straighten_remark'];
        $tv = $_POST['tv'];
        $fire = $_POST['fire'];
        $sky = $_POST['fire'];
        $grass = $_POST['grass'];
        $nationtal_style = $_POST['nationtal_style'];
        $cloud = $_POST['cloud'];
        $style_remark = $_POST['style_remark'];

        $result = $this->customer_model->InsertCustomer(
            $group_id,
            $name,
            $email,
            $password,
            $customer_url,
            $color_mode,
            $output,
            $size,
            $is_straighten,
            $straighten_remark,
            $tv,
            $fire,
            $sky,
            $grass,
            $nationtal_style,
            $cloud,
            $style_remark
        );
        if (is_int($result['last_id'])) {
            $data = array(
                'code' => 201,
                'msg' => 'Customer has been inserted',
                'heading' => 'SUCCESSFULLY!',
                'icon' => 'success',
                'lastedid' => $result['last_id']
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

    public function update()
    {
        $id = $_POST['id'];
        $group_id = $_POST['group_id'];
        $name = $_POST['name'];
        $email = $_POST['email'];
        $password = $_POST['password'];
        $customer_url = $_POST['customer_url'];

        $color_mode = $_POST['color_mode'];
        $output = $_POST['output'];
        $size = $_POST['size'];
        $is_straighten = $_POST['is_straighten'] ? 1 : 0;
        $straighten_remark = $_POST['straighten_remark'];
        $tv = $_POST['tv'];
        $fire = $_POST['fire'];
        $sky = $_POST['fire'];
        $grass = $_POST['grass'];
        $nationtal_style = $_POST['nationtal_style'];
        $cloud = $_POST['cloud'];
        $style_remark = $_POST['style_remark'];

        $result = $this->customer_model->UpdateCustomer(
            $id,
            $group_id,
            $name,
            $email,
            $password,
            $customer_url,
            $color_mode,
            $output,
            $size,
            $is_straighten,
            $straighten_remark,
            $tv,
            $fire,
            $sky,
            $grass,
            $nationtal_style,
            $cloud,
            $style_remark
        );
        if ($result['rows_changed']>0) {
            $data = array(
                'code' => 200,
                'msg' => 'Customer has been updated',
                'heading' => 'SUCCESSFULLY!',
                'icon' => 'success',
                'rows_changed' => $result['rows_changed']
            );
        } else {
            $data = array(
                'code' => 304 ,
                'msg' => 'Update customer failed or no detail changed!',
                'heading' => 'FAILED!',
                'icon' => 'danger'
            );
        }
        echo json_encode($data);
    }


    public function GetDetail()
    {
        $id = $_GET['id'];
        $result = $this->customer_model->CustomerDetail($id);
        if (count($result) > 0) {
            $data = [
                'code' => 200,
                'msg' => 'Get customer detail successfully!',
                'icon' => 'success',
                'heading' => 'SUCCESSFULLY',
                'customer' => $result[0]
            ];
        } else {
            $data = [
                'code' == 404,
                'msg' => 'Customer not found',
                'icon' => 'warning',
                'heading' => 'NO CONTENT'
            ];
        }
        echo json_encode($data);
    }


    public function all()
    {
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