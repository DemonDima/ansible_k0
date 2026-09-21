# v2: чистый production-ready вариант Ansible

Эта версия организована в более привычной структуре для реального проекта:

- inventory/hosts.yml
- group_vars/all.yml
- group_vars/vpn_servers.yml
- group_vars/vpn_secrets.yml.example
- roles/openvpn
- roles/gw
- site.yml

## Секреты

Не храните реальные сертификаты и ключи в git.
Создайте файл `group_vars/vpn_secrets.yml` и заполните его значениями:

- `openvpn_ca_cert`
- `openvpn_server_cert`
- `openvpn_server_key`
- `openvpn_dh_params`

Лучше зашифровать его через `ansible-vault`.

## Запуск

```bash
ansible-playbook site.yml
```
