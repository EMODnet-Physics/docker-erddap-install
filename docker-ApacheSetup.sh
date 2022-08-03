#!/bin/bash
echo setup Apache
# For Red Hat-like distribution
# Copia dei file di template del virtual host
cp $DEPLOYROOTSCRIPT/templates/apache.vhost.template $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
# Modifica del template del virtual host del frontend
sed -i "s@ph_MYROOTDOMAIN@${APACHE_DOMAIN_ROOT}@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
sed -i "s@ph_MYSITEPATH@${APACHE_SITE_PATH}@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
sed -i "s@ph_APACHE_LOG_DIR@${APACHE_LOG_DIR}@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
sed -i "s@ph_PROXY_Location@${APACHE_PROXY_LOCATION}@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
sed -i "s@ph_PROXY_URL_ProxyPassReverse@${APACHE_PROXY_URL_PROXYPASSREVERSE}@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
sed -i "s@ph_PROXY_URL_ProxyPass@${APACHE_PROXY_URL_PROXYPASS}@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf

read -r -p "Do you wish to enable SSL on APACHE? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    ERDDAP_baseHttpsUrl=""
    sed -i "s@:80@:443@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
    sed -i "s@ph_FRONTEND_SSL_CERTWITHCA@${APACHE_SSLCertificateFile}@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
    sed -i "s@ph_FRONTEND_SSL_KEY@${APACHE_SSLCertificateKeyFile}@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
    sed -i "s@#SSLEngine@SSLEngine@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
    sed -i "s@#SSLCertificateFile@SSLCertificateFile@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
    sed -i "s@#SSLCertificateKeyFile@SSLCertificateKeyFile@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
    sed -i "s@#SSLCipherSuite@SSLCipherSuite@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
    sed -i "s@#SSLHonorCipherOrder@SSLHonorCipherOrder@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
    sed -i "s@#SSLCompression@SSLCompression@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
    sed -i "s@#SSLSessionTickets@SSLSessionTickets@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
    sed -i "s@#SSLProtocol@SSLProtocol@g" $APACHE_SITE_CONF_DIR/$APACHE_VHOST_FILENAME.conf
fi

# Restart Apache
echo -n restart Apache....
systemctl restart $APACHE_SERVICE_NAME
echo done!