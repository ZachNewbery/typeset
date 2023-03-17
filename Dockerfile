FROM gapsystem/gap-docker

MAINTAINER Zachariah Newbery <zachariah.newbery@gmail.com>

# Update version number each time after gap-docker container is updated
ENV GAP_VERSION 4.11.1

# Remove previous typeset installation, copy this repository and make new install

RUN cd /home/gap/inst/gap-${GAP_VERSION}/pkg/ \
    && rm -rf typeset \
    && wget https://github.com/ZachNewbery/typeset/archive/main.zip \
    && unzip -q typeset-main.zip \
    && rm typeset-main.zip \
    && mv typeset-main typeset

USER gap

WORKDIR /home/gap/inst/gap-${GAP_VERSION}/pkg/typeset/demos
