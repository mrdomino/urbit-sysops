#!/bin/sh
set -eux

install() {
  sudo install -m 0755 -o root -g root sbin/urbit-meld /usr/local/sbin
  sudo install -m 0755 -o root -g root sbin/make-urbit /usr/local/sbin
  sudo install -m 0755 -o root -g root sbin/urbit-exporter /usr/local/sbin
  sudo install -m 0644 -o root -g root systemd/urbit@.service /etc/systemd/system
  sudo install -m 0644 -o root -g root systemd/urbit-meld@.service /etc/systemd/system
  sudo install -m 0644 -o root -g root systemd/urbit-meld@.timer /etc/systemd/system
  sudo mkdir -p /etc/urbit
}

type install
read enter_to_continue
install
