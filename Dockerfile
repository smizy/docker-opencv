FROM smizy/scikit-learn:0.20.1-alpine

ARG BUILD_DATE
ARG BUILD_NUMBER
ARG VCS_REF
ARG VERSION

LABEL \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="Apache License 2.0" \
    org.label-schema.name="smizy/opencv" \
    org.label-schema.url="https://gitlab.com/smizy" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-type="Git" \
    org.label-schema.version=$VERSION \
    org.label-schema.vcs-url="https://github.com.com/smizy/docker-opencv"

ENV OPENCV_VERSION   $VERSION

RUN set -x \
    && apk update \
    # - opencv lib dependencies
    && apk --no-cache add \
        ffmpeg-libs \
        gstreamer \
        gst-plugins-base \
        gtk+3.0 \
        gtk+ \
        jasper \
        libavc1394 \
        # libdc1394 \
        libjpeg-turbo \
        libgomp \
        libgphoto2 \
        libpng \
        libwebp \
        opencl-headers \
        openexr \
        py3-opencl \
        tiff \
        v4l-utils \
        zlib \
    # - opencv build dependencies
    && apk --no-cache add --virtual .builddeps.opencv \
        ffmpeg-dev \
        gstreamer-dev \
        gst-plugins-base-dev \
        gtk+3.0-dev \
        gtk+-dev \
        jasper-dev \
        libavc1394-dev \
        # libdc1394-dev \
        libgphoto2-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        openexr-dev \
        tiff-dev \
        v4l-utils-dev \
        zlib-dev \
    # - common build tools
    && apk --no-cache add --virtual .builddeps \
        bash \
        build-base \
        cmake \
        git \
        linux-headers \
        openblas-dev \
        pkgconf \
        python3-dev \
    && wget -q -O - https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.tar.gz \
        | tar -xzf - -C /tmp \
    && cd /tmp/opencv-* \
    && ln -s /usr/include/libpng16 /usr/include/libpng \
    && mkdir build \
    && cd build \
    && cmake \
        -D CMAKE_INSTALL_PREFIX=/usr \
        -D CMAKE_INSTALL_LIBDIR=lib \
        -D BUILD_SHARED_LIBS=True \
        -D CMAKE_BUILD_TYPE=Release \
        -D ENABLE_PRECOMPILED_HEADERS=NO \
        -D WITH_OPENMP=YES \
        -D WITH_OPENCL=YES \
        -D WITH_IPP=NO \
        -D WITH_1394=NO \
        -D WITH_LIBV4L=NO \
        -D WITH_V4L=YES \
        -D INSTALL_PYTHON_EXAMPLES=NO \
        -D INSTALL_C_EXAMPLES=NO \
        -D BUILD_DOCS=NO \
        -D BUILD_TESTS=NO \
        -D BUILD_PERF_TESTS=NO \
        -D BUILD_EXAMPLES=NO \
        -D BUILD_opencv_java=NO \
        -D BUILD_opencv_python2=NO \
        -D BUILD_ANDROID_EXAMPLES=NO \
        -D PYTHON3_LIBRARY=`find /usr -name libpython3.so` \
        -D PYTHON_EXECUTABLE=`which python3` \
        -D PYTHON3_EXECUTABLE=`which python3` \
        -D BUILD_opencv_python3=YES  \
        .. \
    && CPUCOUNT=$(cat /proc/cpuinfo | grep '^processor.*:' | wc -l)  \
    && make -j ${CPUCOUNT} \
    && make install \
    # - cleanup
    && find /usr/lib/python3.6 -name __pycache__ | xargs rm -r \
    && apk del \
        .builddeps \
        .builddeps.opencv \
    && rm -rf \
        /root/.[acpw]* \
        /tmp/opencv-* \
    && ln -s /usr/bin/python3 /usr/bin/python

RUN set -x \
    && apk --no-cache add \
        dbus \
        mesa-dri-swrast 