
<BODY id="DataPostBody" onLoad="dosleep()">
 ...
  <div id="wait">placeholder</div>
 ...

  function dosleep() {
    document.getElementById('wait').innerHTML='Aloadmex'
    setTimeout(wake, 10000);  // 10 seconds
  }
  function wake() {
    document.getElementById('wait').innerHTML='Bloadmex'
  }

 ...
