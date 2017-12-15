//////////////////////////////////////////////////////////////////////////////
//     Name: singly_linkedlist.h
//
//  Summary: Declaration of a singly linked list.
//
//  Adapted: Sat 04 Jan 2003 11:49:13 (Bob Heckel -- C++ For C Programmers 
//                                     Ira Pohl)
//////////////////////////////////////////////////////////////////////////////
#ifndef SINGLY_LINKEDLIST_H
#define SINGLY_LINKEDLIST_H

struct slistelem {
  char data;
  slistelem* next;
};


class slist {
  private:
    slistelem* h;  // head of slist
  public:
    slist() : h (0) {}  // 0 denotes empty slist
    ~slist();
    void prepend(char c);
    void del();
    inline slistelem* first() const { return h; }
    void print() const;
    void release();
};

#endif
