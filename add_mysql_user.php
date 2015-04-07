<?
//usage $1=mysql_user $2=mysql_password $3=root_password
//example:add_mysql_user.php user 'password' 'root_password'

$mysql_user=$argv[1];
$mysql_password=$argv[2];
$root_password=$argv[3];

mysql_connect('localhost', 'root', $root_password);


mysql_query("CREATE USER '$mysql_user'@'%' IDENTIFIED BY  '$mysql_password';");

mysql_query("GRANT ALL PRIVILEGES ON * . * TO  '$mysql_user'@'%' IDENTIFIED BY  '$mysql_password' WITH GRANT OPTION MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;");

mysql_query("GRANT ALL PRIVILEGES ON  `$mysql_user\_%` . * TO  '$mysql_user'@'%';");