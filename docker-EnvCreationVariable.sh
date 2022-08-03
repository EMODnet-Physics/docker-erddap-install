### HOST VARIABLES
# this is the user used by ERDDAP to access the MYDOCKER_DATA_DIR
ERDDAP_user="ettdev"

### DOCKER
# this is the folder where will be created all the deployement directories.
MYDOCKER_ROOT_DIR="/media/ettdev/Volume/erddap-docker/"
# this is the folder where you put data accessible by ERDDAP
MYDOCKER_DATA_DIR="/media/ettdev/Volume/erddap-docker/data_dir"
# this is the port used by the container
MYDOCKER_HOST_ERDDAP_PORT="12081"

### APACHE VARIABLES
#These are default paths for Apache on CentOS, change them if different
APACHE_SITE_CONF_DIR="/etc/httpd/conf.d"
APACHE_SERVICE_NAME="httpd"
APACHE_SITE_PATH="/var/www/html"
APACHE_LOG_DIR="/var/log/httpd"
# For the VHOST_FILENAME keep the 00_ if you want that this is the first vhost loaded by Apache
# It will be used as filename for the configuration file
APACHE_VHOST_FILENAME="00_<your project/company/... name>"
# Put here the IPv4 or the domain (without http/https, i.e: www.somedomain.com)
APACHE_DOMAIN_ROOT="localhost:12081"
# change this variable if you need to access ERDDAP with a different path than http(s)://{APACHE_DOMAIN_ROOT}/erddap/
APACHE_PROXY_LOCATION="/erddap"
# change these variables if the docker container is not accessible at 127.0.0.1
APACHE_PROXY_URL_PROXYPASS="http://127.0.0.1:${MYDOCKER_HOST_ERDDAP_PORT}/erddap"
APACHE_PROXY_URL_PROXYPASSREVERSE="http://127.0.0.1:${MYDOCKER_HOST_ERDDAP_PORT}/erddap"
#change these for SSL if needed
APACHE_SSLCertificateFile="path to SSL Certificate File"      
APACHE_SSLCertificateKeyFile="path to SSL Certificate Key File"   

### ERDDAP VARIABLES
# Environment Variables - Starting with ERDDAP v2.14, ERDDAP administrators can override any value in setup.xml by specifying an environment variable named ERDDAP_valueName before running ERDDAP
# bigParentDirectory - Same as volume mounted in the container
ERDDAP_bigParentDirectory="/erddapData"
# baseUrl - Same as the URL that you setup in the web proxy that handle the comunication with the container
ERDDAP_baseUrl="http://${APACHE_DOMAIN_ROOT}"
# baseUrl - Same as the URL that you setup in the web proxy that handle the SSL comunication with the container
ERDDAP_baseHttpsUrl="https://${APACHE_DOMAIN_ROOT}"
# CHANGE THE FOLLOWING VARIABLES
ERDDAP_emailEverythingTo="marco.alba@ettsolutions.com"
ERDDAP_adminInstitution="ETT S.p.A. - People and Technology"
ERDDAP_adminInstitutionUrl="https://www.ettsolutions.com/"
ERDDAP_adminIndividualName="ETT Ricerca"
ERDDAP_adminPosition="ERDDAP administrator"
ERDDAP_adminPhone="+39 010 6519116"
ERDDAP_adminAddress="Via Sestri 37"
ERDDAP_adminCity="GENOVA"
ERDDAP_adminStateOrProvince="GE"
ERDDAP_adminPostalCode="16154"
ERDDAP_adminCountry="ITALY"
ERDDAP_adminemail="ricerca.innovazione.ett@ettsolutions.com"
ERDDAP_flagKeyKey="CHANGE ME!xxx"
ERDDAP_emailDailyReportsTo="nobody@example.com" 

# OPTIONAL - use an empty dataset
# set to 1 to use an empty datasets configuration, 0 to use the default datasets configuration 
ERDDAP_UseEmptyDataset=1

# OPTIONAL - Set ERDDAP mail parameters
# This enable (1) or disable (0) the mail parameters configuration
ERDDAP_SetMailParameters=0
ERDDAP_emailFromAddress=""
ERDDAP_emailUserName=""
# If you use the '|' in the password, than leave the variable blank and set the parameters when the configuration is finished.
ERDDAP_emailPassword=""
ERDDAP_emailProperties=""
ERDDAP_emailSmtpHost=""
ERDDAP_emailSmtpPort=""
# these variables set the minimum and maximum memory available in ERDDAP, set by default at 4 GigaBytes
ERDDAP_MIN_MEMORY="2G"
ERDDAP_MAX_MEMORY="2G"
###
