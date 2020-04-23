# See https://github.com/phusion/baseimage-docker/releases for a list of releases.
FROM phusion/baseimage:0.11
LABEL maintainer="bbsoftware@biggerbird.com"

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

# Update packages
RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confnew"

# base packages: most setups need these
RUN apt-get install -y tzdata

# cmd line utilities
RUN apt-get install -y bzip2 git wget unzip zip

# crystal runtime dependencies: https://crystal-lang.org/install/on_ubuntu/
RUN apt-get install -y libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev libz-dev

# crystal build dependencies: https://github.com/crystal-lang/crystal/wiki/All-required-libraries#ubuntu
RUN apt-get install -y libbsd-dev libedit-dev libevent-dev libgmpxx4ldbl automake libtool llvm-8 llvm-8-dev lld-8 libpcre3-dev build-essential
RUN ln -sf /usr/bin/ld.lld-8 /usr/bin/ld.lld

# db shard dependencies
RUN apt-get install -y libsqlite3-dev libpq-dev libmysqlclient-dev

WORKDIR /tmp

# Pick a Crystal version and install the amd64 .deb: https://github.com/crystal-lang/crystal/releases
# RUN curl -sL https://github.com/crystal-lang/crystal/releases/download/0.33.0/crystal_0.33.0-1_amd64.deb > crystal.deb
RUN curl -sL https://github.com/crystal-lang/crystal/releases/download/0.34.0/crystal_0.34.0-1_amd64.deb > crystal.deb
RUN apt-get install -y ./crystal.deb

# Build guardian
RUN git clone https://github.com/f/guardian.git && cd guardian && crystal build src/guardian.cr --release && cp guardian /usr/bin/

# Pick an Amber version: https://github.com/amberframework/amber/releases
RUN curl -sL https://github.com/amberframework/amber/archive/v0.34.0.tar.gz | tar xz
RUN cd amber-*/ && make && make install

# Add app user
RUN useradd -m -k /etc/skel app
WORKDIR /home/app/myapp

# Startup scripts
RUN mkdir -p /etc/my_init.d
COPY docker/startup/chown.sh /etc/my_init.d/

# Post-build clean up
RUN apt-get autoremove -y && apt-get clean && rm -rf /tmp/* /var/tmp/*

# Expose port(s) so we can access from host (remember to publish using `docker run -p` or ports section in docker-compose config)
EXPOSE 3000

# Run this to start all services (if no command was provided to `docker run`)
CMD ["/sbin/my_init"]
