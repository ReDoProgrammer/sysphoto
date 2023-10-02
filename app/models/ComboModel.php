<?php
    class  ComboModel extends Model{
        protected $__table = 'comboes';
        public function getList(){           
            $comboes = $this->__db->select($this->__table);
            $content = array(
                'code'=>200,
                'msg'=>'Load comboes list successfully!',
                'comboes'=> $comboes
            );
            return json_encode($content);
        }
    }