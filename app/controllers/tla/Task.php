<?php
class Task extends TLAController
{
    private $__task_model;

    function __construct()
    {
        parent::__construct();
        $this->__task_model = $this->model("TaskModel");
    }
    public function index()
    {
        $this->data['title'] = 'Tasks List';
        $this->data['sub_content']['product'] = [];
        $this->data['content'] = 'tla/task/index';
        $this->render('__layouts/tla_layout', $this->data);
    }
    public function GetTask()
    {
        $id = $_GET['id'];
        $result = $this->__task_model->GetTask(4, $id); //4:TLA
        echo $result['msg'];
    }

    public function owntask()
    {
        $this->data['title'] = 'Tasks List';
        $this->data['sub_content']['Your own tasks'] = [];
        $this->data['content'] = 'tla/task/owntask';
        $this->render('__layouts/tla_layout', $this->data);
    }
    public function ViewDetail()
    {
        $id = $_GET['id'];
        $result = $this->__task_model->GetDetail($id);
        if (!empty($result)) {
            $data = [
                'code' => 200,
                'icon' => 'success',
                'heading' => 'SUCCESSFULLY',
                'msg' => 'Get task detail successfully.',
                'task' => $result[0]
            ];
        } else {
            $data = [
                'code' => 404,
                'icon' => 'warning',
                'heading' => 'Not Found',
                'msg' => 'Task not found.'
            ];
        }
        echo json_encode($data);
    }
    public function FilterTasks()
    {
        $from_date = (DateTime::createFromFormat('d/m/Y H:i:s', $_GET['from_date'] . ":00"))->format('Y-m-d H:i:s');
        $to_date = (DateTime::createFromFormat('d/m/Y H:i:s', $_GET['to_date'] . ":00"))->format('Y-m-d H:i:s');
        $status = $_GET['status'];
        $search = $_GET['search'];
        $page = $_GET['page'];
        $limit = $_GET['limit'];
        $result = $this->__task_model->FilterTasks($from_date, $to_date, $status, $search, $page, $limit);
        $user = unserialize($_SESSION['user']);
        echo json_encode(
            [
                'code' => 200,
                'msg' => 'Filter tasks successfully',
                'icon' => 'success',
                'heading' => 'SUCCESSFULLY',
                'tasks' => $result,
                'ownid' => $user->id
            ]
        );
    }
    public function fetch()
    {
        $from_date = (DateTime::createFromFormat('d/m/Y H:i:s', $_GET['from_date'] . ":00"))->format('Y-m-d H:i:s');
        $to_date = (DateTime::createFromFormat('d/m/Y H:i:s', $_GET['to_date'] . ":00"))->format('Y-m-d H:i:s');
        $status = $_GET['status'];
        $page = $_GET['page'];
        $limit = $_GET['limit'];
        $user = unserialize($_SESSION['user']);
        echo json_encode([
            'code' => 200,
            'msg' => 'Successfully fetch the tasks.',
            'icon' => 'success',
            'heading' => 'SUCCESSFULLY',
            'ownid' => $user->id,
            'tasks' => $this->__task_model->GetOwnerTasks($from_date, $to_date, $status, $page, $limit)
        ]);
    }
    public function Submit()
    {
        $id = $_POST['id'];
        $content = $_POST['content'];
        $role = $_POST['role'];
        $read_instructions = $_POST['read_instructions'];

        $result = $this->__task_model->SubmitTask($id, $read_instructions, $content, $role);

        if ($result['updated_rows'] > 0) {
            $data = [
                'code' => 200,
                'icon' => 'success',
                'heading' => 'SUCCESSFULLY',
                'msg' => 'You have submitted the task successfully.'
            ];
        } else {
            $data = [
                'code' => 204,
                'icon' => 'warning',
                'heading' => 'WARNING',
                'msg' => 'The task submission failed.'
            ];
        }
        echo json_encode($data);
    }
    public function Reject()
    {
        $id = $_POST['id'];
        $remark = $_POST['remark'];
        $read_instructions = $_POST['read_instructions'];
        $status = $_POST['status'];

        $result = $this->__task_model->RejectTask($id, $remark, $read_instructions, $status);
        if ($result['updated_rows'] > 0) {
            $data = [
                'code' => 200,
                'icon' => 'success',
                'heading' => 'SUCCESSFULLY',
                'msg' => 'You have submitted the task successfully.'
            ];
        } else {
            $data = [
                'code' => 204,
                'icon' => 'warning',
                'heading' => 'WARNING',
                'msg' => 'The task submission failed.'
            ];
        }
        echo json_encode($data);

    }

    public function create()
    {
        $prjId = $_POST['prjId'];
        $description = $_POST['description'];
        $level = $_POST['level'];
        $status = $_POST['status'];
        $cc = $_POST['cc'];
        $editor = $_POST['editor'];
        $qa = $_POST['qa'];
        $quantity = $_POST['quantity'];

        $result = $this->__task_model->create($prjId, $description, $editor, $qa, $quantity, $level, $cc,$status);
        if ($result['last_id'] > 0) {
            $data = array(
                'code' => 201,
                'msg' => $cc > 0 ? 'New CC task has been created!' : 'New task has been created!',
                'heading' => 'Successfully!',
                'icon' => 'success',
                'id' => $result['last_id']
            );
        } else {
            $data = array(
                'code' => 422,
                'msg' => 'Insert new task failed!',
                'icon' => 'danger'
            );
        }

        echo json_encode($data);

    }
    public function update()
    {
        $id = $_POST['id'];
        $description = $_POST['description'];
        $level = $_POST['level'];
        $status = $_POST['status'];
        $editor = $_POST['editor'];
        $qa = $_POST['qa'];
        $quantity = $_POST['quantity'];
        $result = $this->__task_model->UpdateTask($id, $description, $editor, $qa, $quantity, $level,$status);
        if ($result['updated_rows'] > 0) {
            $data = array(
                'code' => 200,
                'msg' => 'The task has been updated!',
                'heading' => 'Successfully!',
                'icon' => 'success'
            );
        } else {
            $data = array(
                'code' => 204,
                'msg' => 'Update task failed!',
                'icon' => 'danger'
            );
        }
        echo json_encode($data);
    }

    public function delete()
    {
        $id = $_POST['id'];
        $rs = $this->__task_model->destroy($id);
        
        if ($rs['deleted_rows']>0) {
            $data = array(
                'code' => 200,
                'msg' => 'The task has been deleted!',
                'heading' => 'Successfully!',
                'icon' => 'success'
            );
        } else {
            $data = array(
                'code' => 204,
                'msg' => 'Can not delete this task. Error: '.$rs,
                'icon' => 'danger',
                'heading' => 'OPP!!!'
            );
        }
        echo json_encode($data);
    }

}