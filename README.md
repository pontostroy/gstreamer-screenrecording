gstreamer-screenrecording
=========================
![ScreenShot](http://www.gearsongallium.com/wp-content/uploads/2014/04/3.png)

Patches and scripts for gstreamer

Scripts
```
rec.sh - Record screen or window  with VAAPI(intel I420 or NV12), OMX(radeon NV12), software (x264enc I420 or NV12) to mkv file, with or without sound.
Require kdialog, gstreamer-1.0, gst-omx, gstreamer-vaapi-plugin, intel-vaapi or mesa-omx, pulseaudio.

Run with -s argument to enable sound recording /rec.sh -s
         -d to set dir for saving *.mkv /rec.sh -d /tmp
         -n for nogui mode /rec.sh -n=v for vaapi; -n=o for omx; -n=x for x264enc
         -x nubmer of x-server  /rec.sh -x 0
         /rec.sh -s -d /tmp -n=o record screen with sound using omx and save to /tmp
         -h show help message



gsttwich.sh - Record screen or window  VAAPI(intel I420 or NV12), OMX(radeon NV12), software (x264enc I420 or NV12) and streaming it to twich.

Run with
         -n for nogui mode /rec.sh -n=v for vaapi; -n=o for omx; -n=x for x264enc
         -x nubmer of x-server  /rec.sh -x 0
         -h show help message"


Require kdialog, gstreamer-1.0, gst-omx, gstreamer-vaapi-plugin, intel-vaapi or mesa-omx, pulseaudio.
```


Patches for gst-plugins-base 1.2.4
```
SSE_1_nv12_i420.patch sse implementation of videoconvert_convert_matrix8 for nv12 and I420 (reduce cpu usage from 0.50 to 0.22)
SSE_2_nv12,i420.patch sse implementation of videoconvert_convert_matrix8 for nv12 and I420 (reduce cpu usage from 0.50 to 0.19)
table64_nv12_i420.patch tables multiplication implementation of videoconvert_convert_matrix8  for nv12 and I420 (reduce cpu usage from 0.50 to 0.27) crossplatform
SSR_i420.patch copy past from SimpleScreenRecorder for I420 (reduce cpu usage from 0.50 to 0.1) only works with I420 (vaapi, x264enc)
```
Patches for gst-plugins-base 1.4.0
```
SSE_1_nv12_i420.patch sse implementation of videoconvert_convert_matrix8 for nv12 and I420 (reduce cpu usage from 0.50 to 0.22)
SSE_2_nv12,i420.patch sse implementation of videoconvert_convert_matrix8 for nv12 and I420 (reduce cpu usage from 0.50 to 0.19)
table64_nv12_i420.patch tables multiplication implementation of videoconvert_convert_matrix8  for nv12 and I420 (reduce cpu usage from 0.50 to 0.27) crossplatform
SSR_i420.patch copy past from SimpleScreenRecorder for I420 (reduce cpu usage from 0.50 to 0.1) only works with I420 (vaapi, x264enc)
