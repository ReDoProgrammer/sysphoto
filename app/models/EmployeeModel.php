<?php
class EmployeeModel extends Model
{
    protected $__table = 'users';
    public function getList()
    {
        $columns = "users.id, firstname,viettat,email,name_ut,date_created";
        $join = " join user_type on ".$this->__table.".type = user_type.id";
        $data = $this->__db->select($this->__table,$columns,$join);
        return $data;
    }
}