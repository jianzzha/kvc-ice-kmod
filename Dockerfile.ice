ARG DRIVER_TOOLKIT_IMAGE

FROM ${DRIVER_TOOLKIT_IMAGE}

WORKDIR /build/

RUN yum -y install git make sudo gcc wget \
&& yum clean all \
&& rm -rf /var/cache/dnf

# Expecting kmod software version as an input to the build
ARG KMODVER=1.6.4
ARG KVER

RUN wget "https://sourceforge.net/projects/e1000/files/ice%20stable/$KMODVER/ice-$KMODVER.tar.gz"
RUN tar zxf ice-$KMODVER.tar.gz
WORKDIR /build/ice-$KMODVER/src

# Prep and build the module
RUN BUILD_KERNEL=${KVER} KSRC=/lib/modules/$KVER/build/ make modules_install

RUN mkdir -p /usr/lib/kvc/ && mkdir -p /etc/kvc/

COPY ice-kmod-lib.sh /usr/lib/kvc/
RUN chmod 644 /usr/lib/kvc/ice-kmod-lib.sh

COPY ice-kmod-wrapper.sh /usr/lib/kvc/
RUN chmod 755 /usr/lib/kvc/ice-kmod-wrapper.sh

COPY ice-kmod.conf /etc/kvc/
RUN chmod 644 /etc/kvc/ice-kmod.conf

RUN systemctl enable kmods-via-containers@ice-kmod

