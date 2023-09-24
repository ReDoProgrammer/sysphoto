<?php
    class  TaskModel extends Model{
        protected $__table = 'task_list';
        public function getList(){
            $columns = "task_list.id, project_list.name, task_list.description, task,editor,qa, level.name as level, task_list.date_created";
            $join = " JOIN project_list ON task_list.project_id = project_list.id ";
            $join .= " JOIN level ON task_list.idlevel = level.id ";
            $data = $this->__db->select($this->__table,$columns,$join);
            return $data;
        }
    }