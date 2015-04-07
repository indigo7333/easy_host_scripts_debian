<?php
//usage $1=mysql_user $2=mysql_password $3=database
//example:add_mysql_user.php user 'password' database

$mysql_user=$argv[1];
$mysql_password=$argv[2];
$mysql_database=$argv[3];

mysql_connect('localhost', $mysql_user, $mysql_password);
mysql_query("CREATE DATABASE `$mysql_database` CHARACTER SET utf8 COLLATE utf8_general_ci;");
?>