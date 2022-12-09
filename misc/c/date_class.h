// Fig. 8.6: date1.h
// Definition of class Date
// Adapted: Sun Feb 23 20:21:03 2003 (Bob Heckel)
#ifndef DATE1_H
#define DATE1_H
#include <iostream>

using std::ostream;

class Date {
  friend ostream &operator<<(ostream&, const Date&);

public:
  Date(int m=1, int d=1, int y=1900); // constructor
  void setDate(int, int, int); // set the date
  Date& operator++();          // preincrement operator
  Date operator++(int);        // postincrement operator
  const Date& operator+=(int); // add days, modify object
  bool leapYear(int) const;    // is this a leap year?
  bool endOfMonth(int) const;  // is this end of month?

private:
  int month;
  int day;
  int year;

  static const int days[];       // array of days per month
  void helpIncrement();          // utility function
};

#endif



/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
