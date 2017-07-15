#!/bin/bash
#
# Questo script per connettere una singola scheda di rete ad access points differenti.
# Controllare se il vostro hardware soddisfi i requisiti minimi prima dell uso
#
# This script allows a single network card to connect to different access points.
# Check if your hardware satisfy the minimum requirements before using it.
#
# License
#
# This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#installo il pacchetto wpasupplicant
echo ===============================
echo Preparazione accesso alla Rete
echo ===============================
sudo apt-get install wpasupplicant &> /dev/null

#salvo il nome della periferica di rete predefinita in una variabile
b=$(iw dev | awk '{for(i=1;i<=NF;i++){if($i~/^wlp/){print $i}}}')
echo Rilevata interfaccia Wi-Fi predefinita: $b

#killo il network manager e disconnetto la rete virtuale di default
echo killing network-manager
sudo service network-manager stop
sudo ip link set dev $b down
echo status interfaccia di default
sudo ip link show dev $b

sleep 1

echo ===============================
echo Creazione Interfaccie virtuali
echo ===============================
#creo interfaccie virtuali sulla periferica fisica
sudo iw phy phy0 interface add rete1 type station
sudo iw phy phy0 interface add rete2 type station
#sudo iw phy phy0 interface add rete3 type station

sudo ifconfig rete1 down
sudo ifconfig rete2 down
#sudo ifconfig rete3 down

sudo ifconfig rete1 hw ether e8:94:f6:4e:b6:94
sudo ifconfig rete2 hw ether e8:94:f6:4e:b6:95
#sudo ifconfig rete3 hw ether e8:94:f6:4e:b6:96

iw dev

echo done

echo ===============================
echo Tiro su le Interfaccie virtuali
echo ===============================
echo tiro su rete 1
sudo ifconfig rete1 up
echo tiro su rete 2
sudo ifconfig rete2 up
#echo tiro su rete 3
#sudo ifconfig rete3 up

echo prima
sudo ip link set dev rete1 up
sudo ip link show dev rete1

echo seconda
sudo ip link set dev rete2 up
sudo ip link show dev rete2

#echo terza
#sudo ip link set dev rete3 up
#sudo ip link show dev rete3

echo done

sleep 1

echo ===============================
echo Connessione alla Rete 1
echo ===============================
sudo wpa_passphrase benedetto1 benedetto1 > /tmp/wpa1.conf
#scansione reti
sudo iw dev rete1 scan &> /dev/null
#connessione alla rete scelta prima con l interfaccia -i e il driver -D
sudo wpa_supplicant -B -D nl80211 -i rete1 -c /tmp/wpa1.conf

#tiro su dhclient sull'interfaccia
echo avvio dhclient sull interfaccia
sudo dhclient -r
sudo dhclient rete1

echo done

sleep 1

echo ===============================
echo Connessione alla Rete 2
echo ===============================
sudo wpa_passphrase benedetto2 benedetto2 > /tmp/wpa2.conf
#scansione reti
sudo iw dev rete2 scan &> /dev/null
#connessione alla rete scelta prima con l interfaccia -i e il driver -D
sudo wpa_supplicant -B -D nl80211 -i rete2 -c /tmp/wpa2.conf

#tiro su dhclient sull'interfaccia
echo avvio dhclient sull interfaccia
sudo dhclient rete2

echo done

sleep 1

#echo ===============================
#echo Connessione alla Rete 3
#echo ===============================
#sudo wpa_passphrase benedetto3 benedetto3 > /tmp/wpa3.conf
#scansione reti
#sudo iw dev rete3 scan &> /dev/null
#connessione alla rete scelta prima con l interfaccia -i e il driver -D
#sudo wpa_supplicant -B -D nl80211 -i rete3 -c /tmp/wpa3.conf

#tiro su dhclient sull'interfaccia
#echo avvio dhclient sull interfaccia
#sudo dhclient rete3

#verifica della connessione
echo ===============================
echo Verifica della Connessioni
echo ===============================
ifconfig rete1
ifconfig rete2
#ifconfig rete3
echo 

#visualizzo indirizzo IP del gateway
route -n
echo 
echo lista routing ip
ip route list

echo ===============================
echo Sistemo il routing
echo ===============================

echo non faccio niente
#sudo route del default gateway 192.168.1.1 dev rete1
#sudo route add -net 10.5.5.0 gw 10.5.5.9 netmask 255.255.255.0 dev rete1
#sudo route add -net 10.5.5.0 gw 10.5.5.9 netmask 255.255.255.0 dev rete2
#sudo route add -net 10.5.5.0 gw 10.5.5.9 netmask 255.255.255.0 dev rete3
#sudo route add default gw 10.5.5.9 rete2
#sudo route add default gw 10.5.5.9 rete3
route -n

#procedure di chiusura e ripristino alla pressione di CTRL+C
int_handler()
{
    echo "Processo ucciso"
    sudo iw dev rete1 disconnect
    sudo iw dev rete2 disconnect
    #sudo iw dev rete3 disconnect
    sudo ip link set dev rete1 down
    sudo ip link set dev rete2 down
    #sudo ip link set dev rete3 down	
    sudo iw dev rete1 del
    sudo iw dev rete2 del
    #sudo iw dev rete3 del
    sudo ip link set $b up
    sudo service network-manager start
    sudo killall -q wpa_supplicant
    # Kill the parent process of the script.
    kill $PPID
    exit 1
}
trap 'int_handler' INT

while true; do
    sleep 1
done

#NOTE E BUG
#n.d.
