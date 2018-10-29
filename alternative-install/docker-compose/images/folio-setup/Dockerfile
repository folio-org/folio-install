FROM ubuntu:16.04

#Prerequisites
RUN apt-get update
RUN apt-get install -y git curl python libwww-perl libuuid-tiny-perl libjson-perl
RUN apt-get install -y python-pip
RUN pip install --upgrade pip
RUN pip install requests

#Create working directory
RUN mkdir -p /usr/local/bin/folio

#Set working directory
WORKDIR /usr/local/bin/folio

# clone platform-complete
RUN git clone https://github.com/folio-org/platform-complete
RUN git clone https://github.com/folio-org/folio-install

#Copy in scripts and files
COPY setup.sh /usr/local/bin/folio
COPY setup.py /usr/local/bin/folio

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/setup.sh"]
