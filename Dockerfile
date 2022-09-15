FROM phusion/baseimage:master-amd64

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Set system locale
ENV LC_ALL="en_GB.UTF-8" \
    LANG="en_GB.UTF-8" \
    LANGUAGE="en_GB.UTF-8"

###
# INSTALL PACKAGES.
###

# Upgrade & install packages
RUN add-apt-repository -y ppa:ondrej/php && \
    add-apt-repository -y ppa:ondrej/nginx && \
    curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get update && \
    apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
    apt-get install -y php8.1 && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        php8.1-cli php8.1-curl php8.1-fpm php8.1-gd php8.1-mbstring php8.1-mysql php8.1-readline php8.1-xdebug php8.1-xml php8.1-zip php8.1-imagick \
        nginx nginx-extras\
        python3-pip libfuse-dev \
        nullmailer \
        git nano \
        mariadb-client-10.3 \
        nodejs build-essential \
        unzip && \
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
# Note: using a specific commit from master because there are changes waiting for release
# Note (20/03/2019) removed specific commit - now on master
RUN pip3 install git+https://github.com/danilop/yas3fs.git

###
# CONFIGURE PACKAGES
###

# Add all config files
ADD conf/ /tmp/conf

# Configure nginx
RUN mv /tmp/conf/nginx/server.conf /etc/nginx/sites-available/ && \
    mv /tmp/conf/nginx/php-fpm.conf /etc/nginx/ && \
    mkdir /etc/nginx/whitelists/ && \
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    echo "# No frontend IP whitelist configured. Come one, come all!" > /etc/nginx/whitelists/site-wide.conf && \
    echo "# No login IP whitelist configured. Come one, come all!" > /etc/nginx/whitelists/wp-login.conf && \
    echo "# This file is configured at runtime." > /etc/nginx/real_ip.conf && \
    rm /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/server.conf /etc/nginx/sites-enabled/server.conf && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Configure php-fpm
RUN mv /tmp/conf/php-fpm/php-fpm.conf /etc/php/8.1/fpm && \
    mv /tmp/conf/php-fpm/php.ini /etc/php/8.1/fpm && \
    mv /tmp/conf/php-fpm/pool.conf /etc/php/8.1/fpm/pool.d && \
    rm /etc/php/8.1/fpm/pool.d/www.conf && \
    cat /tmp/conf/php-fpm/xdebug.ini >> /etc/php/8.1/mods-available/xdebug.ini && \
    phpdismod xdebug

# Configure cron tasks
RUN mv /tmp/conf/cron.d/* /etc/cron.d/

# Configure bash
RUN echo "export TERM=xterm" >> /etc/bash.bashrc && \
    echo "alias wp=\"wp --allow-root\"" > /root/.bash_aliases && \
    sed -i -e 's/@\\h:/@\$\{SERVER_NAME\}:/' /root/.bashrc

# Configure ImageMagick
RUN mv /tmp/conf/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml

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

# Put a dummy file in /tmp directory to stop yas3fs from deleting /tmp
# This can be removed once the bug with yas3fs is fix, and the version of yas3fs used in this image is updated
# Issue: https://github.com/danilop/yas3fs/issues/150
RUN echo "This file exists to ensure that yas3fs doesn't delete the /tmp directory. For more info see comments in the wordpress-base Dockerfile." > /tmp/keeptmp

###
# BUILD TIME COMMANDS
###

# Generate the Pingdom IP address whitelist
ADD build/ /tmp/build
RUN chmod +x /tmp/build/generate-pingdom-whitelist.sh && sleep 1 && \
    /tmp/build/generate-pingdom-whitelist.sh /etc/nginx/whitelists/pingdom.conf && \
    rm -rf /tmp/build

# Create bedrock directory
RUN mkdir /bedrock

EXPOSE 80
