<?php
    class ProjectLogModel extends Model{
        protected $__table = 'project_logs';
        public function GetLogs($pId){
            $params = [0=>$pId];            
            return $this->__db->callStoredProcedure("ProjectLogs",$params);           
        }
    }