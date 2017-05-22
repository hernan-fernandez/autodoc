Introduction
============

This is an scalable shell script software that will automatically create an detailed engineering document of every of your Linux / Unix Server. Today I'm easily documenting the status of 700 servers.

The system is pretty scalable add another bunch of servers just mean add their ip address


Why I have created this?
========================

When someone implement a new linux / unix server, an detailed engineering document is also created with all the configuration specs. The problem is that this document become obsolete very quickly. The problems is that if you manage dozens or hundred of servers like me, manually update the servers turn into an impossible task.



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

Why Wordpress?

I don't want to create a new CMS. Wordpress is fine but you can replace it easily, to upload the documents I'm using XML-RPC, this is supported by other systems too, so you can adapt it too your needs.


Document Structure
==================

At the moment every document will contain the following information.

* General Information
* Rol of the server or Important detected Software
* Network Configuration
  * Network cards
  * Route table and gateway
  * DNS Servers
* Disk Configuration
  * Filesystems
  * Block Devices
  * Local Mounted Filesystems
  * Remote Mounted Filesystems
* AutoStart Services
* Last Installed Software
* Process with major CPU Usage
* Process with major RAM Usage
* Configuration Files
  * File /etc/hosts
  * File /etc/passwd
  * File /etc/group

How massively run the shell script?
==================================

I recommend you sync the ssh key with all your servers, but if dont you can use sshpass.

```
#!/bin/bash
date
mkdir output
while read -u 5 -r input; do
        echo "Copying script to remot host $input"
        timeout 50 /usr/bin/time -f "%e %C" sshpass -ppassword scp -o  UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no autodoc_master.sh username@$input:/tmp 2>>/tmp/time.ssh.txt

        echo "running script on remot host $input"
        timeout 50 sshpass -ppassword ssh -o StrictHostKeyChecking=no username@$input /tmp/autodoc_master.sh $input > output/$input
        echo "listo $input"

done 5<SERVER_LIST.txt
date

```
The documentation will be saved on output directory


**SERVER_LIST.txt**
Each line of this file will contain a remote server.

```
1.2.3.4
hostone.local
hosttwo.local
hostthree.client
5.6.7.8
```
