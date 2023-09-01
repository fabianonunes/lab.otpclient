# syntax=docker/dockerfile:1.4
FROM ubuntu:20.04 as builder

ARG TZ=UTC
SHELL [ "/bin/bash", "-ex", "-c" ]

RUN <<EOT
  apt-get update;
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime;
  apt-get install -y --no-install-recommends \
    build-essential                          \
    cmake                                    \
    debugedit                                \
    libgcrypt20-dev                          \
    libgtk-3-dev                             \
    libjansson-dev                           \
    libpng-dev                               \
    libzbar-dev                              \
    libzip-dev                               \
    pkg-config                               \
    po4a                                     \
    wget                                     \
  ;
EOT

ARG DEB_BUILD_OPTIONS="parallel=16 nocheck nodoc notest"

WORKDIR /app/debhelper
RUN <<EOT
  wget http://archive.ubuntu.com/ubuntu/pool/main/d/debhelper/debhelper_13.6ubuntu1.dsc
  wget http://archive.ubuntu.com/ubuntu/pool/main/d/debhelper/debhelper_13.6ubuntu1.tar.xz
  dpkg-source -x debhelper_13.6ubuntu1.dsc
  cd debhelper-13.6ubuntu1
  dpkg-buildpackage -rfakeroot -b -uc -us -nc
  apt-get install -yf ../*.deb
EOT

WORKDIR /app/libbaseencode
RUN <<EOT
  wget http://archive.ubuntu.com/ubuntu/pool/universe/libb/libbaseencode/libbaseencode_1.0.12-2.dsc
  wget http://archive.ubuntu.com/ubuntu/pool/universe/libb/libbaseencode/libbaseencode_1.0.12.orig.tar.gz
  wget http://archive.ubuntu.com/ubuntu/pool/universe/libb/libbaseencode/libbaseencode_1.0.12.orig.tar.gz.asc
  wget http://archive.ubuntu.com/ubuntu/pool/universe/libb/libbaseencode/libbaseencode_1.0.12-2.debian.tar.xz
  dpkg-source -x libbaseencode_1.0.12-2.dsc
  cd libbaseencode-1.0.12
  dpkg-buildpackage -rfakeroot -b -uc -us -nc
  cp ../libbaseencode1_1.0.12-2_amd64.deb /app
  apt-get install -yf ../*.deb
EOT

WORKDIR /app/libcotp
RUN <<EOT
  wget http://archive.ubuntu.com/ubuntu/pool/universe/libc/libcotp/libcotp_1.2.4-1.dsc
  wget http://archive.ubuntu.com/ubuntu/pool/universe/libc/libcotp/libcotp_1.2.4.orig.tar.gz
  wget http://archive.ubuntu.com/ubuntu/pool/universe/libc/libcotp/libcotp_1.2.4.orig.tar.gz.asc
  wget http://archive.ubuntu.com/ubuntu/pool/universe/libc/libcotp/libcotp_1.2.4-1.debian.tar.xz
  dpkg-source -x libcotp_1.2.4-1.dsc
  cd libcotp-1.2.4
  dpkg-buildpackage -rfakeroot -b -uc -us -nc
  cp ../libcotp12_1.2.4-1_amd64.deb /app
  apt-get install -yf ../*.deb
EOT

WORKDIR /app/otpclient
RUN <<EOT
  wget http://archive.ubuntu.com/ubuntu/pool/universe/o/otpclient/otpclient_2.4.6-1.dsc
  wget http://archive.ubuntu.com/ubuntu/pool/universe/o/otpclient/otpclient_2.4.6.orig.tar.gz
  wget http://archive.ubuntu.com/ubuntu/pool/universe/o/otpclient/otpclient_2.4.6.orig.tar.gz.asc
  wget http://archive.ubuntu.com/ubuntu/pool/universe/o/otpclient/otpclient_2.4.6-1.debian.tar.xz
  dpkg-source -x otpclient_2.4.6-1.dsc
  cd otpclient-2.4.6
  dpkg-buildpackage -rfakeroot -b -uc -us -nc
  cp ../otpclient-cli_2.4.6-1_amd64.deb /app
  cp ../otpclient_2.4.6-1_amd64.deb /app
EOT

FROM scratch AS export
COPY --from=builder /app/*.deb .
