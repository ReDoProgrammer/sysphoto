<?php
class TaskModel extends Model
{
    protected $__table = 'task_list';

    function create($data)
    {
        return $this->__db->insert($this->__table, $data);
    }
    function updateTask($data,$where){
        return $this->__db->update($this->__table, $data,$where);
    }

    public function getDetail($id)
    {
        $columns = "t.id,l.id as lId, l.name as level,l.mau_sac as level_bg, t.soluong as qty,t.description note, 
           e.id as eId, e.viettat as editor,qa.id as qaId, qa.viettat as qa, t.date_created as got_time, st.stt_task_name as status, st.color_sttt as status_bg";
        $join = " JOIN level l ON t.idlevel = l.id ";
        $join .= "LEFT JOIN users e ON t.editor = e.id ";
        $join .= "LEFT JOIN users qa ON t.qa = qa.id ";
        $join .= "LEFT JOIN status_task st ON t.status = st.id ";
        $where = "t.id = $id";
        $data = $this->__db->select($this->__table . " t", $columns, $join, $where);
        return $data;
    }
    public function getList()
    {
        $columns = "task_list.id, project_list.name, task_list.description, task,editor,qa, level.name as level, task_list.date_created";
        $join = " JOIN project_list ON task_list.project_id = project_list.id ";
        $join .= " JOIN level ON task_list.idlevel = level.id ";
        $data = $this->__db->select($this->__table, $columns, $join);
        return $data;
    }

    public function getTasksByProject($prjId)
    {
        $columns = "t.id, l.name as level,l.mau_sac as level_bg, t.soluong as qty,t.description note, 
            e.viettat as editor, qa.viettat as qa, t.date_created as got_time, st.stt_task_name as status, st.color_sttt as status_bg";
        $join = " JOIN level l ON t.idlevel = l.id ";
        $join .= "LEFT JOIN users e ON t.editor = e.id ";
        $join .= "LEFT JOIN users qa ON t.qa = qa.id ";
        $join .= "LEFT JOIN status_task st ON t.status = st.id ";
        $where = "project_id = $prjId";
        $data = $this->__db->select($this->__table . " t", $columns, $join, $where);
        return $data;
    }
}