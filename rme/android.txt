IntelliJ search: <Shift><Shift>

---

13-Feb-14
$ cd
$ tar xfz ~/Downloads/android-studio-bundle-133.970939-linux.tgz

~/android-studio/bin/studio.sh&

---

http://zetcode.com/mob/android/intents/


//////////////////// Explicit Intent //////////////////////////
AndroidManifest.xml

<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
      package="com.zetcode.explicit"
      android:versionCode="1"
      android:versionName="1.0">
    <application android:label="@string/app_name"
                 android:icon="@drawable/ic_launcher"
                 >

        <activity android:name="MainActivity"
                  android:label="@string/app_name"
                  >
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        
        <activity android:name=".NextActivity"></activity>
        
    </application>
</manifest>


main.xml

<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:layout_width="fill_parent"
    android:layout_height="fill_parent"
    >
    <Button
        android:id="@+id/button1"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_margin="5dp"
        android:onClick="onClicked"
        android:text="@string/btn_title"
        />        
</LinearLayout>


strings.xml

<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Explicit Intent</string>
    <string name="btn_title">Next</string>
</resources>


$ ls src/com/zetcode/explicit/
MainActivity.java  NextActivity.java


MainActivity.java

package com.zetcode.explicit;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.content.Intent;

public class MainActivity extends Activity
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
    }

    public void onClicked(View view)
    {
        Intent intent =  new Intent(this, NextActivity.class);
        startActivity(intent);        
    }
}


NextActivity.java

package com.zetcode.explicit;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;
import android.widget.LinearLayout;

public class NextActivity extends Activity
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        initUI();
    }

    public void initUI()
    {
        LinearLayout lay = new LinearLayout(this);
        
        TextView tv = new TextView(this);
        tv.setText("Next screen");
        lay.addView(tv);

        setContentView(lay);
    }
}
///////////////////////////////////////////////////////////////


/////////////////// Transferring Data /////////////////////////
$ ls res/layout/
screen1.xml  screen2.xml
$ ls src/com/zetcode/switch2/
FirstScreen.java  SecondScreen.java


AndroidManifest.xml

<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
      package="com.zetcode.switch2"
      android:versionCode="1"
      android:versionName="1.0"
      >

    <application android:label="@string/app_name"
                 android:icon="@drawable/ic_launcher"
                 >
        <activity android:name=".FirstScreen">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        
        <activity android:name=".SecondScreen"></activity>
        
    </application>
</manifest>


screen1.xml

<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:layout_width="fill_parent"
    android:layout_height="fill_parent"
    >

  <EditText android:id="@+id/editId"
          android:layout_width="fill_parent"
          android:layout_height="wrap_content"
          android:layout_marginTop="10dip"
          android:layout_marginBottom="10dip"
          android:hint="@string/etHint"
          />
          
  <Button
          android:layout_width="wrap_content"
          android:layout_height="wrap_content"
          android:text="@string/btn_send" 
          android:onClick="sendMessage"
          />

</LinearLayout>


screen2.xml

<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:layout_width="fill_parent"
    android:layout_height="fill_parent"
    >
  <TextView
      android:id="@+id/tvId"
      android:layout_width="fill_parent"
      android:layout_height="wrap_content"
      />
</LinearLayout>


strings.xml

<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Switch</string>
    <string name="etHint">Enter your name</string>
    <string name="btn_send">Send</string>
</resources>


FirstScreen.java

package com.zetcode.switch2;

import android.app.Activity;
import android.os.Bundle;
import android.content.Intent;
import android.view.View;
import android.widget.EditText;

public class FirstScreen extends Activity
{
    private EditText iname;
 
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        setTitle("First screen");
        setContentView(R.layout.screen1);

        iname = (EditText) findViewById(R.id.editId);
    }

    public void sendMessage(View view) 
    {
        Intent switchTo = new Intent(this, SecondScreen.class);        
        switchTo.putExtra("name", iname.getText().toString());        
        startActivity(switchTo); 
    }
}


SecondScreen.java

package com.zetcode.switch2;

import android.app.Activity;
import android.os.Bundle;
import android.content.Intent;
import android.widget.TextView;

public class SecondScreen extends Activity
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.screen2);

        setupUI();
    }

    void setupUI()
    {
        setTitle("Second screen");

        TextView tv = (TextView) findViewById(R.id.tvId);
        
        Intent i = getIntent();
        String name = i.getStringExtra("name");        
        tv.setText("You have entered: " + name);
    }
}

///////////////////////////////////////////////////////////////


////////////////// Grid Layout ////////////////////////////////
main.xml

<?xml version="1.0" encoding="utf-8"?>
<GridLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" 
    android:layout_height="match_parent"
    >
    
    <Button
      android:text="(0, 0)"      
      android:layout_row="0"              
      android:layout_column="0" />    
      
    <Button
      android:layout_row="0"              
      android:layout_column="1" 
      android:layout_columnSpan="2"
      android:layout_gravity="fill_horizontal" />       
      
    <Button
      android:text="(0, 3)"      
      android:layout_row="0"              
      android:layout_column="3" />       
    
    <Button
      android:text="(0, 4)"     
      android:layout_row="0"              
      android:layout_column="4" />       
      
    <Button      
      android:layout_row="1"
      android:layout_column="0"
      android:layout_rowSpan="3" 
      android:layout_columnSpan="5" 
      android:layout_gravity="fill" />   
      
    <Button
      android:text="Center"      
      android:layout_row="4"
      android:layout_column="0"
      android:layout_columnSpan="5" 
      android:layout_gravity="center_horizontal" />      
      
    <Button
      android:text="Right"      
      android:layout_row="5"
      android:layout_column="0"
      android:layout_columnSpan="5" 
      android:layout_gravity="right" />           
    
