#!/bin/sh

PAID=-1

cleanup ()
{
    pgrep -u `id -u` snapserver && (
        echo "Killing snapserver"
        killall snapserver
        sleep 1
        pgrep  -u `id -u` snapserver && killall -9 snapserver
    )
    if [ $PAID -ge 0 ]; then
        echo "Unloading PulseAudio module-pipe-sink ($PAID)"
        pactl unload-module $PAID
        PAID=-1
    fi
    rm -f /tmp/snapfifo || sudo rm -f /tmp/snapfifo
}

pgrep snapserver > /dev/null
if [ $? -eq 0 ]; then
    echo "snapserver already running, exiting"
    exit 1
fi

trap cleanup INT 

cleanup
echo "Loading PulseAudio module-pipe-sink"
PAID=`pactl load-module module-pipe-sink file=/tmp/snapfifo`
echo "Starting snapserver"
snapserver
cleanup
