<?php
class Task extends AdminController
{
    public $task_model;
    function __construct()
    {
        parent::__construct();
        $this->task_model = $this->model('TaskModel');
    }
    public function index()
    {
        //renderview          
        $tasks = $this->task_model->getList();


        //renderview
        $this->data['title'] = 'Danh sách tác vụ'; // title: cái này làm title web, k quan trọng lắm
        $this->data['sub_content']['tasks'] = $tasks; // dữ liệu task, dữ liệu chính
        $this->data['content'] = 'admin/task/index'; // chỉ ra view tương ứng, view cần
        $this->render('__layouts/admin_layout', $this->data); // chỉ ra layout admin kèm dữ liệu, layout cũng cần
    }
    public function create()
    {
        $prjId = $_POST['prjId'];
        $description = $_POST['description'];
        $level = $_POST['level'];
        $cc = $_POST['cc'];
        $editor = $_POST['editor'];
        $qa = $_POST['qa'];
        $quantity = $_POST['quantity'];

        $result = $this->task_model->create($prjId, $description, $editor, $qa, $quantity, $level,$cc);
        if ($result['last_id'] > 0) {
            $data = array(
                'code' => 201,
                'msg' => $cc>0?'New CC task has been created!':'New task has been created!',
                'heading' =>'Successfully!',
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
        $editor = $_POST['editor'];
        $qa = $_POST['qa'];
        $quantity = $_POST['quantity'];
        $result = $this->task_model->UpdateTask($id, $description, $editor, $qa, $quantity, $level);
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
        $rs = $this->task_model->destroy($id);
        
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



    public function getTaskList()
    {
        $tasks = $this->task_model->getList();

        echo json_encode($tasks);
    }

    public function detail()
    {
        $id = $_GET['id'];
        $result = $this->task_model->GetDetail($id);
        if(!empty($result)){
            $data = [
                'code'=>200,
                'icon'=>'success',
                'heading'=>'SUCCESSFULLY',
                'msg'=>'Get task detail successfully.',
                'task'=>$result[0]
            ];
        }else{
            $data = [
                'code'=>404,
                'icon'=>'warning',
                'heading'=>'Not Found',
                'msg'=>'Task not found.'
            ];
        }
        echo json_encode($data);
    }


    public function ListByProject()
    {
        $id = $_GET['id'];
        echo json_encode([
            'code' => 200,
            'msg' => 'Get tasks list based on project successfully',
            'icon' => 'success',
            'heading' => 'SUCCESSFULLY',
            'tasks' => $this->task_model->GetTasksByProject($id)
        ]);
    }
}