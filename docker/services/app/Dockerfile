FROM ubuntu:16.04

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

ENV APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid

# Add multiverse to access mod-fastcgi.
RUN echo "deb http://archive.ubuntu.com/ubuntu xenial multiverse" >> /etc/apt/sources.list \
  && echo "deb-src http://archive.ubuntu.com/ubuntu xenial multiverse" >> /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu xenial-updates multiverse" >> /etc/apt/sources.list \
  && echo "deb-src http://archive.ubuntu.com/ubuntu xenial-updates multiverse" >> /etc/apt/sources.list

# Install packages.
RUN apt-get update -qy --fix-missing \
  && apt-get install -qy --no-install-recommends \
      apache2 \
      build-essential \
      curl \
      git \
      libapache2-mod-fastcgi \
      libcurl4-openssl-dev \
      ntp \
      mysql-client

# Install PHP.
RUN apt-get install -qy --no-install-recommends software-properties-common \
  && LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php \
  && apt-get update \
  && apt-get install -qy --no-install-recommends \
      php7.1 \
      php7.1-mysql \
      php7.1-bcmath \
      php7.1-cli \
      php7.1-curl \
      php7.1-dev \
      php7.1-fpm \
      php7.1-gd \
      php7.1-intl \
      php7.1-ldap \
      php7.1-mbstring \
      php7.1-mcrypt \
      php7.1-xml \
      php7.1-xdebug \
      supervisor \
      sendmail \
      unzip \
      vim \
      wget \
      zip

# Setup Apache.
RUN a2dismod mpm_event \
  && a2enmod mpm_prefork rewrite actions fastcgi alias headers ssl \
  && rm /etc/apache2/sites-enabled/*default* \
  && mkdir -p /var/www/html ${APACHE_RUN_DIR} ${APACHE_LOCK_DIR} ${APACHE_LOG_DIR} \
  && chown ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} \
      /var/www/html \
      ${APACHE_RUN_DIR} \
      ${APACHE_LOCK_DIR} \
      ${APACHE_LOG_DIR}

# Varnish is being installed from source because we need to VCL mod to allow for dynamic configurations
RUN apt-get update && apt-get install -y autoconf \
    automake \
    autotools-dev \
    libedit-dev \
    libjemalloc-dev \
    libncurses-dev \
    libpcre3-dev \
    libtool \
    pkg-config \
    python-docutils \
    python-sphinx \
  && cd /tmp \
    && wget https://github.com/varnishcache/varnish-cache/archive/varnish-4.1.8.tar.gz \
    && wget https://github.com/Dridi/libvmod-querystring/releases/download/v1.0.1/vmod-querystring-1.0.1.tar.gz \
    && tar xfz varnish-4.1.8.tar.gz \
    && rm -rf /tmp/varnish-4.1.8.tar.gz \
    && tar xfz vmod-querystring-1.0.1.tar.gz \
    && rm -rf /tmp/vmod-querystring-1.0.1.tar.gz \
  && cd /tmp/varnish-cache-varnish-4.1.8 \
    && sh autogen.sh \
    && sh configure \
    && make && make install \
  # Varnish querystring module
  && cd /tmp/vmod-querystring-1.0.1 \
    && sh configure \
    && make \
    && make install \
  && rm -rf /tmp/varnish-cache-varnish-4.1.8 \
  && rm -rf /tmp/vmod-querystring-1.0.1 \
  && ldconfig \
  && mkdir -p /etc/varnish

# Install composer.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Cleanup.
RUN rm -rf /var/cache/apt/* \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  && rm -rf /var/tmp/*

COPY ./resources/ /

EXPOSE 80
EXPOSE 443
EXPOSE 8080

WORKDIR /var/www/html

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
