
=============================================================================
Test via
$ telnet locahost 80      

or

$ telnet locahost http
GET / HTTP/1.0
<CR>

or

w3m -dump_head foo.html

=============================================================================
From http://www.irt.org/articles/js078/

GET vs POST
The METHOD attribute controls how the information is sent to the server.
A typical METHOD attribute looks like this: 

METHOD="GET"

or 

METHOD="POST"


If a METHOD is not specified as part of an ACTION, it defaults to GET. 

"What's the difference," you say?

First, though, it's important to remember to provide your form items with
unique and meaningful names. The NAME attribute of your form does this, and
this is what is submitted to the CGI script as part of the name=value pair.
It is very important to remember to put something in these for each and
every item in your form. 

GET (default for following links and passing data on the Internet)
---
GET sends the form information back to the server as part of the URL when
requesting the CGI script. That's not as bad as it sounds, but an example
might help. If you ever used a large search engine like Webcrawler, you
would have noticed how convoluted the URLs look after your search results
have been returned. Typically, they look like this: 

http://www.somewhere.com/cgi-bin/script.pl?firstname=Jason

This one is a bit simple, but do you see that part after the question mark?
That is the information that was contained in the form, in this case, the
form must have contained something like an text field called "firstname",
and the user entered "Jason" as it's value. In CGI terminology, the
information contained in the part of the URL after the question mark is
called the QUERY_STRING, which consists of a string of name=value pairs
separated by ampersands (&). If your form contained two pieces of
information, the URL would look like this: 

http://www.somewhere.com/cgi-bin/script.pl?first=Jason&last=Nugent
    
There are both advantages and disadvantages of using GET to submit
information. Advantages include the ability to "bookmark" search results,
since the submitted information is part of the URL, as well as create
hypertext links which submit information to CGI scripts. The biggest
disadvantage to using GET is that the QUERY_STRING is limited to the input
buffer size of your server. This is typically something like 1024 bytes,
which means that it is possible to submit too much information and lose
some along the way. That is where POST comes in. 

E.g.
$ telnet hpLdev01 80

GET /cgi-bin/create.pl?user=util-tester&pass1=1234&pass2=1234 HTTP/1.0
Referer: file:/tmp/create.html
User-Agent: Mozilla/1.1N (X11; I; SunOS 5.3 sun4m)
Accept: */*
Accept: image/gif
Accept: image/x-xbitmap
Accept: image/jpeg


POST
----
With POST, there is no information added to the URL when a CGI script is
called. Instead, the information is sent after all your request headers
have been sent to the server. The length of the information (in bytes) is
also sent to the server, to let the CGI script know how much information
it has to read in via STDIN (standard in). We'll see how to get at this in
a future article. 

E.g.
$ telnet hpLdev01 80

POST /cgi-bin/create.pl  HTTP/1.0
Referer: file:/tmp/create.html
User-Agent: Mozilla/1.1N (X11; I; SunOS 5.3 sun4m)
Accept: */*
Accept: image/gif
Accept: image/x-xbitmap
Accept: image/jpeg
Content-type: application/x-www-form-urlencoded
Content-length: 40
 
user=util-tester&pass1=1234&pass2=1234


=============================================================================
From http://www.htmlhelp.org/faq/cgifaq.2.html#2

2.8: What is the difference between GET (default) and POST?
Firstly, the HTTP protocol specifies differing usages for the two
methods.   GET requests should always be idempotent on the server.
This means that whereas one GET request might (rarely) change some state
on the Server, two or more identical requests will have no further effect.

This is a theoretical point which is also good advice in practice.
If a user hits "reload" on his/her browser, an identical request will be
sent to the server, potentially resulting in two identical database or
guestbook entries, counter increments, etc.   Browsers may reload a
GET URL automatically, particularly if cacheing is disabled (as is usually
the case with CGI output), but will typically prompt the user before
re-submitting a POST request.   This means you're far less likely to get
inadvertently-repeated entries from POST.

GET is (in theory) the preferred method for idempotent operations, such
as querying a database, though it matters little if you're using a form.
There is a further practical constraint that many systems have builtin
limits to the length of a GET request they can handle: when the total size
of a request (URL+params) approaches or exceeds 1Kb, you are well-advised
to use POST in any case.

In terms of mechanics, they differ in how parameters are passed to the
CGI script.   In the case of a POST request, form data is passed on
STDIN, so the script should read from there (the number of bytes to be
read is given by the Content-length header).   In the case of GET, the
data is passed in the environment variable QUERY_STRING.   The content-type
(application/x-www-form-urlencoded) is identical for GET and POST requests.

