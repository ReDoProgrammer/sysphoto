<?php
    class  CustomerModel extends Model{
        protected $__table = 'custom';
        public function getList(){           
            $customers = $this->__db->select($this->__table,"id,name_ct");
            $content = array(
                'code'=>200,
                'msg'=>'Load customers list successfully!',
                'customers'=> $customers
            );
            return json_encode($content);
        }
    }