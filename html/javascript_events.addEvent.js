<!-- http://www.webmonkey.com/reference/JavaScript_Events -->

<html>
<head>
<script>
// addEvent function by John Resig:
// http://ejohn.org/projects/flexible-javascript-events/
function addEvent( obj, type, fn ) {
  if ( obj.attachEvent ) {
    obj['e'+type+fn] = fn;
    obj[type+fn] = function(){obj['e'+type+fn]( window.event );}
    obj.attachEvent( 'on'+type, obj[type+fn] );
  } else
    obj.addEventListener( type, fn, false );
}
</script>
</head>
<body>

<input id="myinput" type="text"  value="Change this text" />

<br>
<input id="mytext" type="text" />
<br><div id="mydiv" style="border: 1px solid black; width: 100px; height: 100px; margin-top: 10px;"></div>

<script>
  // also available: 'resize' 'scroll' 'unload'
  ///addEvent(window, 'load', function(event) {
    ///alert('The page has loaded');
  ///});

  ///addEvent(document.getElementById('myinput'), 'focus', function(event) {
    ///alert('The element has focus');
  ///});

  // The onBlur event fires whenever a form field lose focus.
  ///addEvent(document.getElementById('myinput'), 'blur', function(event) {
    ///alert('The element lost focus (blurred)');
  ///});

  // The onChange event fires whenever the value of a form field (including
  // select lists) changes. Big caveat: the event is only recognized once a
  // field loses focus, so the change event will not fire as soon as text is
  // edited.
  ///addEvent(document.getElementById('myinput'), 'change', function(event) {
    ///alert('The text has changed');
  ///});

  // 2008-09-23 fails under IE6
  ///addEvent(document.getElementById('myinput'), 'select', function(event) {
    ///var txtbox = event.target;
    ///var selectedText = txtbox.value.substr(txtbox.selectionStart, txtbox.selectionEnd - txtbox.selectionStart);
    ///alert('The user selected some text: ' + selectedText);
  ///});

  // also available: 'keypress' 'keyup'
  ///addEvent(document.getElementById('mytext'), 'keydown', function(event) {
  ///        display_short('keydown: ' + event.keyCode);
  ///});
  ///function display_short(str)
  ///{
  ///        clearTimeout();
  ///        document.getElementById('mydiv').innerHTML = str;
  ///        if (str != '')
  ///                setTimeout("display_short('')", 1000);
  ///}

  // also available: 'contextmenu' 'dblclick' 'mousedown' 'mousemove'
  //                 'mouseout' mouseover' 'mouseup'
  addEvent(document.getElementById('mydiv'), 'click', function(event) {
    display_short('clicked div region');
  });
  function display_short(str)
  {
    clearTimeout();
    document.getElementById('mydiv').innerHTML = str;
    if (str != '')
      setTimeout("display_short('')", 1000);
  }
</script>
</body>
</html>
