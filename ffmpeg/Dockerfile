# ffmpeg - http://ffmpeg.org/download.html
# based on image from 
# https://hub.docker.com/r/jrottenberg/ffmpeg/
#
#
FROM        alpine:3.11


ENV         X264_VERSION=20160826-2245-stable \
            X265_VERSION=x265_2.8 \
            PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
            SRC=/usr/local

COPY ism_movenc.patch /root/ism_movenc.patch

RUN     buildDeps="autoconf \
                   automake \
                   bash \
                   binutils \
                   bzip2 \
                   cmake \
                   curl \
                   coreutils \
                   g++ \
                   gcc \
                   git \
                   libtool \
                   make \
                   openssl-dev \
                   tar \
                   python3 \
                   yasm \
                   zlib-dev" && \
        export MAKEFLAGS="-j$(($(grep -c ^processor /proc/cpuinfo) + 1))" && \
        apk  add --update ${buildDeps} freetype-dev fontconfig-dev ttf-droid libgcc libstdc++ ca-certificates && \
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sL https://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-${X264_VERSION}.tar.bz2 | \
        tar -jx --strip-components=1 && \
        ./configure --prefix="${SRC}" --bindir="${SRC}/bin" --enable-pic --enable-shared --disable-cli && \
        make && \
        make install && \
        rm -rf ${DIR} && \
        # x265 http://www.videolan.org/developers/x265.html 
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sL https://download.videolan.org/pub/videolan/x265/${X265_VERSION}.tar.gz | \
        tar -zx --strip-components=1 && \
        cd build && cmake ../source && \
        make -j$(nproc) && \
        make install && \
        rm -rf ${DIR}


## ffmpeg source from github
RUN     DIR=$(mktemp -d) && cd ${DIR} && \
        git clone https://github.com/FFmpeg/FFmpeg.git . && \
        cp /root/ism_movenc.patch . && \
        git apply ism_movenc.patch && \
        ./configure --prefix="${SRC}" \
        --extra-cflags="-I${SRC}/include" \
        --extra-ldflags="-L${SRC}/lib" \
        --bindir="${SRC}/bin" \
        --disable-doc \
        --disable-static \
        --enable-shared \
        --disable-ffplay \
        --extra-libs=-ldl \
        --enable-version3 \
        --enable-libx264 \
        --enable-libx265 \
        --enable-libfontconfig \
        --enable-libfreetype \
        --enable-gpl \
        --enable-avresample \
        --enable-postproc \
        --enable-nonfree \
        --disable-debug \
        --enable-openssl && \
        make && \
        make install && \
        make distclean && \
        hash -r && \
        rm -rf ${DIR} && \
        cd && \
        apk del ${buildDeps} && \
        rm -rf /var/cache/apk/* /usr/local/include && \
        ffmpeg -buildconf

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
