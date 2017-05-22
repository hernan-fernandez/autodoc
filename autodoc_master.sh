#!/bin/sh
# Autodoc : https://github.com/hernan-fernandez/autodoc/
# Version 0.1
# Hernan Fernandez Retamal


input=$1
PATH=$PATH:$HOME/bin:/sbin:/bin:/usr/sbin:/usr/contrib/bin

DATE=`date +%d-%m-%Y\ %R.%S`
uptime_dias=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')

TableOfContent () {

echo "<div class='page-break'></div>
<h2>Introduction</h2>

The server <b> $(hostname) </b> is $(uname) server and has an uptime if $uptime_dias since last reboot.
The following document has been automatically generated on $DATE

<!--more-->

<h2>Table of Content</h2>
<ol>
        <li><a href='#general'>General Information</a></li>
        <li><a href='#role'>Rol of the server</a></li>
        <li><a href='#network'>Network Configuration</a></li>
<li>
<ol>
        <li><a href='#ifconfig'>Network cards</a></li>
        <li><a href='#netstat'>Route tables and gateway</a></li>
        <li><a href='#resolv'>DNS Servers</a></li>
</ol>
</li>
        <li><a href='#disk'>Disk Configuration</a></li>
<li>
<ol>
        <li><a href='#df'>Filesystems</a></li>
        <li><a href='#lsblk'>Block Devices</li>
        <li><a href='#mount'>Mounted Filesystems</a></li>
</ol>
</li>
        <li><a href='#services'>Autostart Services</a></li>
        <li><a href='#lastupdate'>Last Installed Software</a></li>
        <li><a href='#cpuuse'>Process with major CPU Usage</a></li>
        <li><a href='#ramuse'>Process with major RAM Usage</a></li>

        <li><a href='#hostfile'>Configuration Files</a></li>
        <li>
        <ol>
        <li><a href='#hostfile'>/etc/hosts file</a></li>
        <li><a href='#userfile'>/etc/passwd file</a></li>
        <li><a href='#groupfile'>/etc/group file </a></li>
        </ol>
        </li>
</ol>
<div class='page-break'></div>"
}

InfoOSLinux () {

        echo "<h2 id='general'>General Information</h2>"
        echo "General Information about the server $(hostname)"
        echo "<pre>"
    if hash hostnamectl 2>/dev/null; then
        hostnamectl
    else
                #os_version=$(uname -o)
                if [ -f "/etc/system-release" ]; then
                        os_version=$(cat /etc/system-release);
                elif [ -f "/etc/redhat-release" ]; then
                        os_version=$(cat /etc/redhat-release);
                elif [ -f "/etc/issue" ]; then
                        os_version=$(cat /etc/issue |grep -v ^$);
                elif [ -z ${os_version+x} ]; then
                        os_version=$(uname -o);
                fi

                echo "<strong>Hostname         :</strong> $(hostname)"
                echo "<strong>Operating System :</strong> $os_version"
                echo "<strong>Kernel           :</strong> $(uname -r)"
                echo "<strong>Uptime           :</strong> $(uptime)"
        fi
        echo "</pre>"
}

InfoOSHPUX () {
        echo "<h2 id='general'>General Information</h2>"
        echo "Information about the server $(hostname)"
        echo "<pre>"
        echo "<strong>IP server      :</strong>  $input"
        echo "<strong>Hostname       :</strong>  $(hostname)"
        echo "<strong>Version        :</strong>  $(uname -a)"
        echo "<strong>Uptime         :</strong>  $(uptime)"
        echo "</pre>"
}


InfoIpsLinux () {
        #ip=$(/sbin/ifconfig -a |grep "inet " |awk '{print $2}' |awk -F":" '{if ($2-eq"") print $1; else print $2}' |grep -v 127.0.0.1)

        ip=$(ifconfig -a |grep "inet " |awk '{print $2}' |awk -F":" '{if ($2) print $2; else print $1}'|grep -v 127.0.0.1)

        echo "<h2>Direcciones IP</h2><pre>
$ip</pre>"

        count_ip=$(echo "$ip" | grep -v ^$ | wc -l)

        if (( $count_ip == 1 )); then
                echo "<b>NOTE:</b> Cannot detect backup ip address"
        fi

}


