<?php
class TaskModel extends Model
{
    protected $__table = 'tasks';

    function create($prjId, $description, $editor, $qa, $quantity, $level, $cc)
    {
        $user = unserialize($_SESSION['user']);
        $params = [
            'p_project' => $prjId,
            'p_description' => $description,
            'p_editor' => $editor,
            'p_qa' => $qa,
            'p_quantity' => $quantity,
            'p_level' => $level,
            'p_cc' => $cc,
            'p_created_by' => $user->id
        ];
        return $this->__db->executeStoredProcedure("TaskInsert", $params);
    }
    function UpdateTask($id, $description, $editor, $qa, $quantity, $level)
    {
        $user = unserialize($_SESSION['user']);
        $params = [
            'p_id' => $id,
            'p_description' => $description,
            'p_editor' => $editor,
            'p_assign_editor' => $editor > 0 ? 1 : 0,
            'p_qa' => $qa,
            'p_assign_qa' => $qa > 0 ? 1 : 0,
            'p_quantity' => $quantity,
            'p_level' => $level,
            'p_updated_by' => $user->id
        ];
        return $this->__db->executeStoredProcedure("TaskUpdate", $params);
    }

    public function GetDetail($id)
    {
        $params = [0 => $id];
        return $this->__db->callStoredProcedure("TaskDetailJoin", $params);
    }
    public function getList()
    {

        return null;
    }

    function destroy($id)
    {
        $user = unserialize($_SESSION['user']);
        $params = [
            'p_id' => $id,
            'p_deleted_by' => $user->acronym
        ];
        return $this->__db->executeStoredProcedure("TaskDelete", $params);

        // return $this->__db->delete($this->__table,"id = ".$id);
    }

    public function EditorSubmitTask($id,$url){
        $user = unserialize($_SESSION['user']);
        $params = [
            'p_id'=>$id,
            'p_url'=>$url,
            'p_editor'=>$user->id,
            'p_status'=>1
        ];
        return $this->__db->executeStoredProcedure("TaskSubmitedByEditor",$params);
    }

    public function GetTasksByProject($id)
    {
        // $params = ['p_id'=>$id];
        // return $this->executeStoredProcedure("TasksGetByProject",$params);
        $columns = " t.id,
        l.name as level,
        t.quantity,
        e.acronym as editor,
        q.acronym as qa,
        d.acronym as dc,
        t.status_id,
        t.cc_id,
        ts.name as status,
        ts.color as status_color";
        $join = " JOIN levels l ON t.level_id = l.id";
        $join .= " LEFT JOIN task_statuses ts ON t.status_id = ts.id";
        $join .= " LEFT JOIN users e ON t.editor_id =e.id";
        $join .= " LEFT JOIN users q ON t.qa_id = q.id";
        $join .= " LEFT JOIN users d ON t.dc_id = d.id";

        $where = "t.project_id = $id";
        $orderby = "t.created_at DESC";

        return $this->__db->select($this->__table . " t", $columns, $join, $where, [], 1, 0, $orderby);
    }
    public function EditorGetTask()
    {
        $user = unserialize($_SESSION['user']);
        $params = ['p_editor' => $user->id];
        return $this->__db->executeStoredProcedure("EditorGetTask", $params);
    }
    public function GetOwnerTasks($from_date, $to_date, $status, $page = 1, $limit = 0)
    {
        $user = unserialize($_SESSION['user']);
        $params = array(
            0 => $from_date,
            1 => $to_date,
            2 => $status,
            3 => $page,
            4 => $limit,
            5 => $user->id,
            6 => $user->role_id
        );
        $procedureName = "TasksGottenByOwner";      

       return $this->__db->callAnyStoredProcedure($procedureName, $params);
       
    }
}