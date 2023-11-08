<?php

class Project extends AdminController
{
    public $project_model;
    public $project_instruction_model;
    function __construct()
    {
        parent::__construct();
        $this->project_model = $this->model('ProjectModel');
        $this->project_instruction_model = $this->model('ProjectInstructionModel');
    }

    public function index()
    {
        //renderview
        $this->data['title'] = "Projects List";
        $this->data['content'] = 'admin/project/index';
        $this->data['sub_content'] = [];
        $this->render('__layouts/admin_layout', $this->data);
    }
    public function detail()
    {
        $this->data['title'] = 'Projects detail';
        $this->data['content'] = 'admin/project/detail';
        $this->data['sub_content'] = [];
        $this->render('__layouts/admin_layout', $this->data);
    }

    public function create()
    {

        $customer = $_POST['customer'];
        $name = $_POST['name'];

        $start_date = (DateTime::createFromFormat('d/m/Y H:i:s', $_POST['start_date']))->format('Y-m-d H:i:s');
        $end_date = (DateTime::createFromFormat('d/m/Y H:i:s', $_POST['end_date']))->format('Y-m-d H:i:s');

        $combo = !empty($_POST['combo']) ? $_POST['combo'] : 0;
        $levels = !empty($_POST['templates']) ? implode(',', $_POST['templates']) : '';
        $priority = $_POST['priority'];
        $description = $_POST['description'];
        $instruction = $_POST['instruction'];

        $result = $this->project_model->CreateProject($customer, $name, $start_date, $end_date, $combo, $levels, $priority, $description);
        if ($result['last_id'] > 0) {
            if (!empty(trim($instruction))) {
                //thêm instruction vào csdl
                $this->project_instruction_model->InsertInstruction($result['last_id'], $instruction);
            }
            $data = array(
                'code' => 201,
                'msg' => 'Project has been created successfully!',
                'heading' => 'SUCCESSFULLY',
                'icon' => 'success'
            );
        } else {
            $data = array(
                'code' => 204,
                'msg' => 'Create new project failed!',
                'heading' => 'FAILED',
                'icon' => 'danger'
            );
        }
        echo json_encode($data);
    }

    public function update()
    {
        $id = $_POST['id'];
        $customer = $_POST['customer'];
        $name = $_POST['name'];

        $start_date = (DateTime::createFromFormat('d/m/Y H:i:s', $_POST['start_date']))->format('Y-m-d H:i:s');
        $end_date = (DateTime::createFromFormat('d/m/Y H:i:s', $_POST['end_date']))->format('Y-m-d H:i:s');

        $combo = !empty($_POST['combo']) ? $_POST['combo'] : 0;
        $levels = !empty($_POST['templates']) ? implode(',', $_POST['templates']) : '';
        $priority = $_POST['priority'];
        $description = $_POST['description'];
        $instruction = $_POST['instruction'];

        $result = $this->project_model->UpdateProject($id, $customer, $name, $start_date, $end_date, $combo, $levels, $priority, $description);

        if ($result) {
            $this->project_instruction_model->UpdateInstruction($id, $instruction);
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

    public function addinstruction(){
        $id = $_POST['id'];
        $instruction = $_POST['instruction'];
        $result = $this->project_model->AddInstruction($id,$instruction);
        if($result['last_id']>0){
            $data = array(
                'code' => 201,
                'msg' => 'Instruction has been inserted successfully!',
                'heading' => 'SUCCESSFULLY',
                'icon' => 'success'
            );
            
        }else{
            $data = array(
                'code' => 204,
                'msg' => 'Insert instruction failed!',
                'heading' => 'FAILED',
                'icon' => 'danger'
            );
        }
        echo json_encode($data);
    }

    public function getdetail()
    {
        $id = $_GET['id'];
        $project = $this->project_model->ProjectDetail($id);
        $stats = $this->project_model->StatTasksByStatus($id);
        if ($project) {
            $data = array(
                'code' => 200,
                'msg' => 'Get project detail successfully!',
                'project' => $project,
                'stats'=>$stats
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
        $from_date = (DateTime::createFromFormat('d/m/Y H:i:s', $_GET['from_date'].":00"))->format('Y-m-d H:i:s');
        $to_date = (DateTime::createFromFormat('d/m/Y H:i:s', $_GET['to_date'].":00"))->format('Y-m-d H:i:s');
        if (isset($_GET['stt'])) {
            $stt =implode(',', $_GET['stt']) ;
        } else {
            $stt = '';
        }
        $search = $_GET['search'];
        $page = $_GET['page'];
        $limit = $_GET['limit'];
        

       echo json_encode([
            'code'=>200,
            'msg'=>'Filter projects successfully',
            'icon'=>'success',
            'heading'=>'SUCCESSFULLY',
            'projects'=>$this->project_model->GetList($from_date,$to_date,$stt,$search,$page,$limit)
            // 'pages'=>$this->GetPages($from_date,$to_date,$stt,$search,$limit)
       ]);
    }
       public function ApplyTemplates(){
        $id = $_POST['id'];
        $rs = $this->project_model->ApplyTemplates($id);
       
        if($rs['rows_inserted'] > 0){
            $data = [
                'code'=> 200,
                'msg'=> 'The templates has been applied',
                'icon'=> 'success',
                'heading'=>'SUCCESSFULLY'
            ];
        }else{
            $data = [
                'code'=> 404,
                'msg'=> 'Can not apply the template',
                'icon'=> 'error'
            ];
        }
        echo json_encode($data);
    }


}