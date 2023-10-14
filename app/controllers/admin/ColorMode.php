<?php

class ColorMode extends AdminController
{
    public $colormode_model;
    function __construct()
    {
        parent::__construct();
        $this->colormode_model = $this->model('ColorModeModel');
    }
    public function index()
    {
        //renderview
        $this->data['title'] = 'Color mode list';
        $this->data['content'] = 'admin/colormode/index';
        $this->data['sub_content'] = [];
        $this->render('__layouts/admin_layout', $this->data);
    }

    public function all()
    {
        echo json_encode(
            array(
                'code' => 200,
                'msg' => 'Get color modes list successfully!',
                'icon' => 'success',
                'heading' => 'SUCCESSFULLY',
                'colormodes' => $this->colormode_model->AllColorModes()
            )
        );
    }
}