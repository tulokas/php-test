FROM php:8.2-cli

RUN docker-php-ext-install mysqli

COPY index.php /var/www/html/index.php
COPY wait-for-mysql.sh /wait-for-mysql.sh
RUN chmod +x /wait-for-mysql.sh

WORKDIR /var/www/html
ENTRYPOINT ["/wait-for-mysql.sh"]