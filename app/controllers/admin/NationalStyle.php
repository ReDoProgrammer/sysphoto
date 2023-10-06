<?php

class NationalStyle extends Controller
{
    public $nationalstyle_model;
    function __construct()
    {
        $this->nationalstyle_model = $this->model('NationalStyleModel');
    }
    public function index()
    {
        $this->data['title'] = 'National Style list';
        $this->data['content'] = 'admin/nationalstyle/index';
        $this->data['sub_content'] = [];
        $this->render('__layouts/admin_layout', $this->data);
    }

    public function all()
    {
        echo json_encode(
            array(
                'code' => 200,
                'msg' => 'Get all national styles list successfully!',
                'styles' => $this->nationalstyle_model->AllNationalStyle()
            )
        );

    }
}