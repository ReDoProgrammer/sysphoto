<?php
class CustomerGroup extends Controller
{
    public $customer_group_model;
    function __construct()
    {
        $this->customer_group_model = $this->model('CustomerGroupModel');
    }
    public function list()
    {
        echo json_encode(
            array(
                'code' => 200,
                'msg' => 'Get customer groups successfully!',
                'icon' => 'success',
                'heading' => 'SUCCESSFULLY',
                'groups' => $this->customer_group_model->getList()
            )
        );
    }
}