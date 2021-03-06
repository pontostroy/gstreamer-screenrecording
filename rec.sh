#!/bin/bash


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
MONITOR_H=$(xrandr | grep '*'|head -1| awk '{print $1}'  | awk -Fx '{print $1}')
MONITOR_W=$(xrandr | grep '*'|head -1| awk '{print $1}'  | awk -Fx '{print $2}')
M_H=$(($MONITOR_H - 1))
M_W=$(($MONITOR_W - 1))
FPS="25/1"
TIME=$(date +"%Y-%m-%d_%H%M%S")
DIRM="$HOME"
FILEMANE=""
MUX=" matroskamux name="muxer" "
FOUT=" ! progressreport name="Rec_time" ! filesink location=$FILEMANE"
REC=""
#FORMAT I420 or NV12
FORMAT="I420"
##Software
ENCODER="! x264enc speed-preset=faster qp-min=30 tune=zerolatency "
##OMX
OMX="! omxh264enc control-rate=2 target-bitrate=9000000 ! h264parse "
##VAAPI
VAAPI="! $VAENC  dct8x8=true ! h264parse "
VIDEOCONV="! videoconvert "
NOGUI=""
#SOUND SOURCE
##pactl list | grep -A2 'Source #' | grep 'Name: ' | cut -d" " -f2
##alsa_output.pci-0000_00_1b.0.analog-stereo.monitor
##alsa_input.usb-Sonix_Technology_Co.__Ltd._Trust_Webcam-02-Webcam.analog-mono
SINPUT=$(pacmd list | sed -n "s/.*<\(.*\\.monitor\)>/\\1/p" | head -1)
##SOUND
#if [ $# -gt 0 ]; then
SOUNDC=" pulsesrc device-name=$SINPUT ! audio/x-raw,channels=2 ! multiqueue ! vorbisenc quality=0.4 ! multiqueue ! muxer."
#echo "Sound ON"
#else
SOUND=" "
#echo "Sound Off"
#fi

function show_help {
echo "Run with -s argument to enable sound recording /rec.sh -s
         -d to set dir for saving *.mkv /rec.sh -d /tmp
         -n for nogui mode /rec.sh -n=v for vaapi; -n=o for omx; -n=x for x264enc; -n=g for radeon vaapi
         -x nubmer of x-server  /rec.sh -x 0
         /rec.sh -s -d /tmp -n=o record screen with sound using omx and save to /tmp
         -h show help message"
}


while getopts ":h?sx:d:n:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    s)  SOUND=$SOUNDC
        echo "Sound ON"
        ;;
    x)  DNUM="$OPTARG"
        echo "X-server nubmer $DNUM"
        ;;
    d)  DIRM="$OPTARG"
        FILEMANE="$DIRM/rec_$TIME.mkv"
        FOUT=" ! progressreport name="Rec_time" ! filesink location=$FILEMANE"
        echo "Video saving to $DIRM"
        ;;
    n)  NOGUI=$OPTARG
        echo "Nogui mode"
        if [ -z "$FILEMANE" ]; then
	FILEMANE="$DIRM/rec_$TIME.mkv"
	fi
	FOUT=" ! progressreport name="Rec_time" ! filesink location=$FILEMANE"
        case "$NOGUI" in 
        =v)
        if  [[ "$GSTIN | grep $VAENC >/dev/null"  ]]
	     then ENCODER="$VAAPI "
	     VIDEOCONV="! vaapipostproc format=i420"
	     echo "Using $VAENC encoder"
	     REC="$GST -e  ximagesrc display-name=:$DNUM use-damage=0 startx=0 starty=0 endx=$M_H endy=$M_W  ! multiqueue ! video/x-raw,format=BGRx,framerate=$FPS  $VIDEOCONV  ! video/x-raw,format=$FORMAT,framerate=$FPS  ! multiqueue   $ENCODER ! multiqueue ! $MUX  $SOUND  muxer. $FOUT"
             echo $REC
             eval $REC
             exit 0
	     else echo "Gstreamer $VAENC not found"
	     exit 0
	 fi
	 ;;
        =g)
        if  [[ "$GSTIN | grep $VAENC >/dev/null"  ]]
	     then ENCODER="! $VAENC rate-control=2 bitrate=90000 ! h264parse "
	     FORMAT="NV12"
	     VIDEOCONV="! videoconvert"
	     echo "Using $VAENC encoder"
	     REC="$GST -e  ximagesrc display-name=:$DNUM use-damage=0 startx=0 starty=0 endx=$M_H endy=$M_W  ! multiqueue ! video/x-raw,format=BGRx,framerate=$FPS  $VIDEOCONV  ! video/x-raw,format=$FORMAT,framerate=$FPS  ! multiqueue   $ENCODER ! multiqueue ! $MUX  $SOUND  muxer. $FOUT"
             echo $REC
             eval $REC
             exit 0
	     else echo "Gstreamer $VAENC not found"
	     exit 0
	 fi
	 ;;
        =o) 
        if  [[ '$GSTIN | grep omxh264enc >/dev/null'  ]]
	      then ENCODER="$OMX"
	      FORMAT="NV12"
	      echo "Using omxh264enc encoder"
	      REC="$GST -e  ximagesrc display-name=:$DNUM  use-damage=0 startx=0 starty=0 endx=$M_H endy=$M_W ! multiqueue ! video/x-raw,format=BGRx,framerate=$FPS  $VIDEOCONV ! video/x-raw,format=$FORMAT,framerate=$FPS  ! multiqueue   $ENCODER ! multiqueue ! $MUX  $SOUND  muxer. $FOUT"
              echo $REC
              eval $REC
              exit 0
	      else echo "Gstreamer omxh264enc not found"
	      exit 0
	fi
        ;;
        =x)
        ENCODER="! x264enc  speed-preset=faster qp-min=30 tune=zerolatency "
        REC="$GST -e   ximagesrc display-name=:$DNUM  use-damage=0 startx=0 starty=0 endx=$M_H endy=$M_W ! multiqueue ! video/x-raw,format=BGRx,framerate=$FPS  $VIDEOCONV ! video/x-raw,format=$FORMAT,framerate=$FPS  ! multiqueue   $ENCODER ! multiqueue ! $MUX  $SOUND  muxer. $FOUT"
        echo $REC
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