InfoIpsHPUX () {
        ip=$(netstat -in | awk '{print $4}' |grep -v Address |grep -v 127.0.0.1)

        echo "<pre><strong>IP Address</strong>
        $ip
        </pre>"
}

InfoSystemLinux () {
        echo "<h2>Hardware Information</h2>"
        echo "<pre>"
    if hash dmidecode 2>/dev/null; then
dmidecode -t system |grep Manufacturer
dmidecode -t system |grep Product
dmidecode -t system |grep -i  "Serial Number"
        fi
        echo -n "        Number of CPU : "; cat /proc/cpuinfo |grep processor |wc -l
        echo -n "        CPU Model     : "; cat /proc/cpuinfo |grep "model name" |sort -u |awk -F":" '{print $2}'
        echo -n "        Meminfo       : "; cat /proc/meminfo |grep MemTotal |awk '{print $2 $3}'
        echo "</pre>
        <div class='page-break'></div>"
}

InfoSystemHPUX () {
        echo "<h2>Hardware Information</h2>"
        echo "<pre>"
        machinfo
        echo "</pre>
        <div class='page-break'></div>"
}


DetectLinuxRole () {
        echo "<h2 id='role'>Detected Applications</h2>"
        echo "The following running apps has been detected in this server. This will define the Server Rol."

        #psoutput=$(ps -o comm  --ppid 2 -N --deselect -U root |sort -u |egrep -vi COMMAND\|grep\|ps\|sort\|hald\|nrpe\|ntpd\|dbus\|pickup\|qmgr\|chronyd\|bash\|avahi\|dnsmasq\|lsmd\|sshd\|sftp-server\|rpc\|polkitd\|uuidd\|sh\|tail\|cat\|postdrop\|sftp\|sendmail\|cleanup\|bounce\|nagios\|crond\|gnome\|gconf\|metacity\|snmp\|gvfsd\|bonobo\|gdm\|portmap\|pulseaudio\|rtkit-daemon\|at-spi-registry\|perl\|python\|xfs\|postmaster)

        psoutput=$(ps -o comm  --ppid 2 -N |sort -u |egrep -vi COMMAND\|grep\|ps\|sort\|hald\|nrpe\|ntpd\|dbus\|pickup\|qmgr\|chronyd\|bash\|avahi\|dnsmasq\|lsmd\|sshd\|sftp-server\|rpc\|polkitd\|uuidd\|sh\|tail\|cat\|postdrop\|sftp\|sendmail\|cleanup\|bounce\|nagios\|crond\|gnome\|gconf\|metacity\|snmp\|gvfsd\|bonobo\|gdm\|portmap\|pulseaudio\|rtkit-daemon\|at-spi-registry\|perl\|python\|xfs\|postmaster)

        exit_status=$?

        if [ $exit_status -eq 1 ]; then
                #psoutput=$(ps -fea | grep -v ^root | awk '{ print $8}' |sort -u |egrep -vi COMMAND\|grep\|ps\|sort\|hald\|nrpe\|ntpd\|dbus\|pickup\|qmgr\|chronyd\|bash\|avahi\|dnsmasq\|lsmd\|sshd\|sftp-server\|rpc\|polkitd\|uuidd\|sh\|tail\|cat\|postdrop\|sftp\|sendmail\|cleanup\|bounce\|nagios\|crond\|gnome\|gconf\|metacity\|snmp\|gvfsd\|bonobo\|gdm\|portmap\|pulseaudio\|rtkit-daemon\|at-spi-registry\|perl\|python\|xfs\|postmaster)

                psoutput=$(ps -fea | awk '{ print $8}' |sort -u |egrep -vi COMMAND\|grep\|ps\|sort\|hald\|nrpe\|ntpd\|dbus\|pickup\|qmgr\|chronyd\|bash\|avahi\|dnsmasq\|lsmd\|sshd\|sftp-server\|rpc\|polkitd\|uuidd\|sh\|tail\|cat\|postdrop\|sftp\|sendmail\|cleanup\|bounce\|nagios\|crond\|gnome\|gconf\|metacity\|snmp\|gvfsd\|bonobo\|gdm\|portmap\|pulseaudio\|rtkit-daemon\|at-spi-registry\|perl\|python\|xfs\|postmaster)
        fi


        cant_process=$(echo "$psoutput" | grep -v ^$ |wc -l)

        echo "<pre>"

        if (( $cant_process > 0 )); then
                apache=$(echo "$psoutput" |egrep -i apache\|httpd | wc -l)
                nginx=$(echo "$psoutput" |grep -i nginx | wc -l)
                oracle=$(echo "$psoutput" |egrep -i oracle\|ora_ | wc -l)
                mysql=$(echo "$psoutput" |egrep -i mysqld\|mariadb | wc -l)
                postgresql=$(echo "$psoutput" |grep -i postgres | wc -l)
                sap=$(echo "$psoutput" |egrep -i sap\|jstart | wc -l)
                java=$(echo "$psoutput" |grep -i java | wc -l)
                weblogic=$(echo "$psoutput" |egrep -i WebLogic\|startNodeManage | wc -l)
                dns=$(echo "$psoutput" |egrep -i named\|bind | wc -l)


                if (( $apache > 0 )); then
                        echo "<span class='apacheicon'>Apache WebServer</span>"
                fi

                if (( $nginx > 0 )); then
                        echo "<span class='nginxicon'>Nginx WebServer</span>"
                fi

                if (( $oracle > 0 )); then
                        echo "<span class='oracleicon'>Oracle Database</span>"
                fi

                if (( $mysql > 0 )); then
                        echo "<span class='mysqlicon'>MySQL Server</span>"
                fi

                if (( $postgresql > 0 )); then
                        echo "<span class='postgresicon'>Postgresql</span>"
                fi

                if (( $sap > 0 )); then
                        echo "<span class='sapicon'>SAP Application</span>"
                fi

                if (( $java > 0 )); then
                        echo "<span class='javaicon'>Java Application</span>"
                fi

                if (( $weblogic > 0 )); then
                        echo "<span class='weblogicicon'>Weblogic</span>"
                fi

                if (( $dns > 0 )); then
                        echo "<span class='dnsicon'>DNS Server</span>"
                fi
        else
                echo "No known services has been detected in this server.";
        fi
        echo "</pre>"
}


