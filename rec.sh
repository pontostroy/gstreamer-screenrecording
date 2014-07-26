#!/bin/bash




OPTIND=1
BELAGIOBIN="/usr/bin/omxregister-bellagio"
GST="gst-launch-1.0"
GSTIN="gst-inspect-1.0"
##FPS 
FPSIN="30/1"
#FPSOUT="25/1"
TIME=$(date +"%Y-%m-%d_%H%M%S")
DIRM="$HOME"
FILEMANE="$DIRM/rec_$TIME.mkv"
MUX=" matroskamux name="muxer" "
FOUT=" ! progressreport  ! filesink location=$FILEMANE"
REC=""
#FORMAT I420 or NV12
FORMAT="I420"
##Software
ENCODER="! x264enc  speed-preset=faster qp-min=30 tune=zerolatency "
##OMX
OMX="! omxh264enc ! h264parse "
##VAAPI
VAAPI="! vaapiencode_h264  ! h264parse "
NOGUI=""
#SOUND SOURCE
##pactl list | grep -A2 'Source #' | grep 'Name: ' | cut -d" " -f2
##alsa_output.pci-0000_00_1b.0.analog-stereo.monitor
##alsa_input.usb-Sonix_Technology_Co.__Ltd._Trust_Webcam-02-Webcam.analog-mono
SINPUT="alsa_output.pci-0000_00_1b.0.analog-stereo.monitor"
##SOUND
#if [ $# -gt 0 ]; then
SOUNDC=" pulsesrc device=$SINPUT ! audio/x-raw,channels=2 ! queue ! voaacenc bitrate=128000 ! aacparse ! queue ! muxer."
#echo "Sound ON"
#else
SOUND=" "
#echo "Sound Off"
#fi

function show_help {
echo "Run with -s argument to enable sound recording /rec.sh -s
         -d to set dir for saving *.mkv /rec.sh -d /tmp
         -n for nogui mode /rec.sh -n=v for vaapi; -n=o for omx; -n=x for x264enc 
         /rec.sh -s -d /tmp -n=o record screen with sound using omx and save to /tmp
         -h show help message"
}


while getopts ":h?sd:n:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    s)  SOUND=$SOUNDC
        echo "Sound ON"
        ;;
    d)  DIRM="$OPTARG"
        FILEMANE="$DIRM/rec_$TIME.mkv"
        echo "Video saving to $DIRM"
        ;;
    n)  NOGUI=$OPTARG
        echo "Nogui mode"
        case "$NOGUI" in 
        =v)
        if  [[ '$GSTIN | grep vaapiencode_h264 >/dev/null'  ]]
	     then ENCODER="$VAAPI "
	     echo "Using vaapiencode_h264 encoder"
	     REC="$GST -e   ximagesrc  use-damage=0 ! queue ! video/x-raw,format=BGRx ! videoconvert ! video/x-raw,format=$FORMAT,framerate=$FPSIN  ! queue leaky=downstream   $ENCODER ! queue ! $MUX  $SOUND  muxer. $FOUT"
             echo $REC
             exec $REC
             exit 0
	     else echo "Gstreamer vaapiencode_h264 not found"
	     exit 0
	 fi
	 ;;
        =o) 
        if  [[ '$GSTIN | grep omxh264enc >/dev/null'  ]]
	      then ENCODER="$OMX"
	      FORMAT="NV12"
	      echo "Using omxh264enc encoder"
	      REC="$GST -e   ximagesrc  use-damage=0 ! queue ! video/x-raw,format=BGRx ! videoconvert ! video/x-raw,format=$FORMAT,framerate=$FPSIN  ! queue leaky=downstream   $ENCODER ! queue ! $MUX  $SOUND  muxer. $FOUT"
              echo $REC
              exec $REC
              exit 0
	      else echo "Gstreamer omxh264enc not found"
	      exit 0
	fi
        ;;
        =x)
        ENCODER="! x264enc  speed-preset=faster qp-min=30 tune=zerolatency "
        REC="$GST -e   ximagesrc  use-damage=0 ! queue ! video/x-raw,format=BGRx ! videoconvert ! video/x-raw,format=$FORMAT,framerate=$FPSIN  ! queue leaky=downstream   $ENCODER ! queue ! $MUX  $SOUND  muxer. $FOUT"
        echo $REC
        exec $REC
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
	   if  [[ '$GSTIN | grep vaapiencode_h264 >/dev/null'  ]]
	     then ENCODER="$VAAPI "
	     echo "Using vaapiencode_h264 encoder"
	     else echo "Gstreamer vaapiencode_h264 not found"
	   fi;;
	3)
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
VID=`kdialog --menu "CHOOSE RECORD MODE:" A "FULL SCREEN REC" B "WINDOW REC";`

if [ "$?" = 0 ]; then
	if [ "$VID" = A ]; then
		REC="$GST -e   ximagesrc  use-damage=0 ! queue ! video/x-raw,format=BGRx ! videoconvert ! video/x-raw,format=$FORMAT,framerate=$FPSIN  ! queue leaky=downstream   $ENCODER ! queue ! $MUX  $SOUND  muxer. $FOUT"
	elif [ "$VID" = B ]; then
	        XID=`xwininfo |grep 'Window id' | awk '{print $4;}'`
		REC="$GST -e    ximagesrc  xid=$XID  use-damage=0 ! queue ! video/x-raw,format=BGRx ! videoconvert ! video/x-raw,format=$FORMAT,framerate=$FPSIN  ! queue leaky=downstream   $ENCODER ! queue ! $MUX  $SOUND  muxer. $FOUT"
	else
		echo "ERROR";
	fi;
fi;
}

ENC
DIAL
echo $REC
exec $REC
