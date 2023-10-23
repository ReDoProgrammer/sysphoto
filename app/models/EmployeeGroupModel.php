<?php

class EmployeeGroupModel extends Model
{
    protected $__table = 'user_groups';
    public function All(){
        return $this->__db->callStoredProcedure("UserGroupsAll");
    }

    public function pages($group,$search){

    }

    public function filter($group,$search,$page=1,$limit = 10){

    }


}