ServicesAutoStart () {
        echo "<h2 id='services'>Autostart Services</h2>"
        echo "The server autostart services are."
        echo "<pre>"

        if hash systemctl 2>/dev/null; then
                echo "<!-- systemctl1 -->"
        systemctl list-unit-files |grep enabled
                echo "<!-- systemctl2 -->"
        elif hash chkconfig 2>/dev/null; then
                echo "<!-- chkconfig1 -->"
                chkconfig --list |grep "3:on\|5:on"
                echo "<!-- chkconfig2 -->"
        else
                echo "Runlevel 2"
                ls -l /etc/rc2.d/S* | awk '{print $NF}' |sort -u
                echo "Runlevel 3"
                ls -l /etc/rc3.d/S* | awk '{print $NF}' |sort -u

                ls -l /sbin/rc3.d/S* | awk '{print $NF}' |sort -u

                echo "Runlevel 5"
                ls -l /etc/rc5.d/S* | awk '{print $NF}' |sort -u
        fi
        echo "</pre>
        <div class='page-break'> </div>"
}

NetworkConfigLinux () {
        echo "<h2 id='network'>Network Configuration</h2>"
        echo "<span id='ifconfig'>Network cards configured in this server <b>ifconfig -a</b>"
        echo "<pre><small>"
        ifconfig -a
        echo "</small></pre>"

        echo "<div class='page-break'></div>"
        echo "<h2 id='netstat'>Default Gateway</h2>"
        echo "Route tables and default gateway: <b>netstat -nr</b>"
        echo "<pre><small>"
        netstat -nr
        echo "</small></pre>"

        echo "<h2 id='resolv'>DNS Servers</h2>"
        echo "<span id='resolv'>Configured DNS Servers <b>/etc/resolv.conf</b>"
        echo "<pre>"
        cat /etc/resolv.conf |grep -v "^#" |grep -v ^$
        echo "</pre>
        <div class='page-break'> </div>"
}


NetworkConfigHPUX () {
        echo "<h2 id='network'>Network Configuration</h2>"
        echo "<span id='ifconfig'>Network cards configured in this server <b>ifconfig -a</b>"
        echo "<pre>"
        lanscan -p | while read lan
        do
        ifconfig lan${lan}
        done 2>/dev/null
        echo "</pre>"

        echo "<h2 id='netstat'>Default Gateway</h2>"
        echo "Tablas de rutas y default gateway: <b>netstat -nr</b>"
        echo "<pre>"
        netstat -nr
        echo "</pre>"

        echo "<h2 id='resolv'>DNS Servers</h2>"
        echo "<span id='resolv'>Configured DNS Servers <b>/etc/resolv.conf</b>"
        echo "<pre>"
        cat /etc/resolv.conf |grep -v "^#" |grep -v ^$
        echo "</pre>
        <div class='page-break'> </div>"
}


