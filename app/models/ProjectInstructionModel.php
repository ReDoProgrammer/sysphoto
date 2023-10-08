<?php
    class  ProjectInstructionModel extends Model{
        protected $__table = 'project_instructions';
        public function InsertInstruction($projectId,$content){
            $user = unserialize($_SESSION['user']);
            $params = array(
                'p_project_id' => $projectId,
                'p_content' => $content,
                'p_created_by' => $user->id
            );
           return $this->__db->executeStoredProcedure("ProjectInstructionInsert", $params);
        }
    }