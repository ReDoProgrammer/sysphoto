<?php
    class  ProjectStatusModel extends Model{
        protected $__table = 'project_statuses';
        public function AllProjectStatuses(){           
            $data = $this->__db->callStoredProcedure("ProjectStatusAll");
            return $data;
        }
    }