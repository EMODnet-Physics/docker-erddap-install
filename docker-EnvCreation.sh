#!/bin/bash
# Set script working path
DEPLOYROOTSCRIPT="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#### DEBUG ####
echo The deploy root script dir is ${DEPLOYROOTSCRIPT}
read -p "Press Enter key to start" ignoreusrinput
#### END DEBUG ####

# Import script variables
echo -n read variables...
source ${DEPLOYROOTSCRIPT}/docker-EnvCreationVariable.sh
echo DONE!

### Apache ###
# Import Apache setup
source ${DEPLOYROOTSCRIPT}/docker-ApacheSetup.sh
# Set default index.html
echo "This is a default index" > $APACHE_SITE_PATH/index.html
### ###

### Create linux users ###
echo -n create linux users...
useradd -m -u 2020 -s /sbin/nologin usrtomcat > /dev/null 2>&1
usermod -L usrtomcat > /dev/null 2>&1
usermod -c ",,,,umask=0002" usrtomcat > /dev/null 2>&1
usermod -a -G ${ERDDAP_user} usrtomcat > /dev/null 2>&1
echo DONE!
### ###

### Create folders for application docker environment ###
echo -n create folders for application docker environment...
# Moving in the root directory of the application docker environment 
cd ${MYDOCKER_ROOT_DIR}
# Creating the directories tree
mkdir -p ${MYDOCKER_ROOT_DIR}/customdocker/{customvolumes,deployfiles}
mkdir -p ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/{erddapContent,erddapData}
mkdir -p ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker
# Set directories permissions
chmod -R 775 ${MYDOCKER_ROOT_DIR}/customdocker/
chmod -R g+s ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes
chmod -R g+s ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles

chown -R root:docker ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes
chown -R root:docker ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles
chown -R usrtomcat:usrtomcat ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent
chown -R usrtomcat:usrtomcat ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapData
# Only fot RedHat-like distribution - Set direcotries context
semanage fcontext -a -t container_file_t "${MYDOCKER_ROOT_DIR}/customdocker/customvolumes(/.*)?"
semanage fcontext -a -t container_share_t "${MYDOCKER_ROOT_DIR}/customdocker/deployfiles(/.*)?"
restorecon -RF ${MYDOCKER_ROOT_DIR}/customdocker

echo DONE!
### ###

### Move files folders in the created directories ###
cp -R ${DEPLOYROOTSCRIPT}/data ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker
cp -R ${DEPLOYROOTSCRIPT}/entrypoints ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker
cp -R ${DEPLOYROOTSCRIPT}/environments ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker
### ###

### Load container default content
echo Load ERDDAP container default content...
## ERDDAP ##
# Extract default ERDDAP Content folder (orgin: https://coastwatch.pfeg.noaa.gov/erddap/download/setup.html#initialSetup - https://github.com/BobSimons/erddap/releases/download/v2.12/erddapContent.zip)

if [ $ERDDAP_UseEmptyDataset -eq 1 ]; then
    tar xzf ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/data/erddap/content.erddap_v218.empyDataset.tar.gz -C ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent
else
    tar xzf ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/data/erddap/content.erddap_v218.tar.gz -C ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent
