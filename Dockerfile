### Docker image for amber web development ###

# See https://github.com/phusion/baseimage-docker/releases for a list of releases.
FROM phusion/baseimage:0.11
LABEL maintainer="bbsoftware@biggerbird.com"

# Set up 3rd party repos
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

# Update packages
RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confnew"

# Install other packages we depend on
RUN apt-get install -y tzdata   # base packages: most setups need these
RUN apt-get install -y bzip2 git wget unzip zip  # cmd line utilities
RUN apt-get install -y nodejs
RUN apt-get install -y libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev  # crystal deps
RUN apt-get install -y build-essential                                                # amber deps
RUN apt-get install -y libsqlite3-dev libpq-dev libmysqlclient-dev                    # db deps

RUN apt-get autoremove -y

WORKDIR /tmp

# Pick a Crystal version and install the amd64 .deb: https://github.com/crystal-lang/crystal/releases
RUN curl -sL https://github.com/crystal-lang/crystal/releases/download/0.31.1/crystal_0.31.1-1_amd64.deb > crystal.deb
# RUN curl -sL https://github.com/crystal-lang/crystal/releases/download/0.31.0/crystal_0.31.0-1_amd64.deb > crystal.deb
RUN apt-get install -y ./crystal.deb

# Build guardian
RUN git clone https://github.com/f/guardian.git && cd guardian && crystal build src/guardian.cr --release && cp guardian /usr/bin/

# Pick an Amber version: https://github.com/amberframework/amber/releases
RUN curl -sL https://github.com/amberframework/amber/archive/v0.30.1.tar.gz | tar xz
RUN cd amber-*/ && make && make install

# Add app user
RUN useradd -m -k /etc/skel app
WORKDIR /home/app/myapp

# Startup scripts
RUN mkdir -p /etc/my_init.d
COPY docker/startup/chown.sh /etc/my_init.d/

# Post-build clean up
RUN apt-get clean && rm -rf /tmp/* /var/tmp/*

# Expose port(s) so we can access from host (remember to publish using `docker run -p` or ports section in docker-compose config)
EXPOSE 3000

# Run this to start all services (if no command was provided to `docker run`)
CMD ["/sbin/my_init"]
