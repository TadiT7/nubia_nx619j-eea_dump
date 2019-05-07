#!/system/bin/sh

#Read the arguments passed to the script
cmd="$1"
uart_addr=""

LOG_TAG="btnb-uart-sh"
LOG_NAME="${0}:"

prop_pid="sys.bt.nblog.uart.pid"
ipc_path="/sys/kernel/debug/ipc_logging"
#save uart node name
unode_arr={}

#trace flag
trace=`getprop bluetooth.nblog.uart.trace`

logv ()
{
  if [ trace -eq 1 ];then
    /system/bin/log -t $LOG_TAG -p e "$LOG_NAME $@"
  fi
}

logd ()
{
  /system/bin/log -t $LOG_TAG -p d "$LOG_NAME $@"
}

get_uart_addr ()
{
  addr_path=""
  conf_path="/etc/bluetooth/uart_config.conf"
  def_path="/sys/class/tty/ttyHS0/iomem_base"
  #if we give a config file
  if [ -f ${conf_path} ];then
    addr_path=${conf_path}
  elif [ -f ${def_path} ];then
    addr_path=${def_path}
  fi

  #check if path valid
  logv "conf addr path = ${addr_path}"
  if [ -z ${addr_path} ];then
    logd "invalid addr path, do nothing"
    return 0
  fi

  #read addr
  for i in `cat ${addr_path}`
  do
    logv "read addr : ${i}"
    #change to lower letters
    typeset -l tmp
    tmp=${i#*0x}
	uart_addr=${tmp}
    logv "get addr : ${uart_addr}"
  done
  
  #get uart node name
  index=0
  for i in `ls ${ipc_path} | grep ${uart_addr}`
  do
    logv "find : ${i}"
	unode_arr[index++]=${i}
  done
}
start_cat_node ()
{
  if [ ! -f $1 ];then
    logv "$1 not exist"
    return
  fi
  
  logv "$1,$2,$3"
  cat $1 > $2 &
  setprop $3 $!
  logv "$3 pid = $!"
}
start_capture ()
{
  #get addr
  get_uart_addr
  if [ -z ${uart_addr} ];then
    return 0
  fi

  logv "uart_addr = ${uart_addr}"
  
  #create root dir if need
  root_dir="/sdcard/nubialog/btlog/uart"
  if [ ! -d ${dir} ];then
    mkdir -p ${root_dir}
  fi

  #create dir for this
  now_time=`date +%Y%m%d%H%M%S`
  this_dir=${root_dir}/${now_time}
  mkdir -p ${this_dir}

  logd "start capture uart log ..."

  #save pid numbers
  setprop ${prop_pid}.count ${#unode_arr[@]}
  index=1
  for i in ${unode_arr[@]}
  do
    start_cat_node ${ipc_path}/${i}/log_cont ${this_dir}/${i}.txt ${prop_pid}.${index}
	((index++))
	logv "index = ${index}"
  done
}

stop_cat_node ()
{
  pid=`getprop $1`
  logv "$1 = ${pid}"
  if [ pid -eq 0 ];then
    logd "invalid pid , do nothing"
  elif [ -d /proc/${pid} ];then
    kill -9 ${pid}
    logv "${pid} exist, kill it"
    setprop $1 0
  else
    logv "${pid} not exist, do nothing"
    setprop $1 0
  fi
}
stop_capture ()
{
  logd "stop capture uart log"
  count=`getprop ${prop_pid}.count`
  #check count and reset
  if [ ${count} -eq 0 ];then
    return
  fi
  setprop ${prop_pid}.count 0
  
  i=1
  while [ ${i} -le ${count} ]
  do
    stop_cat_node ${prop_pid}.${i}
	((i++))
  done
}

init ()
{
  prop=`getprop sys.bt.nblog.capture.uart`
  if [ ${prop} -eq 1 ];then
    cmd="start"
  elif [ ${prop} -eq 0 ];then
    cmd="stop"
  else
    cmd=""
  fi
}

init
logd "cmd is : ${cmd}"
if [ "start" = ${cmd} ];then
  start_capture
elif [ "stop" = ${cmd} ];then
  stop_capture
else
  logd "invalid cmd, do nothing"
fi

exit 0
