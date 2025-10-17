#!/usr/bin/env nu

use std *

def run [max_retries: int] {
    mut retries = 0
    mut sleep_time = 15sec
    while $retries < $max_retries { 
        let sy = (rsync --password-file=/etc/rsync.secrets --checksum --archive --recursive --delete --force --compress --bwlimit=128 $"container-user@($env.SERVER)::volume" /data) | complete
        if $sy.exit_code == 0 {
            log info $sy.stdout
            break
        };
        log error $sy.stderr
        log warning $"($retries)/16 Retrying after ($sleep_time) ..."
        sleep $sleep_time
        $retries = $retries + 1
        $sleep_time = $sleep_time + 15sec
    };
}

def "main init" [] {
    run 99999
    crond -f > /dev/stdout
}

def main [] {
    run 8
}