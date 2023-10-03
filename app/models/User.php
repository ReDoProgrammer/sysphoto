<?php
class User
{
    public $firstname;
    public $email;
    public $role;
    public $roleName;
    public $task_getable;

    public function __construct($firstname, $email,$role,$roleName,$task_getable)
    {
        $this->firstname = $firstname;
        $this->email = $email;
        $this->role = $role;
        $this->roleName = $roleName;
        $this->task_getable = $task_getable;
    }
}