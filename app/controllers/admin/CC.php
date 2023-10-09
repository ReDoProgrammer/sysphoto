<?php

class CC extends Controller
{
    public $cc_model;
    function __construct()
    {
        $this->cc_model = $this->model('CCModel');
    }


    public function insert()
    {
        $project_id = $_POST['project_id'];
        $feedback = $_POST['feedback'];
        $start_date = (DateTime::createFromFormat('d/m/Y H:i:s', $_POST['start_date']))->format('Y-m-d H:i:s');
        $end_date = (DateTime::createFromFormat('d/m/Y H:i:s', $_POST['end_date']))->format('Y-m-d H:i:s');
        $rs = $this->cc_model->InsertCC($project_id, $feedback, $start_date, $end_date);
        if ($rs['last_id'] > 0) {
            $data = array(
                'code' => 201,
                'msg' => 'Insert CC successfully!',
                'icon' => 'success',
                'heading' => 'SUCCESSFULLY'
            );
        } else {
            $data = array(
                'code' => 204,
                'msg' => 'Insert CC failed!',
                'icon' => 'warning',
                'heading' => 'FAILED'
            );
        }
        echo json_encode($data);
    }

    public function select(){
        $project_id = $_GET['project_id'];
        echo json_encode([
            'code'=>200,
            'msg'=>'Get CCs list based on project successfully',
            'icon'=>'success',
            'heading'=>'SUCCESSFULLY',
            'ccs'=>$this->cc_model->AllCCs($project_id)
        ]);
    }
    public function getccs(){
        $prjId = $_GET['project_id'];
        echo json_encode([
            'code'=>200,
            'msg'=>'Get CCs list with own tasks based on project successfully',
            'icon'=>'success',
            'heading'=>'SUCCESSFULLY',
            'ccs'=>$this->cc_model->GetCCsListWithTasks($prjId)
        ]);
    }
}