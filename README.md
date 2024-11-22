# Traefik Reverse Proxy with Crowdsec WAF

## Components

### Traefik

This reverse proxy is used to serve all the web apps on the server and is also responsible for certificate creation and renewal. It also redirects all HTTP traffic to HTTPS.

#### How to Expose a Service

To create a new service and expose it with Traefik, it must be in the traefik network and add these labels in a docker-compose:

```yaml
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=traefik"
      - "traefik.http.services.FIXME.loadbalancer.server.port=80"
      - "traefik.http.routers.FIXME.rule=Host(`FIXME.${TOP_DN}`)"
      - "traefik.http.routers.FIXME.tls.certresolver=le"
```


#### Let's encrypt configuration

FIXME

#### HTPASSWORD generation for traefik admin page

FIXME

#### Log Rotation

FIXME

### Robots

This WAF also exposes a `robots.txt` file on all running routers at the top level, accessible at `HOSTNAME/robots.txt`.

### Crowdsec

CrowdSec is an open-source cybersecurity platform that detects and blocks malicious behavior in real time, sharing anonymized threat intelligence with a global community. Lightweight, easy to use, and compatible with various systems.

In this setup, the engine runs in a container and parses Traefik access logs to detect threats. The bouncer, responsible for blocking requests from banned hosts, is a [Traefik plugin](https://plugins.traefik.io/plugins/6335346ca4caa9ddeffda116/crowdsec-bouncer-traefik-plugin) that communicates with the engine.

The setup is inspired by the [CrowdSec documentation](https://docs.crowdsec.net/docs/intro/) and [this blog article](https://www.crowdsec.net/blog/enhance-docker-compose-security).

#### Setup

1. Start the CrowdSec service.
2. Create an account on [CrowdSec](https://app.crowdsec.net/).
3. Enroll the engine by following [this documentation](https://docs.crowdsec.net/u/getting_started/post_installation/console/#your-first-enrollment) and running:  
   ```sh
   docker exec crowdsec cscli console enroll XXXXX
   ```
4. Restart the crowdsec service.
5. Create a bouncer key with:  
   ```sh
   docker exec crowdsec cscli bouncers add traefik-bouncer
   ```
   Then set the key in the `CS_BOUNCER_KEY_TRAEFIK` variable in the `.env` file.
6. Create a discord webhook and set it in `CS_DISCORD_WEBHOOK` in the `.env` file.
7. Restart all service.

#### Test Notifications

To test Discord notifications, run:  

```sh
docker exec crowdsec cscli notifications test discord
``` 

#### Show decissions

```sh
docker compose exec crowdsec cscli decision list
```

```
╭────────┬──────────┬─────────────┬───────────────────────────────────────┬────────┬─────────┬───────────────────────────────────────────────────────┬────────┬────────────┬──────────╮
│   ID   │  Source  │ Scope:Value │                 Reason                │ Action │ Country │                           AS                          │ Events │ expiration │ Alert ID │
├────────┼──────────┼─────────────┼───────────────────────────────────────┼────────┼─────────┼───────────────────────────────────────────────────────┼────────┼────────────┼──────────┤
│ 208206 │ crowdsec │ Ip:....     │ crowdsecurity/CVE-2017-9841           │ ban    │ US      │ 45102 Alibaba US Technology Co., Ltd.                 │ 1      │ 18h55m56s  │ 54       │
│ 156376 │ crowdsec │ Ip:....     │ crowdsecurity/http-probing            │ ban    │ PT      │ 12353 Vodafone Portugal - Communicacoes Pessoais S.A. │ 11     │ 15h21m4s   │ 48       │
│ 156374 │ crowdsec │ Ip:....     │ crowdsecurity/thinkphp-cve-2018-20062 │ ban    │ SG      │ 45102 Alibaba US Technology Co., Ltd.                 │ 1      │ 31h20m12s  │ 46       │
│ 156370 │ crowdsec │ Ip:....     │ crowdsecurity/http-probing            │ ban    │ GB      │ 202306 Hostglobal.plus Ltd                            │ 11     │ 22h43m2s   │ 42       │
│ 138806 │ crowdsec │ Ip:....     │ crowdsecurity/thinkphp-cve-2018-20062 │ ban    │ SG      │ 45102 Alibaba US Technology Co., Ltd.                 │ 1      │ 29h39m0s   │ 38       │
│ 138802 │ crowdsec │ Ip:....     │ crowdsecurity/thinkphp-cve-2018-20062 │ ban    │ SG      │ 45102 Alibaba US Technology Co., Ltd.                 │ 1      │ 29h6m8s    │ 34       │
│ 138798 │ crowdsec │ Ip:....     │ crowdsecurity/thinkphp-cve-2018-20062 │ ban    │ SG      │ 45102 Alibaba US Technology Co., Ltd.                 │ 1      │ 27h57m42s  │ 30       │
│ 123794 │ crowdsec │ Ip:....     │ crowdsecurity/thinkphp-cve-2018-20062 │ ban    │ SG      │ 45102 Alibaba US Technology Co., Ltd.                 │ 1      │ 26h23m17s  │ 25       │
╰────────┴──────────┴─────────────┴───────────────────────────────────────┴────────┴─────────┴───────────────────────────────────────────────────────┴────────┴────────────┴──────────╯
```

#### Ban time setup

Edit `duration_expr` in `crowdsec-profile.yaml`

#### Discord Notification format

Edit `crowdsec-discord.yaml`  For the formating, [this doc](https://discordjs.guide/popular-topics/embeds.html#using-an-embed-object) is a good reference.
