// Fig. 8.6: date1.cpp
// Member function definitions for Date class
// Adapted: Sun Feb 23 20:27:00 2003 (Bob Heckel)
#include <iostream>
#include "date_class.h"

// Initialize static member at file scope; one class-wide copy.
const int Date::days[] = { 0, 31, 28, 31, 30, 31, 30,
                           31, 31, 30, 31, 30, 31 };

// Date constructor.
Date::Date(int m, int d, int y) { setDate(m, d, y); }

// Set the date.
void Date::setDate(int mm, int dd, int yy) {
  month = (mm >= 1 && mm <= 12) ? mm : 1;
  year = (yy >= 1900 && yy <= 2100) ? yy : 1900;

  // test for a leap year
  if ( month == 2 && leapYear(year) )
     day = (dd >= 1 && dd <= 29) ? dd : 1;
  else
     day = (dd >= 1 && dd <= days[month]) ? dd : 1;
}

// Preincrement operator overloaded as a member function.
Date& Date::operator++() {
  helpIncrement();

  return *this;  // reference return to create an lvalue
}

// Postincrement operator overloaded as a member function.  Note that the
// dummy integer parameter does not have a parameter name.
Date Date::operator++(int) {
  Date temp = *this;
  helpIncrement();

  // Return non-incremented, saved, temporary object.
  return temp;   // value return; not a reference return
}

// Add a specific number of days to a date.
const Date& Date::operator+=(int additionalDays) {
  for ( int i = 0; i < additionalDays; i++ )
    helpIncrement();

  return *this;    // enables cascading
}

bool Date::leapYear(int y) const {
  if ( y % 400 == 0 || (y % 100 != 0 && y % 4 == 0) )
    return true;   // a leap year
  else
    return false;  // not a leap year
}

// Determine if the day is the end of the month.
bool Date::endOfMonth(int d) const {
  if ( month == 2 && leapYear(year) )
    return d == 29; // last day of Feb. in leap year
  else
    return d == days[month];
}

// Function to help increment the date.
void Date::helpIncrement() {
  if ( endOfMonth(day) && month == 12 ) {  // end year
    day = 1;
    month = 1;
    ++year;
  }
  else if ( endOfMonth(day) ) {            // end month
    day = 1;
    ++month;
  }
  else       // not end of month or year; increment day
    ++day;
}

// Overloaded output operator
ostream& operator<<(ostream &output, const Date &d) {
  static char *monthName[13] = { "", "January",
     "February", "March", "April", "May", "June",
     "July", "August", "September", "October",
     "November", "December" };

  output << monthName[d.month] << ' ' << d.day << ", " << d.year;

  return output;   // enables cascading
}



/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
