#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/bootdevice/by-name/recovery:67108864:46a3318ab3637f545bc27f4edaee0972fc202179; then
  applypatch  EMMC:/dev/block/bootdevice/by-name/boot:67108864:89ae43b6ff2366fd37cb0a3060d2a74348c8d01a EMMC:/dev/block/bootdevice/by-name/recovery 46a3318ab3637f545bc27f4edaee0972fc202179 67108864 89ae43b6ff2366fd37cb0a3060d2a74348c8d01a:/system/recovery-from-boot.p && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
