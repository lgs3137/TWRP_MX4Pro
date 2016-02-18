#!/system/xbin/busybox ash
/system/xbin/daemonsu --auto-daemon &

echo high > /sys/power/power_mode
unset LD_PRELOAD
stop
cat /dev/input/event6 > /dev/keycheck & sleep 1
kill -9 $!
if [ -s /dev/keycheck -o -e /cache/recovery/command ];then
echo 50 > /sys/class/timed_output/vibrator/enable
mount -o remount,rw rootfs /
mount -o remount,rw /system
rm -f /cache/recovery/command
rm -f /etc
busybox killall adbd
busybox cp -rf /system/twrp/* /
export PATH=/sbin
export LD_LIBRARY_PATH=/sbin
chmod -R 0775 /sbin
setenforce 0
mkdir -p /boot
mkdir -p /recovery
mkdir -p /sideload
busybox rm -f /sdcard
mkdir -p /sdcard
mkdir -p /tmp
mount -t tmpfs tmpfs /tmp
chown root.shell /tmp
chmod 0775 /tmp

busybox killall adbd
busybox killall daemonsu

stop logd
stop lmkd
stop vold
stop debuggerd
stop installd
stop keystore
stop mobicore
stop gpsd
stop gxFpDaemon
stop nvmserver
stop eeh
stop ril-daemon
stop immvibed
stop sdcard
stop fpdaemon
stop console
stop servicemanager
stop drm
stop media
stop cploadserver
stop netd
stop zygote
stop debuggerd
stop debuggerd64

stop flymed
stop lbesec

umount /mnt/shell/emulated
umount /storage/emulated/0
umount /storage/emulated/0/Android/obb
umount /storage/emulated/legacy
umount /storage/emulated/legacy/Android/obb

export ANDROID_ROOT=/system
export ANDROID_DATA=/data
export EXTERNAL_STORAGE=/sdcard
umount -l /system
/sbin/recovery &
sleep 3
rm -rf /tmp/recovery.log
/sbin/recovery &
exit
else
start
fi
rm -f /dev/keycheck
