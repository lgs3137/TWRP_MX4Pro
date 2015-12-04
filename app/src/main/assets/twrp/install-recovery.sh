#!/system/xbin/busybox ash

/system/xbin/daemonsu --auto-daemon &

move_file()
{
    busybox mv -f /system/bin/$1 /backup
    busybox ln -sfT /backup/$1 /system/bin/
}
restore_file()
{
    busybox cp -af /backup/$1 /system/bin/
}
stop
cat /dev/input/event6 > /dev/keycheck & sleep 1
kill -9 $!
if [ -s /dev/keycheck -o -e /cache/recovery/command ];then
mount -o remount,rw rootfs /
mount -o remount,rw /system
busybox killall adbd
mv /sbin/adbd /sbin/adbd.bak
rm -f /etc
busybox cp -af /system/twrp/* /
runcon u:r:recovery:s0
setenforce 0
mkdir /backup
move_file logd
move_file lmkd
move_file vold
move_file debuggerd
move_file installd
move_file keystore
move_file mcDriverDaemon
move_file gpsd
move_file nvmserver
move_file eeh_server
move_file rild
move_file immvibed
move_file sdcard
move_file gxFpDaemon
move_file sh
move_file servicemanager
move_file drmserver
move_file mediaserver
move_file cploadserver

busybox killall logd
busybox killall lmkd
busybox killall vold
busybox killall debuggerd
busybox killall installd
busybox killall keystore
busybox killall -9 mcDriverDaemon
busybox killall gpsd
busybox killall nvmserver
busybox killall eeh_server
busybox killall rild
busybox killall immvibed
busybox killall sdcard
busybox killall gxFpDaemon
busybox killall -9 sh
busybox killall servicemanager
busybox killall drmserver
busybox killall mediaserver
busybox killall cploadserver

sleep 3
restore_file logd
restore_file lmkd
restore_file vold
restore_file debuggerd
restore_file installd
restore_file keystore
restore_file mcDriverDaemon
restore_file gpsd
restore_file nvmserver
restore_file eeh_server
restore_file rild
restore_file immvibed
restore_file sdcard
restore_file gxFpDaemon
restore_file sh
restore_file servicemanager
restore_file drmserver
restore_file mediaserver
restore_file cploadserver

stop
busybox killall daemonsu
mkdir /boot
mkdir /recovery
mkdir /sideload
rm -f /sdcard
mkdir /sdcard
mount tmpfs tmpfs /tmp
chown root shell /tmp
chmod 0755 /tmp

export PATH=/sbin
export LD_LIBRARY_PATH=/sbin
export ANDROID_ROOT=/system
export ANDROID_DATA=/data
export EXTERNAL_STORAGE=/data/media/0
export LD_PRELOAD=
rm -f /cache/recovery/command
/system/xbin/busybox umount -l /system
/sbin/recovery &
exit
else
start
fi