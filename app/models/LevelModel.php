<?php
    class  LevelModel extends Model{
        protected $__table = 'level';
        public function getList(){           
            $levels = $this->__db->select($this->__table);
            $content = array(
                'code'=>200,
                'msg'=>'Load levels list successfully!',
                'levels'=> $levels
            );
            return json_encode($content);
        }
    }