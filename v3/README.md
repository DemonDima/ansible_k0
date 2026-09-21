# Ansible Vault variant

Чистая структура проекта с хранением TLS-секретов в `ansible-vault`.

## Структура

- `inventory/hosts.yml`
- `group_vars/all.yml`
- `group_vars/vpn_servers.yml`
- `group_vars/vpn_secrets.yml` — создаётся через `ansible-vault`
- `roles/openvpn/...`
- `roles/gw/...`
- `site.yml`

## Создание секретного файла

```bash
mkdir -p group_vars
cp group_vars/vpn_secrets.yml.example group_vars/vpn_secrets.yml
ansible-vault encrypt group_vars/vpn_secrets.yml
```

После этого откройте зашифрованный файл:

```bash
ansible-vault edit group_vars/vpn_secrets.yml
```

И заполните переменные:

- `openvpn_ca_cert`
- `openvpn_server_cert`
- `openvpn_server_key`
- `openvpn_dh_params`

## Запуск

```bash
ansible-playbook site.yml
```

> В этом варианте сертификаты и ключи не хранятся в git в открытом виде.
