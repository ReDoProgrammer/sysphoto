<?php
class Task extends Controller
{
    public $task_model;
    function __construct()
    {
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
        $editor = $_POST['editor'];
        $qa = $_POST['qa'];
        $quantity = $_POST['quantity'];
        $status = $_POST['status'];
        $data = array(
            'project_id'=>$prjId,
            'description'=>$description,
            'status'=>$status,
            'editor'=>$editor,
            'qa'=>$qa,
            'soluong'=>$quantity,
            'idlevel'=>$level
        );
        $lastId = $this->task_model->create($data);
        if($lastId>0){
            $data = array(
                'code'=>201,
                'msg'=>'New task has been created!',
                'heading'=>'Successfully!',
                'icon'=>'success',
                'id'=>$lastId
            );
        }else{
            $data = array(
                'code'=>422,
                'msg'=>'Insert new task failed!',
                'icon'=>'danger'
            );
        }

        echo json_encode($data);

    }

    public function getTaskList()
    {
        $tasks = $this->task_model->getList();

        echo json_encode($tasks);
    }

    public function getTasksByProject()
    {
        $id = $_GET['id'];
        $tasks = $this->task_model->getTasksByProject($id);
        $data = array(
            'code' => '200',
            'msg' => 'Get tasks list based on project successfully!',
            'tasks' => $tasks
        );
        echo json_encode($data);
    }
}