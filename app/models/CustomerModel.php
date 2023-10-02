<?php
    class  CustomerModel extends Model{
        protected $__table = 'customers';
        public function getList(){           
            $customers = $this->__db->select($this->__table,"id,acronym");
            $content = array(
                'code'=>200,
                'msg'=>'Load customers list successfully!',
                'customers'=> $customers
            );
            return json_encode($content);
        }
    }