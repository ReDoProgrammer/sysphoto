<?php

class Output extends Controller
{
    public $output_model;
    function __construct()
    {
        $this->output_model = $this->model('OutputModel');
    }
    public function index()
    {
        //renderview          



        //renderview
        $this->data['title'] = 'Output list';
        $this->data['content'] = 'admin/output/index';
        $this->data['sub_content'] = [];
        $this->render('__layouts/admin_layout', $this->data);
    }

    public function all()
    {
        echo json_encode(
            array(
                'code' => 200,
                'msg' => 'Get all outputs format list successfully!',
                'outputs' => $this->output_model->AllOutput()
            )
        );

    }
}