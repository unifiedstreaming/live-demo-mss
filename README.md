# Unified Streaming Live Origin Demo (v2)

This demonstration shows a [Unified Streaming](http://www.unified-streaming.com/products/unified-origin) Origin setup with a Live publishing point and uses [FFmpeg](https://ffmpeg.org/) as an encoder to push an input stream.

The demo consists of two Docker containers which are deployed using Docker Compose.


## Setup

1. Install [Docker](http://docker.io)
2. Install [Docker Compose](http://docs.docker.com/compose/install/)
3. Download this demo's [Compose file](https://github.com/unifiedstreaming/live-demo/blob/master/docker-compose.yaml)


## Build FFmpeg

As this demonstration requires a patch to add functionality to FFmpeg for 
improved live streaming the Docker image needs to be built locally.

This can be done by running the following command in the directory of this demo's Compose file:

```bash
#!/bin/sh
docker-compose build ffmpeg
```

Which will create a Docker image called livedemo_ffmpeg with the patch applied.


## Usage

You need a license key to use this software. To evaluate you can create an account at [Unified Streaming Registration](https://private.unified-streaming.com/register/).

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

![example](https://raw.githubusercontent.com/unifiedstreaming/live-demo/master/ffmpeg/example_logo.png)

