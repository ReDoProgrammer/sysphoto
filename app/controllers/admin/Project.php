<?php

class Project extends Controller
{
    public $project_model;
    function __construct()
    {
        $this->project_model = $this->model('ProjectModel');
    }
    public function index()
    {
        //renderview
        $this->data['title'] = 'Projects list';
        $this->data['content'] = 'admin/project/index';
        $this->data['sub_content'] = [];
        $this->render('__layouts/admin_layout', $this->data);
    }
    public function detail()
    {

        $id = $_GET['id'];
        $this->data['title'] = 'Projects detail';
        $this->data['content'] = 'admin/project/detail';
        $this->data['sub_content']['details'] = $this->project_model->detail($id);
        $this->render('__layouts/admin_layout', $this->data);
    }

    public function create()
    {
        $customer = $_POST['customer'];
        $name = $_POST['name'];
        $start_date = date("Y-m-d H:i:s", strtotime($_POST['start_date']));
        $end_date = date("Y-m-d H:i:s", strtotime($_POST['end_date']));
        $status = $_POST['status'];
        $combo = !empty($_POST['combo']) ? $_POST['combo'] : 0;
        $levels = strval(!empty($_POST['templates']) ? implode(',', $_POST['templates']) : '');
        $priority = $_POST['priority'];
        $description = $_POST['description'];
        $instruction = $_POST['instruction'];

        // $user = unserialize($_SESSION['user']);        
        // $user_id = str_replace(['<br/>', '<br>', '<br />'], '', $user->id);
        
        $user_id = 2;

        $params = array(
            'customer_id' => $customer,
            'name' => $name,
            'start_date' => $start_date,
            'end_date' => $end_date,
            'status_id' => $status,
            'combo_id' => $combo,
            'levels'=> $levels,
            'priority' => $priority,
            'description' => $description,
            'created_by' => $user_id// nếu thay bằng 1 thì sẽ phát sinh lỗi.???
        );
        print_r($params);

        $pid = $this->project_model->callFunction("ProjectInsert", $params);
     

        // if($pid>0){
        //     if(!empty(trim($instruction))){
        //         //thêm instruction vào csdl
        //         $params = array(
        //             'project_id'=>$pid,
        //             'content'=>$instruction,
        //             'created_by'=>$user_id
        //         );
        //         $piid = $this->project_model->callMySqlFunction("ProjectInstructionInsert", $params);
        //         if(!empty($_POST['templates'])){
        //             //thêm task tự động 
        //             $levels = $_POST['templates'];
        //             foreach($levels as $l){
        //                 $params = array(
        //                     'project_id'=>$pid,
        //                     'level_id'=>$l,
        //                     'created_by'=>$user_id
        //                 );
        //                 $tid = $this->project_model->callMySqlFunction("TaskInsertAuto", $params);
        //             }
        //         }
        //     }
        //     $data = array(
        //         'code'=>201,
        //         'msg'=>'Project has been created successfully!',
        //         'heading'=>'SUCCESSFULLY',
        //         'icon'=>'success'
        //     );
        // }else{
        //     $data = array(
        //         'code'=>204,
        //         'msg'=>'Create new project failed!',
        //         'heading'=>'FAILED',
        //         'icon'=>'danger'
        //     );
        // }

        // echo json_encode($data);

    }

    public function update()
    {
        $id = $_POST['id'];

        $customer = $_POST['customer'];
        $name = $_POST['name'];
        $start_date = $_POST['start_date'];
        $status = $_POST['status_id'];
        $end_date = $_POST['end_date'];
        $combo = !empty($_POST['combo']) ? $_POST['combo'] : 0;
        $templates = !empty($_POST['templates']) ? implode(',', $_POST['templates']) : '';
        $urgent = $_POST['urgent'];
        $description = $_POST['description'];
        $instruction = $_POST['instruction'];
        $data = array(
            'customer_id' => $customer,
            'name' => $name,
            'description' => $description,
            // 'instruction' => $instruction,
            'start_date' => (DateTime::createFromFormat('d/m/Y H:i', $start_date))->format('Y-m-d H:i'),
            'end_date' => (DateTime::createFromFormat('d/m/Y H:i', $end_date))->format('Y-m-d H:i'),
            'status_id' => $status,
            'level_id' => $templates,
            'priority' => $urgent,
            'combo_id' => $combo
        );
        $result = $this->project_model->updateProject($id, $data);

        if ($result) {
            $data = array(
                'code' => 200,
                'msg' => 'The project has been updated.',
                'heading' => 'Successfully!',
                'icon' => 'success'
            );
        } else {
            $data = array(
                'code' => 204,
                'msg' => 'Update project failed.',
                'heading' => 'FAILED!',
                'icon' => 'warning'
            );
        }

        echo json_encode($data);
    }

    public function delete()
    {
        $id = $_POST['id'];
        if ($this->project_model->deleteProject($id)) {
            $data = array(
                'code' => 200,
                'msg' => 'Project has been deleted.',
                'icon' => 'success',
                'heading' => 'SUCCESS!!!'
            );
        } else {
            $data = array(
                'code' => 204,
                'msg' => 'Delete project failed.',
                'icon' => 'warning',
                'heading' => 'OPPP!!'
            );
        }
        echo json_encode($data);
    }

    public function getdetail()
    {
        $id = $_GET['id'];
        $projects = $this->project_model->detail($id);
        if (count($projects) > 0) {
            $data = array(
                'code' => 200,
                'msg' => 'Get project detail successfully!',
                'project' => $projects[0]
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

        $data = $this->project_model->getList($from_date, $to_date, $stt, $search, $page, $limit);
        echo $data;
    }
}