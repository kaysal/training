FROM php:7.2-apache

RUN cd /var/www/html/
RUN rm index.html -f
RUN rm index.php -f
COPY index.php .
COPY prod.png .
RUN sed -i '/Listen 80/c\Listen 8080' /etc/apache2/ports.conf
RUN apt-get clean
EXPOSE 8080
CMD ["apache2ctl", "-D", "FOREGROUND"]