</GridLayout>
///////////////////////////////////////////////////////////////


//////// Programmatic without Layout Mgrs in main.xml /////////
MainActivity.java

package com.zetcode.btnrow2;

import android.app.Activity;
import android.os.Bundle;
import android.widget.Button;
import android.widget.LinearLayout;

public class ButtonRow2 extends Activity
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        
        initUI();
    }

    public void initUI()
    {
        Button btn1 = new Button(this);
        btn1.setText("Button");

        Button btn2 = new Button(this);
        btn2.setText("Button2");

        Button btn3 = new Button(this);
        btn3.setText("Button3");

        Button btn4 = new Button(this);
        btn4.setText("Button4");

        LinearLayout ll = new LinearLayout(this);
        ll.setOrientation(LinearLayout.HORIZONTAL);

        ll.addView(btn1);
        ll.addView(btn2);
        ll.addView(btn3);
        ll.addView(btn4);

        setContentView(ll);
    }
}
///////////////////////////////////////////////////////////////

---

SDK Manager
~/android-sdk-linux/tools/android sdk

# Webupd8 PPA??
$ sudo apt-get install oracle-java8-installer

$ ~/android-sdk-linux/tools/android list avd

$ ~/android-sdk-linux/tools/emulator -avd 412_16_arm -verbose

---

~/android-sdk-linux/platform-tools/adb pull /mnt/sdcard/Android/data/com.amazon.kindle/files/B003XRDC16_EBOK.prc

---

20-Oct-12 Root

Settings: Debug mode

$ lsusb
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 002 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 001 Device 008: ID 18d1:4e21 Google Inc. Nexus S

cat /etc/udev/rules.d/51-android.rules
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e21", MODE="0660" OWNER="bheckel"
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e22", MODE="0660" OWNER="bheckel" # MTP mode with USB debug on
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e20", MODE="0660" OWNER="bheckel"

# Make sure to enable Debugging in System Settings first.  Do not need to mount
# USB card.
$ ~/android-sdk-linux/platform-tools/adb devices
List of devices attached 
3031CDA0BE5100ECdevice


 1569  2012-10-19 20:31:22 sudo add-apt-repository ppa:nilarimogard/webupd8
 1570  2012-10-19 20:31:47 sudo apt-get update
 1571  2012-10-19 20:31:58 sudo apt-get install android-tools-adb android-tools-fastboot
 1572  2012-10-19 20:32:49 sudo apt-get purge openjdk*
 1573  2012-10-19 20:33:34 sudo add-apt-repository ppa:webupd8team/java & sudo apt-get update
 1574  2012-10-19 20:33:50 sudo apt-get install oracle-java7-installer
 1575  2012-10-19 20:36:04 sudo rm /etc/apt/sources.list.d/*java*
 1576  2012-10-19 20:36:15 sudo rm /var/lib/dpkg/info/oracle-java7-installer*
 1577  2012-10-19 20:36:23 sudo apt-get purge oracle-java7-installer*
 1578  2012-10-19 20:36:31 sudo apt-get update
 1579  2012-10-19 20:36:40 sudo add-apt-repository ppa:webupd8team/java
 1580  2012-10-19 20:36:52 sudo apt-get install oracle-java7-installer
 1581  2012-10-19 20:37:39 sudo vi /etc/udev/rules.d/99-android.rules
 1582  2012-10-19 20:39:30 apt-get install package sun-java6-jre
 1583  2012-10-19 20:39:44 sudo apt-get install package sun-java6-jre
 1584  2012-10-19 20:47:14 sudo apt-get install openjdk-7-jre
 1595  2012-10-20 09:21:13 cd /etc/udev/rules.d/
 1597  2012-10-20 09:22:25 sudo mv 99-android.rules 51-android.rules 
 1598  2012-10-20 09:22:30 sudo service udev restart
 1599  2012-10-20 09:40:28 md5sum ~/Downloads/openrecovery-twrp-2.3.1.0-crespo4g.img 
 1600  2012-10-20 09:46:31 md5sum ~/Downloads/Superuser-3.1.3-arm-signed.zip 
 1040  2012-10-20 10:06:34 ~/android-sdk-linux/platform-tools/adb devices
 1041  2012-10-20 10:09:45 ~/android-sdk-linux/platform-tools/fastboot oem unlock
 1042  2012-10-20 10:11:58 ~/android-sdk-linux/platform-tools/fastboot flash recovery openrecovery-twrp-2.3.1.0-crespo4g.img

~/android-sdk-linux/platform-tools/adb shell
su  # now works


---

Common adb commands:

adb devices – lists which devices are currently attached to your computer

adb install <packagename.apk> – lets you install an Android application on your phone

adb remount – Remounts your system in write mode – this lets you alter system files on your phone using ADB

adb push <localfile> <location on your phone> – lets you upload files to your phones filesystem

adb pull <location on your phone> <localfile> – lets you download files off your phones filesystem

adb logcat – starts dumping debugging information from your handset to the console – useful for debugging your apps

adb shell <command> – drops you into a basic linux command shell on your phone with no parameters, or lets you run commands directly

---

TODO
5 daily recollections
suttapitaka.com app
turn on for 10 min/hr to download then turn off / radio off scheduler
pdoan


