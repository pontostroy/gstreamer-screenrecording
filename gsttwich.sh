#!/bin/bash

## Run with any argument to enable sound recording /rec.sh s 
#SAVE Twich stream key to ~/.twitch.key or twitch.key

OPTIND=1
DNUM=0
BELAGIOBIN="/usr/bin/omxregister-bellagio"
GST="gst-launch-1.0"
GSTIN="gst-inspect-1.0"
VAENC="vaapiencode_h264"
if [[ "$GSTIN | grep vaapih264enc >/dev/null"  ]]
then VAENC="vaapih264enc"
else
VAENC="vaapiencode_h264"
fi
##FPS 
FPS="25/1"
MONITOR_H=$(xrandr | grep '*'|head -1| awk '{print $1}'  | awk -Fx '{print $1}')
MONITOR_W=$(xrandr | grep '*'|head -1| awk '{print $1}'  | awk -Fx '{print $2}')
M_H=$(($MONITOR_H - 1))
M_W=$(($MONITOR_W - 1))
URL="rtmp://live.justin.tv/app/"
FOUT=" flvmux  streamable=true name="muxer" "
REC=""
#FORMAT I420 or NV12
FORMAT="I420"
VIDEOCONV="! videoconvert "
##Software
ENCODER="! x264enc  speed-preset=faster qp-min=30 tune=zerolatency  ! video/x-h264,stream-format=byte-stream,profile=main ! h264parse "
##OMX
OMX="! omxh264enc ! video/x-h264,stream-format=byte-stream,profile=main ! h264parse  "
##VAAPI
VAAPI="! $VAENC  dct8x8=true !  video/x-h264,stream-format=byte-stream,profile=high ! vaapiparse_h264 config-interval=2 "
SENC="! voaacenc bitrate=128000 ! aacparse"

#SOUND SOURCE 
##pactl list | grep -A2 'Source #' | grep 'Name: ' | cut -d" " -f2
##alsa_output.pci-0000_00_1b.0.analog-stereo.monitor
##alsa_input.usb-Sonix_Technology_Co.__Ltd._Trust_Webcam-02-Webcam.analog-mono
SINPUT=$(pacmd list | sed -n "s/.*<\(.*\\.monitor\)>/\\1/p" | head -1)

# Find stream key
if [ -f ~/.twitch.key ]; then
    ECHO_LOG=$ECHO_LOG"\nUsing global twitch key located in home directory"
    TKEY=$(cat ~/.twitch.key)
else
    if [ -f ./twitch.key ]; then
        ECHO_LOG=$ECHO_LOG"\nUsing twitch key located in current running directory"
        TKEY=$(cat ./twitch.key)
    else
        echo "Could not locate ~/.twitch.key or twitch.key"
        exit 1
    fi
fi


function show_help {
echo "Run with
         -n for nogui mode /rec.sh -n=v for vaapi; -n=o for omx; -n=x for x264enc
         -x nubmer of x-server  /rec.sh -x 0
         -h show help message"
}
         
         
         
