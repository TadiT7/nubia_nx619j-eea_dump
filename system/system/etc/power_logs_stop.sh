#!/system/bin/sh

ROOT_DIR="/sdcard/.woodpecker/nblog/"
LOG_DIR="/sdcard/.woodpecker/nblog/power/stop"

/system/bin/mkdir -p $LOG_DIR
/system/bin/touch $LOG_DIR/ps.txt
/system/bin/touch $LOG_DIR/wakeup_sources.txt
/system/bin/touch $LOG_DIR/rpm_stats.txt
#/system/bin/touch $LOG_DIR/gpio.txt
/system/bin/touch $LOG_DIR/capacity.txt
/system/bin/touch $LOG_DIR/bugreport.txt
/system/bin/chown -R root:system $ROOT_DIR
/system/bin/chmod -R 766 $ROOT_DIR


/system/bin/ps -t -p -P -x -c >> $LOG_DIR/ps.txt
/system/bin/cat /sys/kernel/debug/wakeup_sources >> $LOG_DIR/wakeup_sources.txt
/system/bin/cat /sys/kernel/debug/rpm_stats >> $LOG_DIR/rpm_stats.txt
/system/bin/cat /sys/kernel/debug/rpm_master_stats >> $LOG_DIR/rpm_stats.txt
/system/bin/cat /sys/power/system_sleep/stats >> $LOG_DIR/rpm_stats.txt
#Begin [0016004715,read the rpmh_stats/master_stats information about the subsystem,20180316]
/system/bin/cat /sys/power/rpmh_stats/master_stats >> $LOG_DIR/rpm_stats.txt
#End   [0016004715,read the rpmh_stats/master_stats information about the subsystem,20180316]
#/system/bin/cat /sys/kernel/debug/gpio >> $LOG_DIR/gpio.txt
/system/bin/cat /sys/class/power_supply/battery/capacity >> $LOG_DIR/capacity.txt
/system/bin/date >> $LOG_DIR/capacity.txt
/system/bin/bugreport >> $LOG_DIR/bugreport.txt

