<?php

class EmployeeGroupModel extends Model
{
    protected $__table = 'user_groups';
    public function All(){
        return $this->__db->callStoredProcedure("UserGroupsAll");
    }


}