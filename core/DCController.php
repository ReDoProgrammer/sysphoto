<?php
/**
 * base controller
 */
class DCController extends Controller
{
    function __construct()
    {

        if (!empty($_SESSION['user'])) {
            $user = unserialize($_SESSION['user']);
            if ($user->role_id != 7) {
                header('Location: ' . _WEB_ROOT . '/dc/login');
                exit;
            }
        } else {
            header('Location: ' . _WEB_ROOT . '/dc/login');
            exit;
        }
    }

}