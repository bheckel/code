//////////////////////////////////////////////////////////////////////////////
//     Name: queue_bank.cpp
//
//  Summary: Demo of a bank that uses a class that creates a queue.  
//           Automated Teller Machine simulation.
//
//           To compile:
//           $ g++ -g -c  queue.cpp queue_bank.cpp
//           $ g++ -g -o queue.pgm.exe queue.o queue_bank.o
//
//  Adapted: Sun 11 Aug 2002 09:45:24 (Bob Heckel -- C++ Primer v4 Plus 
//                                     Stephen Prata)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;
#include <cstdlib>   // for rand()
#include <ctime>     // for time()
#include "queue.h"


const int MIN_PER_HR = 60;

bool newcustomer(double x);  // is there a new customer?


int main() {
  srand(time(0));

  cout << "Enter max queue size: ";
  int qs;
  cin >> qs;

  Queue line(qs);   // line queue holds up to qs people

  cout << "Enter num of sim hours: ";
  int hours;
  cin >> hours;

  // Simulation will run 1 cycle per minute.
  long cyclelimit = MIN_PER_HR * hours;    // # of cycles

  cout << "Enter avg num of custs per hr: ";
  double perhour;
  cin >> perhour;

  double min_per_cust;   // avg time betw arrivals
  min_per_cust = MIN_PER_HR / perhour;

  Item temp;             // new cust data
  long turnaways = 0;
  long customers = 0;    // joined the queue
  long served = 0;
  long sum_line = 0;     // cumulative line length
  int wait_time = 0;     // time until ATM is free
  int line_wait = 0;     // cumulative time in line

  // Run simulation.
  for ( int cycle=0; cycle<cyclelimit; cycle++ ) {
    if ( newcustomer(min_per_cust) ) {  // we have a newcomer
      if ( line.isfull() )
        turnaways++;
      else {
        customers++;
        temp.set(cycle);     // cycle == time of arrival
        line.enqueue(temp);  // add newcomer to line
      }
    }
    if ( wait_time <= 0 && !line.isempty() ) {
      line.dequeue(temp);    // attend to next cust
      wait_time = temp.ptime();
      line_wait += cycle - temp.when();
      served++;
    }
    if ( wait_time > 0 )
      wait_time--;

    sum_line += line.queuecount();
  }

  // Report results.
  if ( customers > 0 ) {
    cout << endl;
    cout << "custs accepted: " << customers << endl;
    cout << "custs served: " << served << endl;
    cout << "custs turnaway: " << turnaways << endl;
    cout << "avg queue size: ";
    cout.precision(2);
    cout.setf(ios::fixed, ios::floatfield);  // force fixed point
    cout.setf(ios::showpoint);
    cout << (double) sum_line / cyclelimit << endl;
    cout << "avg wait time: " << (double) line_wait / served << " min" << endl;
  } 
  else
    cout << "no custs" << endl;
    
  return 0;
}


// x == avg time in mins, betw custs.
// Return value is true if cust shows up this minute.
bool newcustomer(double x) {
  return (rand() * x / RAND_MAX < 1);
}