DiskConfigLinux () {

        echo "<h2 id='disk'>Disk Configuration</h2>"
        echo "<span id='df'>Local Filesystem  <b>df -hPl</b>"
        echo "<pre>"
        df -hPl
        echo "</pre>"

        #echo "<b>pvs</b>"
        #echo "<pre>"
        #pvs
        #echo "</pre>"

        #echo "vgs"
        #echo "<pre>"
        #vgs
        #echo "</pre>"

        #echo "lvs"
        #echo "<pre>"
        #lvs
        #echo "</pre>"

        #echo "vgdisplay -v"
        #echo "<pre>"
        #vgdisplay -v
        #echo "</pre>"

        if hash lsblk 2>/dev/null; then
                echo "<h2 id='lsblk'>Block Devices</h2>"
                echo "Block devices list.
                <b>lsblk</b>"
                echo "<pre>"
                lsblk
                echo "</pre>"
        fi

        echo "<div class='page-break'> </div>"
        echo "<h2 id='lsblk'>Local Mount points</h2>"
        echo "<span id='mount'>Local Mount points <b>mount</b>"
        echo "<pre><small>"
        mount | column -t | grep -v ":"
        echo "</small></pre>"
        echo "<div class='page-break'></div>"

        remote_mount=$(mount | column -t | grep ":")
        count_mount=$(echo "$remote_mount" | grep -v ^$ | wc -l)

        if (( $count_mount > 0 )); then
                echo "<h2 id='lsblk'>Remote Mount Points</h2>"
                echo "Remote Mount Points <b>mount | column -t | grep ":"</b>"
                echo "<pre><small>"
                echo "$remote_mount"
                echo "</small></pre>"
        fi

        echo "<div class='page-break'> </div>"
}

DiskConfigHPUX () {
        echo "<h2 id='disk'>Disk Configuration</h2>"
        echo "<span id='df'>local disks <b>df -hPl</b>"
        echo "<pre>"
        bdf | awk '{if (NF-eq1) {line=$0;getline;sub(" *"," ");print line$0} else {print}}'
        echo "</pre>"

        echo "<h2>Volume Groups</h2>"
        echo "<b>vgdisplay -v</b>"
        echo "<pre>"
        vgdisplay -v
        echo "</pre>"

        echo "<h2>Disks Information</h2>
        <b>ioscan -fnNkCdisk</b>"
        echo "<pre>"
        ioscan -fnNkCdisk #11.31
        ioscan -fnkCdisk #pre-11.31
        echo "</pre>"

        echo "<h2 id='lsblk'>Local Mount points</h2>"
        echo "<span id='mount'>Local Mount points <b>mount</b>"
        echo "<pre>"
        mount -p
        echo "</pre>"
        echo "<div class='page-break'> </div>"

}

LastUpdateLinux () {
        echo "<h2 id='role'>Last Installed Software</h2>"
        echo "Last 25 software packages installed in the server"
        echo "<pre><small>"
        #redhat
        if hash rpm 2>/dev/null; then
                rpm -qa --last  |head -25
        else
                grep install /var/log/dpkg.log |tail -25
                grep install /var/log/dpkg.log.[0-9] |tail -25
                zcat /var/log/dpkg.log.*.gz |grep install  |sort  |tail -25
        fi
        echo "</small></pre>"
        echo "<div class='page-break'> </div>"
}

CPUProcessLinux () {
        echo "<h2 id='cpuuse'>Five Major CPU usage process</h2>"
        echo "Stats with the five process with major CPU usage since last process or server restart."
        echo "<pre>"
        echo "CPU Time Process"
        ps -e -o time,comm |grep -v COMMAND | sort -nr | head -5
        echo "</pre>"
}


RAMProcessLinux () {
        echo "<h2 id='ramuse'>Five Major RAM usage process</h2>"
        echo "Stats with the five process with major RAM usage since last process or server restart."
        echo "<pre>"
        echo "Memory  User  Process"
        ps -e -o 'vsz user comm' |sort -nr|head -5
        echo "</pre>"
        echo "<div class='page-break'> </div>"
}


