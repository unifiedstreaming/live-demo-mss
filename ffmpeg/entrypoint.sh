#!/bin/sh

# set env vars to defaults if not already set
export FRAME_RATE="${FRAME_RATE:-50}"
export GOP_LENGTH="${GOP_LENGTH:-${FRAME_RATE}}"

if [ "${FRAME_RATE}" = "30000/1001" -o "${FRAME_RATE}" = "60000/1001" ]; then
  echo "drop frame"
  export FRAME_SEP="."
else
  export FRAME_SEP=":"
fi

export LOGO_OVERLAY="https://raw.githubusercontent.com/unifiedstreaming/live-demo/master/ffmpeg/usp_logo_white.png"

# validate required variables are set
if [ -z "${PUB_POINT_URI}" ]; then
  echo >&2 "Error: PUB_POINT_URI environment variable is required but not set."
  exit 1
fi

# get current time in microseconds
DATE_MICRO=$(LANG=C date +%s.%6N)
DATE_PART1=${DATE_MICRO%.*}
DATE_PART2=${DATE_MICRO#*.}
# the -ism_offset option has a timescale of 10,000,000, so add an extra zero
ISM_OFFSET=${DATE_PART1}${DATE_PART2}0
# the number of seconds into the current day
DATE_MOD_DAYS=$((${DATE_PART1}%86400))

set -x
exec ffmpeg -re \
-f lavfi \
-i smptehdbars=size=${ASPECT_RATIO}:rate=${FRAME_RATE} \
-i "https://raw.githubusercontent.com/unifiedstreaming/live-demo/master/ffmpeg/usp_logo_white.png" \
-filter_complex \
"sine=frequency=1:beep_factor=480:sample_rate=48000, \
atempo=0.5[a1]; \
sine=frequency=1:beep_factor=960:sample_rate=48000, \
atempo=0.5, \
adelay=1000[a2]; \
[a1][a2]amix, \
highpass=40, \
adelay='$(date +%3N)', \
asplit=2[a1][a2]; \
[a1]showwaves=mode=p2p:colors=white:size=1280x100:scale=lin:rate=$(($FRAME_RATE))[waves]; \
color=size=1280x100:color=black[blackbg]; \
[blackbg][waves]overlay[waves2]; \
[0][waves2]overlay=y=620[v]; \
[v]drawbox=y=25: x=iw/2-iw/7: c=0x00000000@1: w=iw/3.5: h=36: t=fill, \
drawtext=text='fMP4 Live Ingest': fontsize=32: x=(w-text_w)/2: y=75: fontsize=32: fontcolor=white,\
drawtext=text='Encoder 1 (${CODEC}-${ASPECT_RATIO}p${FRAME_RATE}-${VIDEO_BITRATE})': fontsize=32: x=(w-text_w)/2: y=125: fontsize=32: fontcolor=white, \
drawtext=text='%{pts\:gmtime\:${DATE_PART1}\:%Y-%m-%d}%{pts\:hms\:${DATE_MOD_DAYS}.${DATE_PART2}}':\
fontsize=32: x=(w-tw)/2: y=30: fontcolor=white[v+tc]; \
[v+tc][1]overlay=eval=init:x=W-15-w:y=15[vid]" \
-map "[vid]" -c:v ${CODEC} -b:v ${VIDEO_BITRATE} -profile:v main -preset ultrafast -tune zerolatency \
-map "[a2]" -c:a aac -b:a ${AUDIO_BITRATE} -ar ${AUDIO_SAMPLERATE} -metadata:s:a:0 language=dut \
-g ${GOP_LENGTH} \
-r ${FRAME_RATE} \
-keyint_min ${GOP_LENGTH} \
-fflags +genpts \
-movflags isml+frag_keyframe \
-write_prft pts \
-ism_offset ${ISM_OFFSET} \
-f ismv \
"${PUB_POINT_URI}/Streams(encoder1)"