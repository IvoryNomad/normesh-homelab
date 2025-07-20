version: 1
config:
  - type: physical
    name: '${ifname}'
    subnets:
      - type: static
        address: '${ipv4_addr}/${ipv4_mask}'
        gateway: '${ipv4_gw}'
      - type: static6
        address: '${ipv6_addr}/${ipv6_mask}'
        gateway: '${ipv6_gw}'
  - type: nameserver
    address:
%{ for dns in dns_servers ~}
      - '${dns}'
%{ endfor ~}
    search:
%{ for domain in search_domains ~}
      - '${domain}'
%{ endfor ~}