CambioHoraLinux () {
        echo "<h2 id='cambiohora'>Daylight Saving Time</h2>"
        echo "Next daylight saving time changes"

        DATE1=`date +%Y`
        DATE2=$((DATE1 + 1))
        echo "Year $DATE1."
        echo "<pre><small>"
        zdump -v /etc/localtime |grep $DATE1
        echo "</small></pre>"

        echo "Year $DATE2."
        echo "<pre><small>"
        zdump -v /etc/localtime |grep $DATE2
        echo "</small></pre>"
        echo "<div class='page-break'> </div>"

}


NtpConf () {

        echo "<h2 id='ntp'>NTP Config</h2>"
        echo "File /etc/ntp.conf"
        echo "<pre>"
        if [ -f "/etc/ntp.conf" ]; then
                cat /etc/ntp.conf |grep -v "^#" |grep -v ^$
        elif [ -f "/etc/chrony.conf" ]; then
                echo "/etc/chrony.conf detectado"
                cat /etc/chrony.conf |grep -v "^#" |grep -v ^$
        else
                echo "/etc/ntp.conf not found"
        fi
        echo "</pre>"

        echo "<h2>Time sync</h2>"
        echo "<pre><small>"

        if hash ntpq 2>/dev/null; then
                echo "Command: ntpq -p"
                ntpq -p
        elif hash ntpq 2>/dev/null; then
                echo "Command: ntpdate -p"
                ntpdate -p
        elif hash timedatectl 2>/dev/null; then
                echo "Command: timedatectl"
                timedatectl
        else
                echo "config not found"
        fi
        echo "</small></pre>"
}


HostFile () {
        echo "<h2>Configuration files</h2>"
        echo "<h2 id='hostfile'>/etc/hosts File</h2>"
        echo "Content of /etc/hosts file"
        echo "<pre>"
        cat /etc/hosts  |grep -v "^#" |grep -v ^$
        echo "</pre>"
        echo "<div class='page-break'></div>"
}

UserFile () {
        echo "<h2 id='userfile'>/etc/passwd file</h2>"
        echo "Content of /etc/passwd file"
        echo "<pre>"
        cat /etc/passwd  |grep -v "^#" |grep -v ^$
        echo "</pre>"
        echo "<div class='page-break'></div>"
}

GroupFile () {
        echo "<h2 id='groupfile'>/etc/group file</h2>"
        echo "Content of /etc/group file"
        echo "<pre>"
        cat /etc/group  |grep -v "^#" |grep -v ^$
        echo "</pre>"
        echo "<div class='page-break'></div>"
}




CoverPage () {
DATE=`date +%d-%m-%Y\ %R.%S`
echo "<img class='aligncenter wp-image-2623' src='/wp-content/uploads/2017/03/2.png' alt='' width='100%' height='100%' />

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;
<h1  style='text-align: center;'>Detailed Engineering Document
$(uname -s)
$(hostname) - $1</h1>
&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;
$DATE
<img class='aligncenter wp-image-2622 size-full' src='/wp-content/uploads/2017/03/portada.jpg' alt='' width='100%' height='100%' />";
echo "<div class='page-break'></div>"
}

unamestr=`uname`

case "$unamestr" in
        SunOS*)
                echo "SOLARIS"
                ;;
        HP-UX*)
                CoverPage $input
                TableOfContent $input
                InfoOSHPUX
                InfoIpsHPUX
                InfoSystemHPUX
                NetworkConfigHPUX
                DiskConfigHPUX
                ServicesAutoStart
                HostFile
                UserFile
                GroupFile
                NtpConf
                ;;
        Linux*)
                CoverPage $input
                TableOfContent $input
                InfoOSLinux
                InfoIpsLinux
                InfoSystemLinux
                DetectLinuxRole
                NetworkConfigLinux
                DiskConfigLinux
                ServicesAutoStart
                LastUpdateLinux
                CPUProcessLinux
                RAMProcessLinux
                CambioHoraLinux
                NtpConf
                HostFile
                UserFile
                GroupFile
                ;;
        FreeBSD*)
                echo "AIX"
                ;;
        AIX*)
                echo "AIX"
                ;;
        *)
                echo "unknown: $unamestr"
                ;;
esac

