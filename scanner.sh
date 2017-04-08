#! /bin/bash
set +o noclobber
set -x # print each command

#
#   $1 = friendly name
#   $2 = resolution - 100,200,300,400,600
#   $3 = device name
#

# default parameters
output_file=/media/vlin/data/ftproot/scan_"`date +%Y-%m-%d-%H-%M-%S`"
resolution=300
device="brother4:net1;dev0"

if [ $# -ge 1 ]; then
  output_file=$1;
fi


if [ $# -ge 2 ]; then
  resolution=$2;
fi

if [ $# -ge 3 ]; then
  device=$3;
fi

output_file_pnm="$output_file"".pnm"
output_file_pdf="$output_file"".pdf"


if [ "`which usleep  2>/dev/null `" != '' ];then
    usleep 100000
else
    sleep  0.1
fi

echo "scan from ($device) to $output_file at $resolution dpi"
scanimage --device-name "$device" --resolution $resolution> $output_file_pnm  2>/dev/null
if [ ! -s $output_file_pnm ];then
  if [ "`which usleep  2>/dev/null `" != '' ];then
    usleep 1000000
  else
    sleep  1
  fi
  echo "retry scan from ($device) to $output_file at $resolution dpi"
  scanimage --device-name "$device" --resolution $resolution> $output_file_pnm  2>/dev/null
fi

# echo  $output_file_pnm is created.
if [ ! -s $output_file_pnm ];then
  echo "scan from ($device) to $output_file at $resolution dpi failed!"
  exit 1
fi

gm convert $output_file_pnm $output_file_pdf

if [ ! -s $output_file_pdf ];then
  echo "Conert to $output_file_pdf failed!"
  exit 1
fi

echo "Copy $output_file_pdf to google drive"
rclone copy  $output_file_pdf gdrive:ftproot


rm -f $output_file_pnm



