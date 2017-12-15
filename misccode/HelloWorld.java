//////////////////////////////////////////////////////////////////////////////
//     Name: HelloWorld.java
//
//  Summary: Simple java program
//           Make sure '.../jdk1.3.1_01/bin' is on $PATH
//
//           $ javac HelloWorld.java  <---HelloWorld.class is compiled
//           $ java HelloWorld        <---Run JVM virtual machine (don't use
//                                        .class extension!)
//
//           http://zetcode.com/lang/java
//
//  Created: Thu 26 Sep 2002 08:14:51 (Bob Heckel)
// Modified: Fri 10 Jan 2014 09:55:10 (Bob Heckel)
//////////////////////////////////////////////////////////////////////////////

// touch ./com/rshdev/HelloWorld.java
// The package name must correspond to the directory structure in which the
// source file is located.  This line must come first in the file.
package com.rshdev; 

import java.util.Arrays;

// Must be same name as filename without the .java (case-sensitive). A file of
// Java code may have one or more classes, out of which only one can be
// declared public. 
public class HelloWorld {

  // The method is declared to be static. This static method can be called
  // without the need to create an instance of the Java class. First we need to
  // start the application and after that, we are able to create instances of
  // classes. The void keyword states that the method does not return a value.
  // Finally, the public keyword makes the main() method available to the outer
  // world without restrictions.
  public static void main(String args[]) {

    int age = 29;
    int binary = 0b1001;
    String nationality = "Hungarian";  /* an object of String type is created */
    String nationality2 = new String("Hungarian2");  /* an object of String type is created */
    String job = null;
    static String lyrics = "I cheated myself\n" +
"like I knew I would\n" +
"I told ya, I was trouble\n" +
"you know that I'm no good";
    char c = 'J';
    boolean sng = true;
    double weight = 68.5;
    double n = 1.234E10; 
    long bigone = 23_482_345_629L;

    int[] a = new int[] { 2, 4, 5, 6, 7, 3, 2 };
    int[] b = { 2, 4, 5, 6, 7, 3, 2 };  /* same */
    int[][] twodim = new int[][] { {1, 2, 3}, {1, 2, 3} };

    final int WIDTH = 100;  // constant

    // Class.object.function(parameter)
    System.out.println("Don't panic ");

    System.out.format("His nationality is %s%n", nationality);
    System.out.format("His is %d years old%n", age);

    // Strings are immutable, must create new String
    String output = String.format("%s is %d years old.", nationality, age);

    for (int i = 0; i <= 3; i++) {
      System.out.print("repeating myself ");
    }

    // Not sure this test is necessary
    if ( args.length > 0 ) {
      for (String arg : args) {
        System.out.println(arg);
      }
    }

   System.out.println(Arrays.toString(a));

  }

}

// Additional classes, if they existed here, would have generated foo.class,
// foo2.class, etc. along with HelloWorld.class in the pwd.

/** Documentation would go here */
