<?php
class TaskStatus extends TLAController
{
    private $__taskstatus_model;
    function __construct()
    {
        $this->__taskstatus_model = $this->model("TaskStatusModel");
    }
    public function All()
    {
        echo json_encode([
            'code' => 200,
            'msg' => 'Get all task statuses successfully',
            'icon' => 'success',
            'heading' => 'SUCCESSFULLY',
            'taskstatuses' => $this->__taskstatus_model->AllTaskStatuses()
        ]);
    }
}