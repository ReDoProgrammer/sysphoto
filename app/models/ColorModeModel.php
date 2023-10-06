<?php
    class  ColorModeModel extends Model{
        protected $__table = 'color_modes';
        public function AllColorModes(){          
            return $this->__db->select($this->__table,"id,name");
        }
    }