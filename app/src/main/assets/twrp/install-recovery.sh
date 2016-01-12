#!/system/bin/sh
setenforce 0
echo high > /sys/power/power_mode
setprop sys.usb.config mtp,adb
unset LD_PRELOAD
stop
cat /dev/input/event6 > /dev/keycheck & sleep 1
kill -9 $!
if [ -s /dev/keycheck -o -e /cache/recovery/command ];then
echo 50 > /sys/class/timed_output/vibrator/enable
mount -o remount,rw /
mount -o remount,rw /system

SVCRUNNING=$(getprop | grep -E '^\[init\.svc\..*\]: \[running\]')

rm -f /etc
cp -Rf /system/twrp/* /
chmod -R 755 /sbin
export PATH=/sbin:/system/bin
export LD_LIBRARY_PATH=.:/sbin
mkdir -p /boot
mkdir -p /recovery
mkdir -p /sideload
busybox rm -f /sdcard
mkdir -p /sdcard
mkdir -p /tmp
mount -t tmpfs tmpfs /tmp
chown root.shell /tmp
chmod 0775 /tmp

for SVC in ${SVCRUNNING}; do
  SVCNAME=$(expr ${SVC} : '\[init\.svc\.\(.*\)\]:.*')
  [ "${SVCNAME}" != "flash_recovery" ] && stop ${SVCNAME}
done

busybox killall -9 daemonsu

umount /mnt/shell/emulated
umount /storage/emulated/0
umount /storage/emulated/0/Android/obb
umount /storage/emulated/legacy
umount /storage/emulated/legacy/Android/obb

export ANDROID_ROOT=/system
export ANDROID_DATA=/data
export EXTERNAL_STORAGE=/sdcard
rm -rf /cache/recovery/command
umount -l /system
mount /dev/block/by-name/system /system
/sbin/recovery &
else
start
fi
rm -f /dev/keycheck
