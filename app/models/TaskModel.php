<?php
class TaskModel extends Model
{
    protected $__table = 'tasks';

    function create($prjId,$description,$editor,$qa,$quantity,$level)
    {
        $user = unserialize($_SESSION['user']);
        $params = [
            'p_project'=>$prjId,
            'p_description'=>$description,
            'p_editor'=>$editor,
            'p_qa'=>$qa,
            'p_quantity'=>$quantity,
            'p_level'=>$level,
            'p_created_by'=>$user->id
        ];
        return $this->executeStoredProcedure("TaskInsert",$params);
    }
    function updateTask($data,$where){
        return $this->__db->update($this->__table, $data,$where);
    }

    public function getDetail($id)
    {
       $params = ['p_id'=>$id];
        return $this->executeStoredProcedure("TaskDetailJoin",$params);
    }
    public function getList()
    {
        
        return null;
    }

    function destroy($id){
        $where = "id =$id";
        return $this->__db->delete($this->__table.' t', $where);
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
        ts.name as status,
        ts.color as status_color";
        $join = " JOIN levels l ON t.level_id = l.id";
        $join .=" LEFT JOIN task_statuses ts ON t.status_id = ts.id";
        $join .=" LEFT JOIN users e ON t.editor_id =e.id";
        $join .=" LEFT JOIN users q ON t.qa_id = q.id";
        $join .=" LEFT JOIN users d ON t.dc_id = d.id";

        $where = "t.project_id = $id";
        $orderby ="t.created_at DESC";
   
        return $this->__db->select($this->__table." t",$columns,$join,$where,[],1,0, $orderby);
    }
}