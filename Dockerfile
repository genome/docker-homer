FROM ubuntu:xenial
MAINTAINER Chris Miller <c.a.miller@wustl.edu>

LABEL Image for homer

# annotation data is too large to include in this image, so it
# requires a directory to be mounted at /opt/homerdata/ containing
#  - config.txt - homer configuration file with directories pointing to paths like "data/accession"
#  - data  - folder containing homer annotation data files
# at WUSTL, this can be provided by providing the following in an analysis-project configuration:
#    docker_volumes: "/gscmnt/gc2560/core/annotation_data/homer:/opt/homerdata"
# or outside the pipelines:
#    LSF_DOCKER_VOLUMES="$LSF_DOCKER_VOLUMES /gscmnt/gc2560/core/annotation_data/homer:/opt/homerdata"

RUN apt-get update && apt-get install -y libnss-sss samtools r-base r-base-dev tabix wget && apt-get clean all

#set timezone to CDT to avoid confusion
#LSF: Java bug that need to change the /etc/timezone.
#/etc/localtime is not enough.
RUN ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    echo "America/Chicago" > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata

ADD rpackages.R /tmp/
RUN R -f /tmp/rpackages.R

#install homer
RUN mkdir /opt/homer/ && cd /opt/homer && wget http://homer.ucsd.edu/homer/configureHomer.pl && /usr/bin/perl configureHomer.pl -install 

#softlink config file and data directory
RUN rm -rf /opt/homer/data && ln -s /opt/homerdata/data /opt/homer/data
RUN rm -f /opt/homer/config.txt && ln -s /opt/homerdata/config.txt /opt/homer/config.txt

ENV PATH=${PATH}:/opt/homer/bin/
