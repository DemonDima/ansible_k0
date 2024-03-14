#!/bin/bash

export IPT="iptables"

# Внешний интерфейс
export WAN=eth0
export WAN_IP={{ ansible_host }}

# Список разрешенных хостов
export ALLOW_IP=185.197.161.44,193.42.109.24,82.146.35.177,91.227.136.24
#export ALLOW_IP_ADMIN=178.210.32.198,85.17.28.150

# Локальная сеть
export LAN=tun0
export LAN_IP_RANGE=10.8.{{ subnet }}.0/24

# VPN
#export VPN=tun0
#export VPN_IP=10.8.40.70
#export VPN_IP_ALLOW=10.8.40.1,10.8.40.26,10.8.40.30
#export VPN_IP_C=10.8.40.26
#export VPN_IP_U=10.8.40.30

# Очищаем правила
$IPT -F
$IPT -F -t nat
$IPT -F -t mangle
$IPT -X
$IPT -t nat -X
$IPT -t mangle -X

# Запрещаем все, что не разрешено
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

# Разрешаем localhost и локалку
$IPT -A INPUT -i lo -j ACCEPT
#$IPT -A INPUT -i $VPN -j ACCEPT
$IPT -A INPUT -i $LAN -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT
#$IPT -A OUTPUT -o $VPN -j ACCEPT
$IPT -A OUTPUT -o $LAN -j ACCEPT
#$IPT -A INPUT -s $LAN_IP_RANGE -p udp -m addrtype --dst-type MULTICAST -m state --state NEW -m multiport --dports 5404,5405 -j ACCEPT
#$IPT -A INPUT -s $LAN_IP_RANGE -d $LAN_IP_RANGE -p udp -m state --state NEW -m multiport --dports 5404,5405 -j ACCEPT

# Рзрешаем пинги внешние
$IPT -A INPUT -s $ALLOW_IP -p icmp --icmp-type echo-reply -j ACCEPT
$IPT -A INPUT -s $ALLOW_IP -p icmp --icmp-type destination-unreachable -j ACCEPT
$IPT -A INPUT -s $ALLOW_IP -p icmp --icmp-type time-exceeded -j ACCEPT
$IPT -A INPUT -s $ALLOW_IP -p icmp --icmp-type echo-request -j ACCEPT

# Рзрешаем пинги внутренние
#$IPT -A INPUT -s $VPN_IP_ALLOW -p icmp --icmp-type echo-reply -j ACCEPT
#$IPT -A INPUT -s $VPN_IP_ALLOW -p icmp --icmp-type destination-unreachable -j ACCEPT
#$IPT -A INPUT -s $VPN_IP_ALLOW -p icmp --icmp-type time-exceeded -j ACCEPT
#$IPT -A INPUT -s $VPN_IP_ALLOW -p icmp --icmp-type echo-request -j ACCEPT

$IPT -A INPUT -s $LAN_IP_RANGE -p icmp --icmp-type echo-reply -j ACCEPT
$IPT -A INPUT -s $LAN_IP_RANGE -p icmp --icmp-type destination-unreachable -j ACCEPT
$IPT -A INPUT -s $LAN_IP_RANGE -p icmp --icmp-type time-exceeded -j ACCEPT
$IPT -A INPUT -s $LAN_IP_RANGE -p icmp --icmp-type echo-request -j ACCEPT


# Разрешаем все исходящие подключения сервера
$IPT -A OUTPUT -o $WAN -j ACCEPT
# Разрешаем VPN
$IPT -A OUTPUT -o $LAN -j ACCEPT

# Разрешаем все входящие подключения сервера
#$IPT -A INPUT -i $WAN -j ACCEPT

# разрешаем установленные подключения
$IPT -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A FORWARD -p all -m state --state ESTABLISHED,RELATED -j ACCEPT

# Отбрасываем неопознанные пакеты
$IPT -A INPUT -m state --state INVALID -j DROP
$IPT -A FORWARD -m state --state INVALID -j DROP

# Отбрасываем нулевые пакеты
$IPT -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# Закрываемся от syn-flood атак
$IPT -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
$IPT -A OUTPUT -p tcp ! --syn -m state --state NEW -j DROP

# Блокируем доступ с указанных адресов
#$IPT -A INPUT -s 84.122.21.197 -j REJECT

# Закрываем доступ снаружи в локалку
#$IPT -A FORWARD -i $WAN -o $LAN1 -j REJECT
$IPT -A FORWARD -i $LAN -o $WAN -j ACCEPT

# Пробрасываем внешний порт 23543 на локальный адрес и порт 3389
#$IPT -t nat -A PREROUTING -p tcp --dport 23543 -i ${WAN} -j DNAT --to 10.1.3.50:3389

# Пробрасываем внешний порт udp 5060 на локальный адрес 192.168.26.1 и порт 5060
#$IPT -t nat -A PREROUTING -p udp --dport 5060 --dst ${WAN_IP} -j DNAT --to 192.168.26.1:5060
#$IPT -t nat -A PREROUTING -p udp --dport 5160 --dst ${WAN_IP} -j DNAT --to 192.168.26.1:5160
#$IPT -t nat -A PREROUTING -p tcp --dport 5161 --dst ${WAN_IP} -j DNAT --to 192.168.26.1:5161
#$IPT -t nat -A PREROUTING -p udp --dport 10000:20000 --dst ${WAN_IP} -j DNAT --to 192.168.26.1

# Включаем NAT
$IPT -t nat -A POSTROUTING -o $WAN -s $LAN_IP_RANGE -j MASQUERADE

# открываем доступ SSH, Proxmox, HTTP, https внешний
$IPT -A INPUT -i $WAN -s $ALLOW_IP -p tcp --dport 2112 -j ACCEPT
$IPT -A INPUT -i $WAN -s $ALLOW_IP -p tcp --dport 22 -j ACCEPT
$IPT -A INPUT -i $WAN -p udp --dport 1194 -j ACCEPT


# открываем доступ SSH, Proxmox, HTTP, https внутренний
#$IPT -A INPUT -i $VPN -s $VPN_IP_ALLOW -p tcp --dport 2112 -j ACCEPT
#$IPT -A INPUT -i $VPN -s $VPN_IP_ALLOW -p tcp --dport 22 -j ACCEPT


# Включаем логирование
$IPT -N block_in
$IPT -N block_out
$IPT -N block_fw

$IPT -A INPUT -j block_in
$IPT -A OUTPUT -j block_out
$IPT -A FORWARD -j block_fw

$IPT -A block_in -j LOG --log-level info --log-prefix "--IN--BLOCK"
$IPT -A block_in -j DROP
$IPT -A block_out -j LOG --log-level info --log-prefix "--OUT--BLOCK"
$IPT -A block_out -j DROP
$IPT -A block_fw -j LOG --log-level info --log-prefix "--FW--BLOCK"
$IPT -A block_fw -j DROP

# Сохраняем правила
/sbin/iptables-save  > /etc/iptables.rules
