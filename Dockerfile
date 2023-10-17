FROM tensorflow/tensorflow:2.11.0-gpu

ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=utf-8 \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /source

RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libgtk2.0-dev \
    vim \
    cmake \
    git && \
    rm -rf /var/lib/apt/lists/\* && \
    apt-get clean

COPY requirements.txt /source/

RUN pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt

COPY . /source

WORKDIR /usr/local/lib/python3.8/dist-packages

ARG OPENCV_VERSION="4.5.1"
ENV OPENCV_VERSION $OPENCV_VERSION

RUN curl -Lo opencv.zip https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
            unzip -q opencv.zip && \
            curl -Lo opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip && \
            unzip -q opencv_contrib.zip && \
            rm opencv.zip opencv_contrib.zip && \
            cd opencv-${OPENCV_VERSION} && \
            mkdir build && cd build && \
            cmake -D CMAKE_BUILD_TYPE=RELEASE \
                  -D CMAKE_INSTALL_PREFIX=/usr/local \
                  -D OPENCV_EXTRA_MODULES_PATH=/usr/local/lib/python3.8/dist-packages/opencv_contrib-${OPENCV_VERSION}/modules \
                  -D OPENCV_ENABLE_NONFREE=ON \
                  -D BUILD_opencv_python3=YES \
                  -D OPENCV_GENERATE_PKGCONFIG=ON .. && \
            make -j $(nproc --all) && \
            make preinstall && make install && ldconfig && \
            cd / && rm -rf opencv*

ENV PYTHONPATH "${PYTHONPATH}:/usr/local/lib/python3.8/dist-packages/opencv-4.5.1/build/python_loader"

WORKDIR /source

ENTRYPOINT ["python"]