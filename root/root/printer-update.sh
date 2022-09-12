#!/bin/sh

call_airprint_generate() {
rm -rf /services/AirPrint-*.service
/root/airprint-generate.py -d /services
cp /etc/cups/printers.conf /config/printers.conf
rsync -avh /services/ /etc/avahi/services/
}

call_airprint_generate

/usr/bin/inotifywait -m -e close_write,moved_to,create /etc/cups | 
while read -r directory events filename; do
	if [ "$filename" = "printers.conf" ]; then
		call_airprint_generate
	fi
done

