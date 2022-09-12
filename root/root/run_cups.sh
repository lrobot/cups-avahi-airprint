#!/bin/sh
set -e
set -x
ifconfig
addgroup root lpadmin


# Is CUPSADMIN set? If not, set to default
if [ -z "$CUPSADMIN" ]; then
    CUPSADMIN="cupsadmin"
fi

# Is CUPSPASSWORD set? If not, set to $CUPSADMIN
if [ -z "$CUPSPASSWORD" ]; then
    CUPSPASSWORD=$CUPSADMIN
fi

if [ $(grep -ci $CUPSADMIN /etc/shadow) -eq 0 ]; then
    adduser -S -G lpadmin --no-create-home $CUPSADMIN 
fi
echo $CUPSADMIN:$CUPSPASSWORD | chpasswd

mkdir -p /config/ppd
mkdir -p /services
rm -rf /etc/avahi/services/*
rm -rf /etc/cups/ppd
ln -s /config/ppd /etc/cups
if [ `ls -l /services/*.service 2>/dev/null | wc -l` -gt 0 ]; then
	cp -f /services/*.service /etc/avahi/services/
fi
if [ `ls -l /config/printers.conf 2>/dev/null | wc -l` -eq 0 ]; then
    touch /config/printers.conf
fi
cp /config/printers.conf /etc/cups/printers.conf

if [ `ls -l /config/cupsd.conf 2>/dev/null | wc -l` -eq 0 ]; then
    cp /etc/cups/cupsd.conf /config/cupsd.conf
fi

/usr/sbin/avahi-daemon --daemonize
/usr/sbin/cupsd -c /config/cupsd.conf
#lpinfo -m   #list all printer driver
lpinfo -v  #list all printer backend
#lpadmin add new printer
lpadmin -p HL2140CUPS -E -v socket://192.168.99.53 -m $(lpinfo --make-and-model "Brother HL-2140 series" -m | grep 2140 | sed -e  's/ .*//g')
lpstat -v  #show current printer list and stat
/root/printer-update.sh &
sh
#exec /usr/sbin/cupsd -f -c /config/cupsd.conf

