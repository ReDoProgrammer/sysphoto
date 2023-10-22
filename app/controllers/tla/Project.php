<?php
class Project extends TLAController
{
    private $__project_model;

    function __construct()
    {
        parent::__construct();
        $this->__project_model = $this->model("ProjectModel");
    }
    public function index()
    {
        $this->data['title'] = 'Projects List';
        $this->data['sub_content']['product'] = [];
        $this->data['content'] = 'tla/project/index';
        $this->render('__layouts/tla_layout', $this->data);
    }
    public function detail()
    {
        $this->data['title'] = 'Projects detail';
        $this->data['content'] = 'tla/project/detail';
        $this->data['sub_content'] = [];
        $this->render('__layouts/tla_layout', $this->data);
    }

    public function Send(){
        $id = $_POST['id'];
        $rs = $this->__project_model->Submit($id,'',5);
        if($rs['rows_changed']>0){
            $data = array(
                'code' => 200,
                'msg' => 'The project has been sent!',
                'icon'=>'success',
                'heading'=>'SUCCESSFULLY'               
            );
        }else{
            $data = array(
                'code' => 204,
                'msg' => 'Send project failed!',
                'icon' => 'success',
                'heading' => 'NO CONTENT!!'
            );
        }
        echo json_encode($data);
    }
    public function Upload(){
        $id = $_POST['id'];
        $url = $_POST['url'];
        $rs = $this->__project_model->Submit($id,$url);
        if($rs['rows_changed']>0){
            $data = array(
                'code' => 200,
                'msg' => 'The project has been uploaded with link!',
                'icon'=>'success',
                'heading'=>'SUCCESSFULLY'               
            );
        }else{
            $data = array(
                'code' => 204,
                'msg' => 'Upload project failed!',
                'icon' => 'success',
                'heading' => 'NO CONTENT!!'
            );
        }
        echo json_encode($data);
    }

    public function getList()
    {
        $from_date = $_GET['from_date'];
        $to_date = $_GET['to_date'];
        if (isset($_GET['stt'])) {
            $stt = $_GET['stt'];
        } else {
            $stt = [];
        }
        $search = $_GET['search'];
        $page = $_GET['page'];
        $limit = $_GET['limit'];

        $data = $this->__project_model->getList($from_date, $to_date, $stt, $search, $page, $limit);
        echo $data;
    }

    public function getdetail()
    {
        $id = $_GET['id'];
        $project = $this->__project_model->ProjectDetail($id);
        if ($project) {
            $data = array(
                'code' => 200,
                'msg' => 'Get project detail successfully!',
                'project' => $project
            );
        } else {
            $data = array(
                'code' => 404,
                'msg' => 'Project not found!',
                'icon' => 'success',
                'heading' => 'NO RESULT!!'
            );
        }

        echo json_encode($data);
    }

}