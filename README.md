# Unified Streaming Live Origin Demo
# Microsoft Smooth Streaming Ingest Protocal

## Overview
This project demonstrates the use of [FFmpeg](https://ffmpeg.org/) and [Unified Streaming - Origin Live](http://www.unified-streaming.com/products/unified-origin) to present a Live Adaptive Bitrate presentation. 

FFMPEG delivers fragmented mp4 tracks to Unified Origin using the [Microsoft Smooth Streaming Protocol - MSS-STR](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-sstr/8383f27f-7efe-4c60-832a-387274457251) 

For more information about Unified Origin or you have any questions please visit see our [Documentation](http://docs.unified-streaming.com/) or contact us at [support@unified-streaming.com](mailto:support@unified-streaming.com?subject=[GitHub]%20MSS%20Ingest%20Live%20Demo).
![Image](flow.png?raw=true)

The demo consists of two Docker containers which are deployed using Docker Compose.

The default track configuration created is below, however encoding parameters can be updated within the [docker-compose.yaml](docker-compose.yaml).
- Video Track 1 - 1280x720 1000k AVC 96GOP@50FPS
- Video Track 2 - 1024x576 500k AVC 48GOP@25FPS
- Audio Track 1 - 128kbs 48kHz AAC-LC - English language 
- Audio Track 2 - 64kbs 48kHz AAC-LC - Dutch language

## Disclaimer
This is a demo and therefore not intended for production use.

## Setup

1. Install [Docker](http://docker.io)
2. Install [Docker Compose](http://docs.docker.com/compose/install/)
3. Download this demo's [Compose file](https://github.com/unifiedstreaming/live-demo/blob/master/docker-compose.yaml)


## Build FFmpeg

As this demonstration contains will generate the following stream configurations, so the Docker image needs to be built locally.

This can be done by running the following command in the directory of this demo's Compose file:

```bash
#!/bin/sh
docker-compose build ffmpeg
```

Which will create a Docker image called livedemo_ffmpeg with the patch applied.


## Usage

You need a license key to use this software. To evaluate you can create an account at [Unified Streaming Registration](https://www.unified-streaming.com/licenses/access).

The license key is passed to containers using the *USP_LICENSE_KEY* environment variable.

Start the stack using *docker-compose*:

```bash
#!/bin/sh
export USP_LICENSE_KEY=<your_license_key>
docker-compose up
```

You can also choose to run it in background (detached mode):

```bash
#!/bin/sh
export USP_LICENSE_KEY=<your_license_key>
docker-compose up -d
```

Now that the stack is running the live stream should be available in all streaming formats at the following URLs:

| Streaming Format | Playout URL |
|------------------|-------------|
| MPEG-DASH | http://localhost/test/test.isml/.mpd |
| HLS | http://localhost/test/test.isml/.m3u8 |
| Microsoft Smooth Streaming | http://localhost/test/test.isml/Manifest |
| Adobe HTTP Dynamic Streaming | http://localhost/test/test.isml/.f4m |


Watching the stream can be done using your player of choice, for example FFplay.

```bash
#!/bin/sh
ffplay http://localhost/test/test.isml/.m3u8
```

And it should look something like:

![example](./ffmpeg/example.png?raw=true) 