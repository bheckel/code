
package com.zetcode;

// The import allows a shorthand referring for classes. This is different from
// some other languages. For instance in Python, the import keyword imports
// objects into the namespace of a script. In Java, the import keyword only
// saves typing by allowing to refer to types without specifying the full name. 
import java.util.Scanner;

public class ReadLine {

    public static void main(String[] args) {
        
        System.out.print("Write your name:");

        Scanner sc = new Scanner(System.in);
        String name = sc.nextLine();

        System.out.println("Hello " + name);
    }
}
