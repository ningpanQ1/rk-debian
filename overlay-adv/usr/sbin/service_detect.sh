#!/bin/bash

sleep 10

flag1=`systemctl list-units |grep systemd-logind |awk {'print $3'}`
if [ x$flag1 != "xactive" ];then
    echo "[ADV] systemd-logind boot fail" > /dev/ttyS2
fi

flag2=`systemctl list-units |grep systemd-user-sessions |awk {'print $3'}`
if [ x$flag2 != "xactive" ];then
    echo "[ADV] systemd-user-sessions boot fail" > /dev/ttyS2
fi

flag3=`systemctl list-units |grep lightdm |awk {'print $3'}`
if [ x$flag3 != "xactive" ];then
    echo "[ADV] lightdm boot fail" > /dev/ttyS2
fi

flag4=`systemctl list-units |grep serial-getty@ttyS2 |awk {'print $3'}`
if [ x$flag4 != "xactive" ];then
    echo "[ADV] serial-getty@ttyS2 boot fail" > /dev/ttyS2
fi


if [[ x$flag1 == "xactive" ]] && [[ x$flag2 == "xactive" ]] && [[ x$flag3 == "xactive" ]] && [[ x$flag4 == "xactive" ]];then
    # disable WDT
    echo "[ADV] service boot success" > /dev/ttyS2
    echo 1 > /sys/class/adv_timer_class/adv_timer_device/timer_flag
else
    echo "[ADV] service boot fail" > /dev/ttyS2
fi