fi   
chown -R usrtomcat:usrtomcat ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/*
# Set ERDDAP docker environment variable
echo "ERDDAP_bigParentDirectory=${ERDDAP_bigParentDirectory}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_baseUrl=${ERDDAP_baseUrl}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_baseHttpsUrl=${ERDDAP_baseHttpsUrl}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_emailEverythingTo=${ERDDAP_emailEverythingTo}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_adminInstitution=${ERDDAP_adminInstitution}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_adminInstitutionUrl=${ERDDAP_adminInstitutionUrl}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_adminIndividualName=${ERDDAP_adminIndividualName}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_adminPosition=${ERDDAP_adminPosition}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_adminPhone=${ERDDAP_adminPhone}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_adminAddress=${ERDDAP_adminAddress}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_adminCity=${ERDDAP_adminCity}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_adminStateOrProvince=${ERDDAP_adminStateOrProvince}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_adminPostalCode=${ERDDAP_adminPostalCode}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_adminCountry=${ERDDAP_adminCountry}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_adminemail=${ERDDAP_adminemail}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_flagKeyKey=${ERDDAP_flagKeyKey}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_emailDailyReportsTo=${ERDDAP_emailDailyReportsTo}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env

sed -i "s@<bigParentDirectory>/home/yourName/erddap/</bigParentDirectory>@<bigParentDirectory>${ERDDAP_bigParentDirectory}</bigParentDirectory>@g" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
sed -i "s@<baseUrl>http://localhost:8080</baseUrl>@<baseUrl>${ERDDAP_baseUrl}</baseUrl>@g" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
sed -i "s@<baseHttpsUrl></baseHttpsUrl>@<baseHttpsUrl>${ERDDAP_baseHttpsUrl}</baseHttpsUrl>@g" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
sed -i "s|<emailEverythingTo>your.email@yourInstitution.edu</emailEverythingTo>|<emailEverythingTo>${ERDDAP_emailEverythingTo}</emailEverythingTo>|g" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
sed -i "s@<adminInstitution>Your Institution</adminInstitution>@<adminInstitution>${ERDDAP_adminInstitution}</adminInstitution>@" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
sed -i "s@<adminInstitutionUrl>Your Institution's or Group's Url</adminInstitutionUrl>@<adminInstitutionUrl>${ERDDAP_adminInstitutionUrl}</adminInstitutionUrl>@" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
sed -i "s@<adminIndividualName>Your Name</adminIndividualName>@<adminIndividualName>${ERDDAP_adminIndividualName}</adminIndividualName>@" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
sed -i "s@<adminPosition>ERDDAP administrator</adminPosition>@<adminPosition>${ERDDAP_adminPosition}</adminPosition>@" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
sed -i "s@<adminPhone>+1 999-999-9999</adminPhone>@<adminPhone>${ERDDAP_adminPhone}</adminPhone>@" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
sed -i "s@<adminAddress>123 Main St.</adminAddress>@<adminAddress>${ERDDAP_adminAddress}</adminAddress>@" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
sed -i "s@<adminCity>Some Town</adminCity>@<adminCity>${ERDDAP_adminCity}</adminCity>@" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
sed -i "s@<adminStateOrProvince>CA</adminStateOrProvince>@<adminStateOrProvince>${ERDDAP_adminStateOrProvince}</adminStateOrProvince>@" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
sed -i "s@<adminPostalCode>99999</adminPostalCode>@<adminPostalCode>${ERDDAP_adminPostalCode}</adminPostalCode>@" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
sed -i "s@<adminCountry>USA</adminCountry>@<adminCountry>${ERDDAP_adminCountry}</adminCountry>@" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
sed -i "s|<adminEmail>your.email@yourCompany.com</adminEmail>|<adminEmail>${ERDDAP_adminemail}</adminEmail>|" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
sed -i "s@<flagKeyKey>CHANGE THIS TO YOUR FAVORITE QUOTE</flagKeyKey>@<flagKeyKey>${ERDDAP_flagKeyKey}</flagKeyKey>@" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml

if [ $ERDDAP_SetMailParameters -eq 1 ]; then
    sed -i "s|<emailFromAddress>your.email@yourCompany.com</emailFromAddress>|<emailFromAddress>${ERDDAP_emailFromAddress}</emailFromAddress>|" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
    sed -i "s|<emailUserName>your.email@yourCompany.com</emailUserName>|<emailUserName>${ERDDAP_emailUserName}</emailUserName>|" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
    sed -i "s|<emailPassword>yourPassword</emailPassword>@<emailPassword>${ERDDAP_emailPassword}</emailPassword>|" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
    sed -i "s|<emailProperties></emailProperties>|<emailProperties>${ERDDAP_emailProperties}</emailProperties>|" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
    sed -i "s|<emailSmtpHost>your.smtp.host.edu</emailSmtpHost>|<emailSmtpHost>${ERDDAP_emailSmtpHost}</emailSmtpHost>|" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
    sed -i "s|<emailSmtpPort>25</emailSmtpPort>|<emailSmtpPort>${ERDDAP_emailSmtpPort}</emailSmtpPort>|" ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml
else
    echo "The ERDDAP mail parameters will be not configured, as you specified (ERDDAP_SetMailParameters=$ERDDAP_SetMailParameters)."
fi

echo "ERDDAP_MIN_MEMORY=${ERDDAP_MIN_MEMORY}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
echo "ERDDAP_MAX_MEMORY=${ERDDAP_MAX_MEMORY}" >> ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env
### ###

### Set docker-compose file ###
cp ${DEPLOYROOTSCRIPT}/templates/docker-compose.yaml.template ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/docker-compose.yaml
sed -i "s@ph_HOST_ERDDAP_PORT@${MYDOCKER_HOST_ERDDAP_PORT}@g" ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/docker-compose.yaml
sed -i "s@ph_HOST_ERDDAP_ENVIRONMENT_FILE@${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/environments/erddap-compose.env@g" ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/docker-compose.yaml
sed -i "s@ph_MYDOCKER_ERDDAP_DATA@${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapData@g" ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/docker-compose.yaml
sed -i "s@ph_MYDOCKER_ERDDAP_CONTENT@${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent@g" ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/docker-compose.yaml
sed -i "s@ph_MYDOCKER_DATA_DIR@${MYDOCKER_DATA_DIR}@g" ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/docker-compose.yaml
sed -i "s@ph_HOST_ERDDAP_ENTRYPOINT@${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/entrypoints/erddap_entrypoint.sh@g" ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/docker-compose.yaml
### ###

### Set Entrypoint ###
### Set ERDDAP_user value in erddap_entrypoint.sh script ###
sed -i "s@ERDDAP_user@${ERDDAP_user}@g" ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/entrypoints/erddap_entrypoint.sh
### Set ERDDAP permission erddap_entrypoint.sh file ###
chown usrtomcat:usrtomcat ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/entrypoints/erddap_entrypoint.sh
chmod 775 ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/entrypoints/erddap_entrypoint.sh
### ###

echo DONE!

echo "Create ERDDAP Docker"
cd  ${MYDOCKER_ROOT_DIR}/customdocker/deployfiles/erddap-docker/
docker-compose up --no-start
echo DONE!

read -r -p "Do you wish to start ERDDAP? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    docker-compose up -d
fi

### ERDDAP Reminder for password configuration
if [ $ERDDAP_SetMailParameters -eq 1 ]; then
    if [ -z "$MYDOCKER_GEONETWORK_IMAGE" ]
    then
        echo "!!! Remember to set the ERDDAP SMTP password in the ${MYDOCKER_ROOT_DIR}/customdocker/customvolumes/erddapContent/setup.xml file."
    fi
fi
###
