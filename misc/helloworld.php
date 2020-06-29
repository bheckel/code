<html>
 <head>
  <title>PHP HelloWorld Test</title>
 </head>
 <body>
  <?php echo '<p>Hello World</p>'; ?> 
  // If server is configured correctly the 'php' after '?' part can be 
  // eliminated.
  User's browser is <? echo $_SERVER['HTTP_USER_AGENT'] ?>
  <?phpinfo()?>
 </body>
</html>
