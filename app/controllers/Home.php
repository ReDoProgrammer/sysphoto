<?php
class Home extends Controller
{
    public $home_model;
    function __construct()
    {       
       $this->home_model = $this->model('JobModel');
    }
    public function index()
    {
        
        $data = $this->home_model->getList();
   
       
        //renderview
        $this->data['title'] = 'Danh sách sản phẩm';
        $this->data['sub_content']['product'] = $data;
         $this->data['content'] ='Home/index';
        $this->render('__layouts/client_layout',$this->data);
    }

    public function get_request(){
        $request = new Request();
        echo $request->getMethod();
        $this->render('home/form');
    }
    public function post_request(){
        $request = new Request();
        echo $request->getMethod();
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