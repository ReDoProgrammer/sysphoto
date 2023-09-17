<?php
class Home extends Controller
{
    public $home_model;
    function __construct()
    {       
       $this->home_model = $this->model('HomeModel');
    }
    public function index()
    {
        
        $data = $this->home_model->getProductList();
        $detail = $this->home_model->getDetail(1);
        // echo '<pre>';
        // print_r($data);
        // print_r($detail);
        // echo '</pre>';

        //renderview
        $this->data['product'] = $data;
        $this->data['detail'] = $detail;
        $this->render('Home/index',$this->data);
    }

    public function detail($id = '', $slug = '')
    {
        echo $id . '---' . $slug;
    }

    public function search()
    {
        $keyword = $_GET['keyword'];
        echo 'tu khoa can tim: ' . $keyword;
    }
}