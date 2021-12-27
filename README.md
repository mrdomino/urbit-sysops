# Urbit Sysops

Contains some helpful scripts for hosting Urbit.

These scripts are in use in production, but this repository is not currently used to provision production hosts; as such the install process is untested, and may contain some gotchas.

There are two variants included in this repo: one using docker, and one using plain systemd.

The docker approach requires a working docker install, but has the advantage of making it possible to assign predictable HTTP ports per urbit instance; as such it is preferred unless you’re hosting ships that do not require HTTP access, or hosting one ship per VPS.

## urbit-exporter

`urbit-exporter` is a [prometheus](https://prometheus.io/) exporter for urbit. It exports the variables `urbit_up` and `urbit_us` (indicating that the login page returned HTTP 200, and that it seems to be for the expected ship, respectively.) Run it by passing the TCP port on which to start its own server (a handy convention may be to use the TCP port corresponding to that urbit’s assigned UDP port, but any scheme is fine), the urbit ship name, and that urbit’s http port. A systemd script is included to automate this.

For example, suppose you have `~sampel-palnet` listening on http port `8080/tcp`, and you wish to run the exporter on port `42069/tcp`. Then you might have:

```console
$ cat /etc/urbit/sampel-palnet.exporter
PORT=42069
SHIP=sampel-palnet
URBIT_PORT=8080
$ cat /etc/prometheus/prometheus.yml
[…]
scrape_configs:
  - job_name: urbit
    static_configs:
      - targets: ['localhost:42069']
[…]
rule_files:
  - "/etc/prometheus/rules/*.yml"
$ cat /etc/prometheus/rules/alert-rules.yml
[…]
groups:
  - name: alert-rules
    rules:
    - alert: UrbitDown
      expr: urbit_up == 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: 'Urbit down {{ $labels.instance }}'
[…]
$ readlink /etc/systemd/system/multi-user.target.wants/urbit-exporter\@sampel-palnet.service
/etc/systemd/system/urbit-exporter@.service
```

## urbit-meld

This is intended to be run as a cron job. It stops an urbit instance, runs `urbit-worker meld` on it, and restarts the instance after either success or failure.

`urbit-meld` is designed for a systemd-based setup; `urbit-meld-docker` is designed for a docker-based setup.

`urbit-meld` includes systemd timer files, so it's sufficient to `systemctl enable --now urbit-meld@$ship.timer` to get it to run weekly on that ship.

For `urbit-meld-docker`, you should somehow or another have a list of the ships that you’re running, and just have it do all of them one after another in sequence in a `cron.weekly` file or something.
