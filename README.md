# autodoc

This is an scalable  software that will automatically create an detailed engineering document of every of your Linux / Unix Servers.

It's pretty scalable. Today I'm using to generate the documents for more than 700 servers.


Status of the project
=====================

The software currently support the follwing unix systems

* Linux Support  : 100%
* HP-UX Support  : 50%
* Solaris Support: 0%
* AIX Support    : 0%


Advantages
============

* Scalable, reliable and up-to-date automatic documentation of all linux / unix systems
* Easy access to the documents. A single webpage per server.
* Any authorized person or your client may have access to the details of the server without any risk of break it.
* Ideal for supporting decisions about the systems in meetings.
* It will help you to document system changes (using diff), also a useful tool to support the change management process.



Requirements
============

* IP of every server reachable through SSH 22/TCP Port
* An non-root user account



Software Requirements
---------------------

* Linux Server
* Apache or Nginx Web Server
  * PHP (php-xmlrpc)
* MySQL or MariaDB
* Wordpress
  * Print View Plug-in - Recommended WP-Print : https://es.wordpress.org/plugins/wp-print/
  * Diff Plug-in - Recommended Post Revision Display : https://es.wordpress.org/plugins/post-revision-display/
  * WikiWP (theme) : https://wordpress.org/themes/wikiwp/



