FROM ubuntu:bionic

ARG DEBIAN_FRONTED='noninteractive'


RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8



## Install some useful tools and dependencies for MRO
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
        wget \
	&& rm -rf /var/lib/apt/lists/*



# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.0 \
    libxml2-dev \
    libssl-dev

# system library dependency for the euler app
RUN apt-get update && apt-get install -y \
    libmpfr-dev \
    gfortran \
    aptitude \
    libgdal-dev \
    libproj-dev \
    g++ \
    libicu-dev \
    libpcre3-dev\
    libbz2-dev \
    liblzma-dev \
    openjdk-7-jdk \
    libnlopt-dev \
    build-essential
    
WORKDIR /home/docker

# Download, valiate, and unpack and install Micrisift R open
RUN wget https://www.dropbox.com/s/uz4e4d0frk21cvn/microsoft-r-open-3.5.1.tar.gz?dl=1 -O microsoft-r-open-3.5.1.tar.gz \
&& echo "9791AAFB94844544930A1D896F2BF1404205DBF2EC059C51AE75EBB3A31B3792 microsoft-r-open-3.5.1.tar.gz" > checksum.txt \
	&& sha256sum -c --strict checksum.txt \
	&& tar -xf microsoft-r-open-3.5.1.tar.gz \
	&& cd /home/docker/microsoft-r-open \
	&& ./install.sh -a -u \
	&& ls logs && cat logs/*


# Clean up
WORKDIR /home/docker
RUN rm microsoft-r-open-3.5.1.tar.gz \
	&& rm checksum.txt \
&& rm -r microsoft-r-open


#COPY Makeconf /usr/lib64/microsoft-r/3.3/lib64/R/etc/Makeconf

RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
RUN apt-get update
RUN apt-get install -y libudunits2-dev libgdal-dev libgeos-dev 


RUN sudo apt-add-repository -y ppa:webupd8team/java \
&& apt-get update && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections && apt-get install -y oracle-java8-installer \
&& R -e "Sys.setenv(JAVA_HOME = '/usr/lib/jvm/java-8-oracle/jre')"
RUN sudo java -version

#RUN sudo R CMD javareconf
RUN sudo apt-get install -y ncbi-blast+

# basic shiny functionality
RUN sudo R -e "install.packages('rmarkdown', repos='http://cran.rstudio.com/')" \
&& R -e "install.packages(c('shiny'), repos='http://cran.rstudio.com/')" \
&& R -e "install.packages('binom', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('dplyr', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('purrr', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('ggplot2', repos='https://cran.r-project.org/')"
