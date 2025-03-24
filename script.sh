#/bin/bash

echo "Nombre del Dominio: "
read DOMAIN
echo "Nombre del SubDominio: "
read SUBDOMAIN
echo "Correo del Admin: "
read ADMIN_EMAIL

FULL_DOMAIN="$SUBDOMAIN.$DOMAIN"
CONF_FILE="/etc/apache2/sites-available/$FULL_DOMAIN.conf"
DOC_ROOT="/var/www/$FULL_DOMAIN/public_html"
CERT_DIR="/etc/ssl/$FULL_DOMAIN"
CERT_FILE="$CERT_DIR/$FULL_DOMAIN.crt"
KEY_FILE="$CERT_DIR/$FULL_DOMAIN.key"

mkdir -p "$DOC_ROOT"
chown -R www-data:www-data "$DOC_ROOT"
chmod -R 755 "$DOC_ROOT"
echo "<h1>Bienvenido a $FULL_DOMAIN</h1>" > "$DOC_ROOT/index.html"

mkdir -p "$CERT_DIR"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$KEY_FILE" -out "$CERT_FILE" -subj "/CN=$FULL_DOMAIN"

a2enmod ssl

cat <<EOL > "$CONF_FILE"
<VirtualHost *:443>
    ServerName $FULL_DOMAIN
    ServerAdmin $ADMIN_EMAIL
    DocumentRoot $DOC_ROOT
    SSLEngine on
    SSLCertificateFile $CERT_FILE
    SSLCertificateKeyFile $KEY_FILE
    <Directory $DOC_ROOT>
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/$FULL_DOMAIN_error.log
    CustomLog \${APACHE_LOG_DIR}/$FULL_DOMAIN_access.log combined
</VirtualHost>
EOL

a2ensite "$FULL_DOMAIN.conf"
systemctl reload apache2

echo "Subdominio $FULL_DOMAIN configurado."