while getopts "h?n:x:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    x)  DNUM="$OPTARG"
        echo "X-server nubmer $DNUM"
        ;;
    n)  NOGUI=$OPTARG
        echo "Nogui mode"
        case "$NOGUI" in 
        =v)
        if  [[ "$GSTIN | grep $VAENC >/dev/null"  ]]
	     then ENCODER="$VAAPI "
	     VIDEOCONV="! vaapipostproc format=i420"
	     echo "Using $VAENC encoder"
	     REC="$GST -e  ximagesrc  display-name=:$DNUM  use-damage=0 startx=0 starty=0 endx=$M_H endy=$M_W ! video/x-raw,format=BGRx,framerate=$FPS $VIDEOCONV ! video/x-raw,format=$FORMAT,framerate=$FPS  $ENCODER ! multiqueue ! $FOUT pulsesrc device-name=$SINPUT ! audio/x-raw,channels=2 ! multiqueue  $SENC ! multiqueue ! muxer. muxer. ! progressreport name="Rec_time" ! queue leaky=downstream ! rtmpsink location=$URL$TKEY" 
             #echo $REC
             eval $REC
             exit 0
	     else echo "Gstreamer $VAENC not found"
	     exit 0
	 fi
	 ;;
        =o) 
        if [ -f $BELAGIOBIN ]; 
	then 
	$BELAGIOBIN
	else
	echo "omxregister-bellagio not found"
	fi
        if  [[ '$GSTIN | grep omxh264enc >/dev/null'  ]]
	      then ENCODER="$OMX"
	      FORMAT="NV12"
	      echo "Using omxh264enc encoder"
	      REC="$GST -e  ximagesrc display-name=:$DNUM  use-damage=0 startx=0 starty=0 endx=$M_H endy=$M_W ! video/x-raw,format=BGRx,framerate=$FPS $VIDEOCONV ! video/x-raw,format=$FORMAT,framerate=$FPS  $ENCODER ! multiqueue ! $FOUT pulsesrc device-name=$SINPUT ! audio/x-raw,channels=2 ! multiqueue  $SENC ! multiqueue ! muxer. muxer. ! progressreport name="Rec_time"  ! queue leaky=downstream ! rtmpsink location=$URL$TKEY" 
              #echo $REC
              eval $REC
              exit 0
	      else echo "Gstreamer omxh264enc not found"
	      exit 0
	fi
        ;;
        =x)
        ENCODER="! x264enc  speed-preset=faster qp-min=30 tune=zerolatency "
        REC="$GST -e  ximagesrc  use-damage=0 startx=0 starty=0 endx=$M_H endy=$M_W ! video/x-raw,format=BGRx,framerate=$FPS $VIDEOCONV ! video/x-raw,format=$FORMAT,framerate=$FPS $ENCODER ! multiqueue ! $FOUT pulsesrc device-name=$SINPUT ! audio/x-raw,channels=2 ! multiqueue  $SENC ! multiqueue ! muxer. muxer. ! progressreport name="Rec_time" ! queue leaky=downstream ! rtmpsink location=$URL$TKEY"
        #echo $REC
        eval $REC
        exit 0
        ;;
        *)
         echo "Use n=v for vaapi; n=o for omx; n=x for x264enc"
         exit 0
        ;;
        esac
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift         
         
         

function ENC {
DI=`kdialog --menu "CHOOSE ENCODER:" 1 "Radeon OMX" 2 "Intel VAAPI" 3 "SOFTWARE";`

if [ "$?" = 0 ]; then
case "$DI" in 
	1)
	if [ -f $BELAGIOBIN ]; 
	then 
	$BELAGIOBIN
	else
	echo "omxregister-bellagio not found"
	fi
	   if  [[ '$GSTIN | grep omxh264enc >/dev/null'  ]]
	      then ENCODER="$OMX"
	      FORMAT="NV12"
	      echo "Using omxh264enc encoder"
	      else echo "Gstreamer omxh264enc not found"
	   fi;;
       2)
	   if  [[ "$GSTIN | grep $VAENC >/dev/null"  ]]
	     then ENCODER="$VAAPI "
	     VIDEOCONV="! vaapipostproc format=i420"
	     echo "Using $VAENC encoder"
	     else echo "Gstreamer $VAENC not found"
	   fi;;
	3)
	     ENCODER="! x264enc  speed-preset=faster qp-min=30 tune=zerolatency"
	     echo "Using software encoder";;
	*)
	     #ENCODER="! x264enc speed-preset=superfast"
	     echo "Using software encoder"
	     ;;
	     esac
fi
}



function DIAL {
VID=`kdialog --menu "CHOOSE RECORD MODE:" A "FULL SCREEN REC" B "WINDOW REC";`

if [ "$?" = 0 ]; then
	if [ "$VID" = A ]; then
		REC="$GST -e  ximagesrc display-name=:$DNUM  use-damage=0 startx=0 starty=0 endx=$M_H endy=$M_W ! video/x-raw,format=BGRx $VIDEOCONV ! video/x-raw,format=$FORMAT,framerate=$FPS    $ENCODER ! multiqueue ! $FOUT pulsesrc device-name=$SINPUT ! audio/x-raw,channels=2 ! multiqueue  $SENC ! multiqueue ! muxer. muxer. ! progressreport name="Rec_time" ! queue leaky=downstream ! rtmpsink location=$URL$TKEY" 
	elif [ "$VID" = B ]; then
	        XID=`xwininfo |grep 'Window id' | awk '{print $4;}'`
		REC="$GST -e  ximagesrc display-name=:$DNUM xid=$XID  use-damage=0 ! video/x-raw,format=BGRx $VIDEOCONV ! video/x-raw,format=$FORMAT,framerate=$FPS    $ENCODER ! multiqueue ! $FOUT pulsesrc device-name=$SINPUT ! audio/x-raw,channels=2 ! multiqueue  $SENC ! multiqueue ! muxer. muxer. ! progressreport name="Rec_time" ! queue leaky=downstream ! rtmpsink location=$URL$TKEY" 
	else
		echo "ERROR";
	fi;
fi;
}


ENC
DIAL
echo $REC
eval $REC
