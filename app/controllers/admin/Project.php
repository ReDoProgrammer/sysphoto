<?php

class Project extends Controller
{
    public $project_model;
    function __construct()
    {
        $this->project_model = $this->model('ProjectModel');
    }
    public function testproc()
    {
        $procedureName = "InsertEmployee";

        // Khai báo biến cho ID và gán giá trị mặc định là null
        $insertedId = null;

        $params = array(
            "p_name" => "John Doe",
            "p_email" => "john@example.com"
        );

        $result = $this->project_model->executeStoredProcedure('FilterEmployeesBySalary');
        print_r($result);
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
        $levels = !empty($_POST['templates']) ? implode(',', $_POST['templates']) : '';
        $priority = $_POST['priority'];
        $description = $_POST['description'];
        $instruction = $_POST['instruction'];

        $user = unserialize($_SESSION['user']);




        $params = array(
            'p_customer_id' => $customer,
            'p_name' => $name,
            'p_start_date' => $start_date,
            'p_end_date' => $end_date,
            'p_status_id' => $status,
            'p_combo_id' => $combo,
            'p_levels' => $levels,
            'p_priority' => $priority,
            'p_description' => $description,
            'p_created_by' => $user->id
        );


        $pid = $this->project_model->executeStoredProcedure("ProjectInsert", $params);


        if ($pid > 0) {
            if (!empty(trim($instruction))) {
                //thêm instruction vào csdl
                $params = array(
                    'p_project_id' => $pid['last_id'],
                    'p_content' => $instruction,
                    'p_created_by' => $user->id
                );
                $this->project_model->executeStoredProcedure("ProjectInstructionInsert", $params);

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