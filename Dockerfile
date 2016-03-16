FROM phusion/baseimage:0.9.18

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
RUN apt-get update && \
    apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
    add-apt-repository -y ppa:ondrej/php && \
    add-apt-repository -y ppa:nginx/stable && \
    curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash - && \
    apt-get update && \
    apt-get install -y \
        php7.0-cli php7.0-fpm php7.0-curl php7.0-mysql php7.0-gd php7.0-mcrypt php7.0-readline php-zip php-xml php-mbstring \
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
RUN pip install yas3fs

###
# CONFIGURE PACKAGES
###

# Configure nginx
ADD conf/nginx/server.conf /etc/nginx/sites-available/
ADD conf/nginx/php-fpm.conf /etc/nginx/
ADD conf/nginx/pingdom.conf /etc/nginx/whitelists/

RUN echo "daemon off;" >> /etc/nginx/nginx.conf && \
    echo "# No frontend IP whitelist configured. Come one, come all!" > /etc/nginx/whitelist-frontend.conf && \
    rm /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/server.conf /etc/nginx/sites-enabled/server.conf

# Configure php-fpm
ADD conf/php-fpm/php-fpm.conf /etc/php/7.0/fpm
ADD conf/php-fpm/php.ini /etc/php/7.0/fpm
ADD conf/php-fpm/pool.conf /etc/php/7.0/fpm/pool.d
RUN rm /etc/php/7.0/fpm/pool.d/www.conf

# Configure cron tasks
ADD conf/cron.d/* /etc/cron.d/

# Configure init scripts
ADD init/* /etc/my_init.d/
RUN chmod +x /etc/my_init.d/*

# Configure bash
RUN echo "export TERM=xterm" >> /etc/bash.bashrc && \
    echo "alias wp=\"wp --allow-root\"" > /root/.bash_aliases

# Configure services
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
