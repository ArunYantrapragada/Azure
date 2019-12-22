FROM nbas/png-bash-worker
MAINTAINER Arun

RUN apt-get update -y \
 && apt-get install -y \
	unzip \
	zip \
	vim \
	lsb-release

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

# Install python3
RUN apt-get update -y \
    && apt-get install -y \
    python3 \
    python3-dev \
    python3-pip

## Install R
RUN apt-get install -y \
    r-base \
    g++ \
    libczmq-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libssl-dev
RUN apt-get clean

#Install azure-cli

RUN AZ_REPO=$(lsb_release -cs) && \
	echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list

RUN curl -L https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN apt-get install apt-transport-https
RUN apt-get update && apt-get install azure-cli
RUN pip install azure-servicebus

## packages to install
COPY install.R /home/
RUN Rscript /home/install.R