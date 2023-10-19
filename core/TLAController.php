<?php
/**
 * base controller
 */
class TLAController extends Controller
{
    function __construct()
    {

        if (!empty($_SESSION['user'])) {
            $user = unserialize($_SESSION['user']);
            if ($user->role_id != 4) {
                header('Location: ' . _WEB_ROOT . '/tla/login');
                exit;
            }
        } else {
            header('Location: ' . _WEB_ROOT . '/tla/login');
            exit;
        }
    }

}