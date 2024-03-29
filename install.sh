#!/bin/sh
set -eu

main() {
  sudo install -m 0755 -o root -g root bin/urbit-fg /usr/local/bin
  sudo install -m 0755 -o root -g root sbin/make-urbit-docker /usr/local/sbin
  sudo install -m 0755 -o root -g root sbin/make-urbit /usr/local/sbin
  sudo install -m 0755 -o root -g root sbin/urbit-exporter /usr/local/sbin
  sudo install -m 0755 -o root -g root sbin/urbit-meld-docker-all /usr/local/sbin
  sudo install -m 0755 -o root -g root sbin/urbit-meld-docker /usr/local/sbin
  sudo install -m 0755 -o root -g root sbin/urbit-pack-docker-all /usr/local/sbin
  sudo install -m 0755 -o root -g root sbin/urbit-pack-docker /usr/local/sbin
  sudo install -m 0755 -o root -g root sbin/urbit-meld /usr/local/sbin
  sudo install -m 0755 -o root -g root sbin/urbit-pack /usr/local/sbin
  sudo install -m 0644 -o root -g root systemd/urbit-exporter@.service /etc/systemd/system
  sudo install -m 0644 -o root -g root systemd/urbit-meld@.service /etc/systemd/system
  sudo install -m 0644 -o root -g root systemd/urbit-meld@.timer /etc/systemd/system
  sudo install -m 0644 -o root -g root systemd/urbit-pack@.service /etc/systemd/system
  sudo install -m 0644 -o root -g root systemd/urbit-pack@.timer /etc/systemd/system
  sudo install -m 0644 -o root -g root systemd/urbit@.service /etc/systemd/system
  sudo mkdir -p /etc/urbit
  sudo adduser --system --shell /usr/sbin/nologin --gecos "" \
               --disabled-password --no-create-home urbit-exporter || true
  # try to install packages in case we're on debian
  sudo apt install -yy python3-prometheus-client python3-urllib3 || true

  # optionally install prometheus
  read ctrl_c_to_not_install_prometheus
  sudo apt install -yy prometheus prometheus-alertmanager prometheus-node-exporter
}

echo "Here's what we're going to do:"
echo
cat $0 | sed -e '1,/main/d' | sed -e '/^}/,$d'
echo
set -x
read enter_to_continue
main
