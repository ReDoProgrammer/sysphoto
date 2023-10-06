<?php

class Cloud extends Controller
{
    public $cloud_model;
    function __construct()
    {
        $this->cloud_model = $this->model('CloudModel');
    }
    public function index()
    {
        //renderview
        $this->data['title'] = 'Cloud list';
        $this->data['content'] = 'admin/cloud/index';
        $this->data['sub_content'] = [];
        $this->render('__layouts/admin_layout', $this->data);
    }

    public function all()
    {
        echo json_encode(
            array(
                'code' => 200,
                'msg' => 'Get clouds list successfully!',
                'icon' => 'success',
                'heading' => 'SUCCESSFULLY',
                'clouds' => $this->cloud_model->AllClouds()
            )
        );
    }
}