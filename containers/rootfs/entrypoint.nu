#!/usr/bin/env nu

def "main client" [] {
    /etc/periodic/daily/rsync init
}

def main [] {
    rsync --daemon --bwlimit=128 --no-detach --log-file=/dev/stdout
}