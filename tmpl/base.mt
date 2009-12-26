<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type"  content="text/html; charset=UTF-8" />
        <meta http-equiv="Cache-Control" content="max-age=0" />
        <meta name="robots" content="noindex,nofollow" />
        <meta name="viewport" content="width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;"/>
        <meta name="apple-mobile-web-app-capable" content="yes"/>
        <link rel="stylesheet" href="<?= uri_for('/static/newmo.css') ?>" type="text/css" />
        <title>Newmo</title>
    </head>
    <body>
        <a name="top"></a>
        <? block content => 'CONTENT HERE' ?>

        <hr class="hr" />

        <div class="footer">
            <a href="<?= uri_for('/', {t => time()}) ?>" accesskey="0">go to top[0]</a><br />
        </div>
    </body>
</html>