if [ -z "$FILEMANE" ]; then
FILEMANE="$DIRM/rec_$TIME.mkv"
fi
FOUT=" ! progressreport name="Rec_time" ! filesink location=$FILEMANE"

function ENC {
#DI=`kdialog --menu "CHOOSE ENCODER:" 1 "Radeon OMX" 2 "Radaon Vaapi" 3 "Intel VAAPI" 4 "SOFTWARE";`
DI=`zenity --list --title="CHOOSE ENCODER" \
       --text="CHOOSE ENCODER:" \
       --column="#" --column="Encoder" --column="" \
       1 Amd "omx(vce) encoder" \
       2 Amd "vaapi(vce) encoder" \
       3 Intel "vaapi encoder" \
       4 Software "Software x264 edcoder" `

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
	     then ENCODER="! $VAENC rate-control=2 bitrate=90000 ! h264parse "
	     FORMAT="NV12"
	     VIDEOCONV="! videoconvert"
	     echo "Using $VAENC encoder"
	    else echo "Gstreamer $VAENC not found"
	   fi;;
        3)
	   if  [[ "$GSTIN | grep $VAENC >/dev/null"  ]]
	     then ENCODER="$VAAPI "
	     VIDEOCONV="! vaapipostproc format=i420"
	     echo "Using $VAENC encoder"
	    else echo "Gstreamer $VAENC not found"
	   fi;;
	4)
	     ENCODER="!  x264enc  speed-preset=faster qp-min=30 tune=zerolatency "
	     echo "Using software encoder";;
	*)
	     #ENCODER="! x264enc speed-preset=superfast"
	     echo "Using software encoder"
	     ;;
	     esac
fi
}



function DIAL {
#VID=`kdialog --menu "CHOOSE RECORD MODE:" A "FULL SCREEN REC" B "WINDOW REC";`
VID=`zenity --list --title="CHOOSE RECORD MODE" \
       --text="Mode:" \
       --column="#" --column=""\
       Fullscreen "Fullscreen recording" \
       Window "Windows recording"`

if [ "$?" = 0 ]; then
	if [ "$VID" = Fullscreen ]; then
		REC="$GST -e   ximagesrc display-name=:$DNUM  use-damage=0 startx=0 starty=0 endx=$M_H endy=$M_W ! multiqueue ! video/x-raw,format=BGRx,framerate=$FPS  $VIDEOCONV ! video/x-raw,format=$FORMAT,framerate=$FPS  ! multiqueue   $ENCODER ! multiqueue ! $MUX  $SOUND  muxer. $FOUT"
	elif [ "$VID" = Window ]; then
	        if which xwininfo >/dev/null; then
	        XID=`xwininfo |grep 'Window id' | awk '{print $4;}'`
		REC="$GST -e    ximagesrc  xid=$XID  display-name=:$DNUM  use-damage=0 ! multiqueue ! video/x-raw,format=BGRx,framerate=$FPS  $VIDEOCONV ! video/x-raw,format=$FORMAT,framerate=$FPS  ! multiqueue   $ENCODER ! multiqueue ! $MUX  $SOUND  muxer. $FOUT"
		else
		echo "install xwininfo";
		fi
	else
		echo "ERROR";
	fi;
fi;
}

ENC
DIAL
echo $REC
eval $REC
