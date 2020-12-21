# Creamos la imagen a partir de ubuntu versión 18.04
FROM ubuntu:18.04

# Damos información sobre la imagen que estamos creando
LABEL \
	version="1.0" \
	description="Ubuntu + Apache2 + virtual host + FTP" \
	creationDate="20-12-2020" \
	maintainer="Rosa Fraile <mfraile@birt.eus>"

# Instalamos el editor nano, Apache y FTP
RUN \
	apt-get update \
	&& apt-get install nano \
	&& apt-get install apache2 --yes \
	&& apt-get install -y proftpd && apt-get install openssl \
	&& mkdir /var/www/html/sitio1 /var/www/html/sitio2 \
# Generar usuario rosafraile1
	&& useradd -m -d /var/www/html/sitio1/rosafraile1 -s /usr/sbin/nologin -p $(openssl passwd -1 rosafraile1) rosafraile1 \
# Generar claves
	&& openssl req -new -nodes -keyout proftpd.key -out proftpd.crt \
	-subj "/C=ES/ST=Vizcaya/L=Durango/O=ftp.rosafraile.org/OU=ftp.rosafraile.org/CN=ftp.rosafraile.org" \
	-days 365 -x509 \
	&& mv proftpd.crt /etc/ssl/certs/proftpd.crt \
	&& mv proftpd.key /etc/ssl/private/proftpd.key

# Copiamos los ficheros necesarios para FTP
COPY proftpd.conf /etc/proftpd/proftpd.conf
COPY tls.conf /etc/proftpd/tls.conf


# Copiamos el index al directorio por defecto del servidor Web
#COPY index1.html index2.html sitio1.conf sitio2.conf sitio1.key sitio1.cer /
COPY index1.html /var/www/html/sitio1/index.html
COPY index2.html /var/www/html/sitio2/index.html
COPY sitio1.conf /etc/apache2/sites-available/ 
COPY sitio2.conf /etc/apache2/sites-available/
COPY sitio1.key /etc/ssl/private/ 
COPY sitio1.cer /etc/ssl/certs/

RUN \
#	mv /index1.html /var/www/html/sitio1/index.html \
#	&& mv /index2.html /var/www/html/sitio2/index.html \
#	&& mv /sitio1.conf /etc/apache2/sites-available \
	a2ensite sitio1 \
#	&& mv /sitio2.conf /etc/apache2/sites-available \
	&& a2ensite sitio2 \
#	&& mv /sitio1.key /etc/ssl/private \
#	&& mv /sitio1.cer /etc/ssl/certs \
	&& a2enmod ssl

# Indicamos el puerto que utiliza la imagen
EXPOSE 80
EXPOSE 443
EXPOSE 20
EXPOSE 21
