# Ansible OpenVPN gateway

Чистая версия проекта для настройки VPN-сервера и firewall на Debian/Ubuntu.

## Структура

- [inventory/hosts.yml](inventory/hosts.yml) — inventory для хостов
- [group_vars/all.yml](group_vars/all.yml) — общие переменные
- [group_vars/vpn_servers.yml](group_vars/vpn_servers.yml) — переменные для VPN-хоста
- [group_vars/vpn_secrets.yml.example](group_vars/vpn_secrets.yml.example) — пример секретов
- [playbooks/play.yml](playbooks/play.yml) — точка входа
- [playbooks/roles/openvpn](playbooks/roles/openvpn) — установка и настройка OpenVPN
- [playbooks/roles/gw](playbooks/roles/gw) — firewall и NAT

## Секреты

Не храните реальные сертификаты и ключи в git. Создайте файл `group_vars/vpn_secrets.yml` и заполните его данными:

- `openvpn_ca_cert`
- `openvpn_server_cert`
- `openvpn_server_key`
- `openvpn_dh_params`

Лучше шифровать его через Ansible Vault:

```bash
ansible-vault create group_vars/vpn_secrets.yml
```

## Запуск

```bash
ansible-playbook playbooks/play.yml
```

> В этом проекте все ключевые параметры вынесены в vars, поэтому легко менять адреса, подсети, порты и whitelist без правки самого кода.
