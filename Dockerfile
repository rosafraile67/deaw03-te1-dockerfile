# Creamos la imagen a partir de ubuntu versión 18.04
FROM ubuntu:18.04

# Damos información sobre la imagen que estamos creando
LABEL \
	version="1.0" \
	description="Ubuntu + Apache2 + virtual host" \
	creationDate="23-11-2019" \
	maintainer="Nora San Saturnino <nsansaturnino@birt.eus>"

# Instalamos el editor nano
RUN \
	apt-get update \
	&& apt-get install nano \
	&& apt-get install apache2 --yes \
	&& mkdir /var/www/html/sitio1 /var/www/html/sitio2
	# && apt-get install ssh --yes \
	# && apt-get install git --yes

# Copiamos el index al directorio por defecto del servidor Web
COPY index1.html index2.html sitio1.conf sitio2.conf sitio1.key sitio1.cer /

RUN \
	mv /index1.html /var/www/html/sitio1/index.html \
	&& mv /index2.html /var/www/html/sitio2/index.html \
	&& mv /sitio1.conf /etc/apache2/sites-available \
	&& a2ensite sitio1 \
	&& mv /sitio2.conf /etc/apache2/sites-available \
	&& a2ensite sitio2 \
	&& mv /sitio1.key /etc/ssl/private \
	&& mv /sitio1.cer /etc/ssl/certs \
	&& a2enmod ssl

# Copiamos la clave privada
#COPY SSH-key/id_rsa /etc 

# arrancamos el ssh-agent, añadimos la clave y el host
#RUN eval "$(ssh-agent -s)" \
#&& chmod 700 /etc/id_rsa \
#&& ssh-add /etc/id_rsa \
#&& ssh-keyscan -H github.com >> /etc/ssh/ssh_known_hosts \
#&& git clone git@github.com:deaw-birt/proyecto-html.git /usr/local/apache2/htdocs/proyecto

# Indicamos el puerto que utiliza la imagen
EXPOSE 80
EXPOSE 443