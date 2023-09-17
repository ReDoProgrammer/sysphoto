<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
        <?php
            echo (!empty($title)?$title:'Trang chủ khách hàng');
        ?>
    </title>
    <link rel="stylesheet" href="<?php echo _WEB_ROOT;?>/public/assets/css/style.css">
</head>
<body>
    <?php
        $this->render('__Layouts/blocks/header');
        $this->render($content,$sub_content);
        $this->render('__Layouts/blocks/footer');
    ?>
    <script src="<?php echo _WEB_ROOT;?>/public/assets/js/script.js"></script>
</body>
</html>