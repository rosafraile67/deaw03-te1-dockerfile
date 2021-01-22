# Creamos la imagen a partir de ubuntu versión 18.04
FROM ubuntu:18.04

# Damos información sobre la imagen que estamos creando
LABEL \
	version="1.0" \
	description="Ubuntu + Apache2 + virtual host + FTP + SSH" \
	creationDate="20-12-2020" \
	maintainer="Rosa Fraile <mfraile@birt.eus>"

# Instalamos el editor nano, Apache y FTP
RUN \
	apt-get update \
	&& apt-get install nano \
	&& apt-get install apache2 --yes \
# Instalamos FTP y ssl
	&& apt-get install -y proftpd && apt-get install openssl \
	&& mkdir /var/www/html/sitio1 /var/www/html/sitio2 \
# Generar usuario rosafraile1
	&& useradd -m -d /var/www/html/sitio1/rosafraile1 -s /usr/sbin/nologin -p $(openssl passwd -1 rosafraile1) rosafraile1 \
# Generar usuario rosafraile2
	&& useradd -m -d /var/www/html/sitio2/rosafraile2 -p $(openssl passwd -1 rosafraile2) rosafraile2 \
# Generar usuario rosafraile para acceso FTP anonimo
	&& useradd -m -d /srv/ftp -s /usr/sbin/nologin rosafraile \
# Generar claves para FTP
	&& openssl req -new -nodes -keyout proftpd.key -out proftpd.crt \
	-subj "/C=ES/ST=Vizcaya/L=Durango/O=ftp.rosafraile.org/OU=ftp.rosafraile.org/CN=ftp.rosafraile.org" \
	-days 365 -x509 \
	&& mv proftpd.crt /etc/ssl/certs/proftpd.crt \
	&& mv proftpd.key /etc/ssl/private/proftpd.key \
# Instalamos ssh y git
	&& apt-get install -y ssh \
	&& apt-get install -y git

# Copiamos los ficheros necesarios al directorio por defecto del servidor Web
COPY index1.html index2.html sitio1.conf sitio2.conf sitio1.key sitio1.cer proftpd.conf tls.conf ftpusers sshd_config id_rsa id_rsa.pub /
# Movemos cada fichero copiado al directorio que le corresponde
RUN \
	mv /index1.html /var/www/html/sitio1/index.html \
	&& mv /index2.html /var/www/html/sitio2/index.html \
	&& mv /sitio1.conf /etc/apache2/sites-available \
	&& a2ensite sitio1 \
	&& mv /sitio2.conf /etc/apache2/sites-available \
	&& a2ensite sitio2 \
	&& mv /sitio1.key /etc/ssl/private \
	&& mv /sitio1.cer /etc/ssl/certs \
	&& a2enmod ssl \
	&& mv /proftpd.conf /etc/proftpd/proftpd.conf \
	&& mv /tls.conf /etc/proftpd/tls.conf \
	&& mv ftpusers /etc/ftpusers \
	&& mv sshd_config /etc/ssh/sshd_config 
	
RUN	mv id_rsa /etc \
	&& eval "$(ssh-agent -s)" \
	&& chmod 700 /etc/id_rsa \
	&& ssh-add /etc/id_rsa \
	&& ssh-keyscan -H github.com >> /etc/ssh/ssh_known_hosts \
	&& git clone git@github.com:deaw-birt/deaw03-te1-ftp-anonimo.git /srv/ftp/deaw03-te1

RUN	mkdir .ssh \
	&& cat id_rsa.pub >> ~/.ssh/authorized_keys \
	mv id_rsa.pub /var/www/html/sitio2/rosafraile2

# Indicamos el puerto que utiliza la imagen
# Puertos para HTTP y HTTPS
EXPOSE 80
EXPOSE 443
# Puertos para FTP
EXPOSE 20
EXPOSE 21
# Puertos para FTP anónimo
EXPOSE 50000-50030
# Puerto para SSH
EXPOSE 1024
