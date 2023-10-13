<?php
    class  TaskStatusModel extends Model{
        protected $__table = 'task_statuses';
        public function AllTaskStatuses(){      
            return $this->__db->callStoredProcedure("TaskStatusAll");
        }
    }