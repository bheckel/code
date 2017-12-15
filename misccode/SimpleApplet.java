/* $ javac SimpleApplet.java
   SimpleApplet.class is created.
   Create SimpleApplet.html like so:
   <HTML>
   <BODY>
   <APPLET CODE=SimpleApplet.class WIDTH=200 HEIGHT=100>
   </APPLET>
   </BODY>
   </HTML>
   
   Or for debugging use:
   $ appletviewer SimpleApplet.html
 */

import java.applet.Applet;
import java.awt.Graphics;
import java.awt.Color;

public class SimpleApplet extends Applet{
  String text = "I'm a simple applet";

  public void init() {
    System.out.println("I'm in init() ...");
    text = "I'm a simple applet";
    setBackground(Color.cyan);
  }

  public void start() {
    System.out.println("starting...");
  }

  public void stop() {
    System.out.println("stopping...");
  }

  public void destroy() {
    System.out.println("preparing to unload...");
  }

  public void paint(Graphics g){
    System.out.println("Paint");
    g.setColor(Color.green);
    g.drawRect(0, 0, getSize().width-1, getSize().height-1);
    g.setColor(Color.red);
    g.drawString(text, 15, 25);
  }
}
