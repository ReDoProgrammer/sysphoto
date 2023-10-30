<?php
    class ProjectModel extends Model{
        protected $__table = 'projects';

        public function ApplyTemplates($id){
            $params = ['p_id'=>$id];
            return $this->__db->executeStoredProcedure("ProjectApplyingTemplates",$params);
        }
        public function CreateProject($customer,$name,$start_date,$end_date,$combo,$levels,$priority,$description){
            $user = unserialize($_SESSION['user']);
            $params = array(
                'p_customer_id' => $customer,
                'p_name' => $name,
                'p_start_date' => $start_date,
                'p_end_date' => $end_date,
                'p_combo_id' => $combo,
                'p_levels' => $levels,
                'p_priority' => $priority,
                'p_description' => $description,
                'p_created_by' => $user->id
            );
            return $this->__db->executeStoredProcedure("ProjectInsert",$params);
        }

        public function UpdateProject($id,$customer,$name,$start_date,$end_date,$combo,$levels,$priority,$description){
            $user = unserialize($_SESSION['user']);
            $params = array(
                'p_id'=>$id,
                'p_customer_id' => $customer,
                'p_name' => $name,
                'p_start_date' => $start_date,
                'p_end_date' => $end_date,
                'p_combo_id' => $combo,
                'p_levels' => $levels,
                'p_priority' => $priority,
                'p_description' => $description,
                'p_updated_by' => $user->id
            );
            return $this->__db->executeStoredProcedure("ProjectUpdate",$params);
        }

        public function DeleteProject($id){
            return $this->__db->delete($this->__table," id = $id");
        }

        public function ProjectDetail($id){
            $params = ['p_id'=>$id];
            return $this->__db->executeStoredProcedure("ProjectDetailJoin",$params);
        }

        public function GetList($from_date,$to_date,$stt,$search,$page = 1,$limit = 10){
            $params = [
                0=>$from_date,
                1=>$to_date,
                2=>$stt,
                3=>$search,
                4=>$page,
                5=>$limit
            ];
            print_r($stt);
            return $this->__db->callStoredProcedure("ProjectFilter",$params);
        }

        public function GetPages($from_date,$to_date,$stt,$search='',$limit=10){
            $params = [
                'p_from_date'=>$from_date,
                'p_end_date'=>$to_date,
                'p_status'=>$stt,
                'p_search'=>$search,
                'p_limit'=>$limit
            ];
            return $this->__db->executeStoredProcedure("ProjectPages",$params);
        }

        public function AddInstruction($id,$instruction){
            $user = unserialize($_SESSION['user']);
            $params = [
                'p_project'=>$id,
                'p_content'=>$instruction,
                'p_created'=>$user->id
            ];
            return $this->__db->executeStoredProcedure("ProjectInstructionInsert",$params);
        }

        public function Submit($id,$content,$status = 4){
            $user = unserialize($_SESSION["user"]);
            $params = [
                'p_id'=>$id,
                'p_content'=>$content,
                'status'=>$status,
                'p_actioner'=>$user->id               
            ];
            return $this->__db->executeStoredProcedure("ProjectSubmit",$params);
        }
    }