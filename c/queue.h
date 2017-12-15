// Interface for a queue.
#ifndef QUEUE_H_
#define QUEUE_H_

// Queue will contain Customer items.
class Customer {
  private:
    long arrive;
    int processtime;
  public:
    Customer() { arrive = processtime = 0; }
    void set(long when);
    long when() const { return arrive; }
    int ptime() const { return processtime; }
};

typedef Customer Item;

class Queue {
  // Class scope definitions:
  // Node is a nested structure definition local to this class.
  struct Node { Item item; struct Node * next; };
  enum {Q_SIZE = 10};
  private:
    Node * front;     // ptr to front of Queue
    Node * rear;
    int items;        // current num of items in Queue
    const int qsize;  // max num of items in Queue
    // Preemptive definition to prevent public copying.
    Queue(const Queue & q) : qsize(0) {};
    Queue & operator=(const Queue & q) { return *this; }
  public:
    Queue(int qs = Q_SIZE);  // create Queue with Q_SIZE limit
    ~Queue();
    bool isempty() const;
    bool isfull() const;
    bool queuecount() const;
    bool enqueue(const Item &item);  // add item to end
    bool dequeue(Item &item);        // remove item from front
};

#endif
