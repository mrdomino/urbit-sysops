# Urbit Sysops

Contains some helpful scripts for hosting Urbit.

There are two variants included in this repo: one using docker, and one using plain systemd. I use and generally recommend the systemd approach these days unless you are otherwise committed to using docker.

## urbit-exporter

`urbit-exporter` is a [prometheus](https://prometheus.io/) exporter for urbit. It exports the variables `urbit_up` and `urbit_us` (indicating that the login page returned HTTP 200, and that it seems to be for the expected ship, respectively.) Run it by passing the TCP port on which to start its own server (a handy convention may be to use the TCP port corresponding to that urbit’s assigned UDP port, but any scheme is fine), the urbit ship name, and that urbit’s http port. A systemd script is included to automate this.

For example, suppose you have `~sampel-palnet` listening on http port `8080/tcp`, and you wish to run the exporter on port `42069/tcp`. Then you might have:

```console
$ cat /etc/urbit/sampel-palnet.exporter
PORT=42069
SHIP=sampel-palnet
ARGS=--http=8080
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

## urbit-fg

Occasionally it is convenient (and sometimes necessary — for example if the web terminal is broken) to run an urbit process in the foreground and interact on the console. This functionality is provided for the systemd route by the `urbit-fg` script. What it does is stop the systemd service for the specified ship, and start a foreground urbit process as that ship’s user. If the urbit process exits successfully (e.g. by you pressing `Ctrl-D` to send an `EOF`), then the systemd service is restarted afterwards. Otherwise (e.g. if urbit is exited by pressing `Ctrl-\`), the service is not restarted, in case some manual intervention is needed before it starts again.

`urbit-fg` is intended to be run as your regular user, and will use `sudo` to elevate privileges where necessary.

## urbit-meld

This is intended to be run as a cron job. It stops an urbit instance, runs `urbit meld` on it, and restarts the instance after either success or failure.

`urbit-meld` is designed for a systemd-based setup; `urbit-meld-docker` is designed for a docker-based setup.

`urbit-meld` includes systemd timer files, so it's sufficient to `systemctl enable --now urbit-meld@$ship.timer` to get it to run weekly on that ship.

For `urbit-meld-docker`, you should somehow or another have a list of the ships that you’re running, and just have it do all of them one after another in sequence in a `cron.weekly` file or something. `make-urbit-docker` tries to do this by updating a `/etc/urbit/ships` file, and `urbit-meld-docker-all` melds all docker ships in this file one after the other, with a short delay between them to prevent Prometheus from detecting too many ships down at the same time.

The `urbit-meld` script tries to freshen the `bhk` backup checkpoint when it runs. It does this by moving it to a separate location during the meld, and either deleting it or moving it back after the meld completes, depending on whether the meld produced its own `bhk` or not. This means that after each successful meld, the `bhk` checkpoint should refer to the ship’s state as of that meld.
