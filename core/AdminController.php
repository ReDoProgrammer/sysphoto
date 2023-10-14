<?php
/**
 * base controller
 */
class AdminController extends Controller
{
    function __construct()
    {

        if (!empty($_SESSION['user'])) {
            $user = unserialize($_SESSION['user']);
            if ($user->role_id != 1) {
                header('Location: ' . _WEB_ROOT . '/admin/login');
                exit;
            }
        } else {
            header('Location: ' . _WEB_ROOT . '/admin/login');
            exit;
        }
    }

}