<?php
/**
 * base controller
 */
class EditorController extends Controller
{
    function __construct()
    {

        if (isset($_SESSION['user'])) {
            $user = unserialize($_SESSION['user']);
            if ($user->role != 1 && $user->role != 6) {
                header('Location: ' . _WEB_ROOT . '/editor/login');
                exit;
            }
        } else {
            header('Location: ' . _WEB_ROOT . '/editor/login');
            exit;
        }
    }

}