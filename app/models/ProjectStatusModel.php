<?php
    class  ProjectStatusModel extends Model{
        protected $__table = 'project_statuses';
        public function AllProjectStatuses(){           
            $data = $this->__db->callStoredProcedure("ProjectStatusAll");
            return $data;
        }

        public function add($name, $color, $description, $visible){
            $user = unserialize($_SESSION['user']);
            $params = [
                "p_name"=> $name,
                "p_color"=>$color,
                "p_description"=> $description,
                "p_visible"=> $visible,
                "p_created_by"=>$user->id
            ];
            return $this->__db->executeStoredProcedure("ProjectStatusInsert", $params);
        }
      
        public function edit($id,$name, $color, $description, $visible){
            $user = unserialize($_SESSION['user']);
            $params = [
                "p_id"=> $id,
                "p_name"=> $name,
                "p_color"=>$color,
                "p_description"=> $description,
                "p_visible"=> $visible,
                "p_updated_by"=>$user->id
            ];
            return $this->__db->executeStoredProcedure("ProjectStatusUpdate", $params);
        }
        public function detail($id){
            $params = [0=>$id];
            return $this->__db->callStoredProcedure('ProjectStatusDetail', $params);
        }
        public function destroy($id){
            $params = ["p_id"=>$id];
            return $this->__db->executeStoredProcedure("ProjectStatusDelete", $params);
        }
    }