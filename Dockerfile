FROM phusion/baseimage:0.9.19

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Set system locale
ENV LC_ALL="en_GB.UTF-8" \
    LANG="en_GB.UTF-8" \
    LANGUAGE="en_GB.UTF-8"

###
# INSTALL PACKAGES
###

# Upgrade & install packages
RUN add-apt-repository -y ppa:ondrej/php && \
    add-apt-repository -y ppa:nginx/stable && \
    curl -sL https://deb.nodesource.com/setup_5.x | bash - && \
    apt-get update && \
    apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        php7.0-cli php7.0-curl php7.0-fpm php7.0-gd php-mbstring php7.0-mcrypt php7.0-mysql php7.0-readline php-xdebug php7.0-xml php7.0-zip \
        nginx nginx-extras\
        python-pip libfuse-dev \
        nullmailer \
        git nano \
        nodejs build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /init

# Install composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Install yas3fs
# Note: using the master branch because there are changes waiting for release
RUN pip install git+https://github.com/danilop/yas3fs.git@master

###
# CONFIGURE PACKAGES
###

# Add all config files
ADD conf/ /tmp/conf

# Configure nginx
RUN mv /tmp/conf/nginx/server.conf /etc/nginx/sites-available/ && \
    mv /tmp/conf/nginx/php-fpm.conf /etc/nginx/ && \
    mkdir /etc/nginx/whitelists/ && \
    mv /tmp/conf/nginx/pingdom.conf /etc/nginx/whitelists/ && \
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    echo "# No frontend IP whitelist configured. Come one, come all!" > /etc/nginx/whitelists/site-wide.conf && \
    echo "# This file is configured at runtime." > /etc/nginx/real_ip.conf && \
    rm /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/server.conf /etc/nginx/sites-enabled/server.conf && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Configure php-fpm
RUN mv /tmp/conf/php-fpm/php-fpm.conf /etc/php/7.0/fpm && \
    mv /tmp/conf/php-fpm/php.ini /etc/php/7.0/fpm && \
    mv /tmp/conf/php-fpm/pool.conf /etc/php/7.0/fpm/pool.d && \
    rm /etc/php/7.0/fpm/pool.d/www.conf && \
    cat /tmp/conf/php-fpm/xdebug.ini >> /etc/php/7.0/mods-available/xdebug.ini && \
    phpdismod xdebug

# Configure cron tasks
RUN mv /tmp/conf/cron.d/* /etc/cron.d/

# Configure bash
RUN echo "export TERM=xterm" >> /etc/bash.bashrc && \
    echo "alias wp=\"wp --allow-root\"" > /root/.bash_aliases

# Cleanup /tmp/conf
RUN rm -Rf /tmp/conf

###
# CONFIGURE INIT SCRIPTS
###

ADD init/* /etc/my_init.d/
RUN chmod +x /etc/my_init.d/*

###
# CONFIGURE SERVICES
###

ADD service/* /etc/service/
RUN mkdir /etc/service/nginx && \
    mkdir /etc/service/nullmailer && \
    mkdir /etc/service/php-fpm && \
    mkdir /etc/service/yas3fs && \
    mv /etc/service/nginx.sh /etc/service/nginx/run && \
    mv /etc/service/nullmailer.sh /etc/service/nullmailer/run && \
    mv /etc/service/php-fpm.sh /etc/service/php-fpm/run && \
    mv /etc/service/yas3fs.sh /etc/service/yas3fs/run && \
    chmod +x /etc/service/nginx/run && \
    chmod +x /etc/service/nullmailer/run && \
    chmod +x /etc/service/php-fpm/run && \
    chmod +x /etc/service/yas3fs/run

# Create bedrock directory
RUN mkdir /bedrock

EXPOSE 80
