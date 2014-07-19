gstreamer-screenrecording
=========================

Patches and scripts for gstreamer

Scripts
```
rec.sh - Record screen or window  with VAAPI(intel I420 or NV12), OMX(radeon NV12), software (x264enc I420 or NV12) to mkv file, with or without sound.
Require gstreamer-1.0, gst-omx, gstreamer-vaapi-plugin, intel-vaapi or mesa-omx, pulseaudio.

gsttwich.sh - Record screen or window  VAAPI(broken, twich dont show video ), OMX(radeon NV12), software (x264enc I420 or NV12) and streaming it to twich.
Require gstreamer-1.0, gst-omx, gstreamer-vaapi-plugin, intel-vaapi or mesa-omx, pulseaudio.
```


Patches for gst-plugins-base 1.2.4
```
SSE_1_nv12_i420.patch sse implementation of videoconvert_convert_matrix8 for nv12 and I420 (reduce cpu usage from 0.50 to 0.22)
SSE_2_nv12,i420.patch sse implementation of videoconvert_convert_matrix8 for nv12 and I420 (reduce cpu usage from 0.50 to 0.19)
table64_nv12_i420.patch tables multiplication implementation of videoconvert_convert_matrix8  for nv12 and I420 (reduce cpu usage from 0.50 to 0.27) crossplatform
SSR_i420.patch copy past from SimpleScreenRecorder for I420 (reduce cpu usage from 0.50 to 0.1) only works with I420 (vaapi, x264enc)
```
