# DOCKER DEPLOY
You can deploy the basic structure of environment using the script `docker-EnvCreation.sh`.  
The enviroment created contains: 
  
* ERDDAP container - Exposed on port set with the variable `MYDOCKER_HOST_ERDDAP_PORT`. Now it's set to 12081.
* data directory - This directory on the host could have data that will be accessible from the ERDDAP container.
* ERDDAP Data directory - This is the directory on the host where are ERDDAP Data files (cache, logs, etc...).
* ERDDAP Content directory - This is the directory on the host where are ERDDAP Content files (configuration files).
* Apache default website - In this web site is set the proxy that forward request to ERDDAP container from the location `/erddap`.
  
WARNING: This script doesn't do any check of the variables content. So be careful when you change their value.

## Prerequisites
* Host OS - Centos (see NOTE section for other Linux OS).
* `${ERDDAP_user}` - GID=UID=2021 - the user defined in the `${ERDDAP_user}` environment variable must exist on the host with GID=UID=2021. `${ERDDAP_user}` must have reading permission on `${MYDOCKER_DATA_DIR}` directory
* UID=2020, GUID=2020 - On the host they must be free, because is used for the new host user *usrtomcat*.
* `${MYDOCKER_ROOT_DIR}/opt` - Will be the folder where are created all the deployement directories.
* Host port `MYDOCKER_HOST_ERDDAP_PORT` is usable - It will be used from the ERDDAP container. It will forward request to the ERDDAP container port 8080. By default is set to 12081.
* Access to the *root* user
* Docker must be already installed
* Apache installed with proxy, proxy_http, rewrite, ssl and headers modules enabled.

## HOW TO USE
1. Login as *root* user.
2. Copy al the content from this repository in any folder of the host. For example `/root/deploy`. 
Download link: https://bitbucket.org/ettnewmedia/nautilos-docker/get/90445fe16a66.zip
3. Enter in the directory with the `docker-EnvCreation.sh` file.
4. Customize the configuration in the `docker-EnvCreationVariable.sh` file. The minimal changes you have to do are:
    1. `ERDDAP_user`
    2. `MYDOCKER_DATA_DIR`
    3. `APACHE_DOMAIN_ROOT`
    4. `ERDDAP_emailEverythingTo`
    5. `ERDDAP_admin*` - Use the *@* only in the email fields.
    6. `ERDDAP_flagKeyKey` - Do no use the *@* char
5. Give the permissions *Excute* (chmod +x) to `docker-EnvCreation.sh` file.
6. Run `docker-EnvCreation.sh` and follow instruction on terminal.

## NOTE
### To execute GenerateDatasetsXml
docker exec -it erddap-docker_erddap_1 bash -c "cd webapps/erddap/WEB-INF/ && bash GenerateDatasetsXml.sh -verbose"

In the docker image the `MYDOCKER_DATA_DIR` is mounted in the `/Data/` path

### OS other than CentOS
#### SELinux
For OS that doesn't have se SELinux, from `docker-EnvCreation.sh` remove the lines 

    # Only fot RedHat-like distribution - Set direcotries context
    semanage fcontext -a -t container_file_t "${MYDOCKER_ROOT_DIR}/opt/customdocker/customvolumes(/.*)?"
    semanage fcontext -a -t container_share_t "${MYDOCKER_ROOT_DIR}/opt/customdocker/deployfiles(/.*)?"
    restorecon -RF ${MYDOCKER_ROOT_DIR}/opt/customdocker

#### Apache
Remember to change  
  
* the `APACHE_SITE_CONF_DIR` variable to match where are deployed the Apache vhosts.
* the `APACHE_SERVICE_NAME`variable to match the Apache service name.

## TROUBLESHOOT
### Apache - Website not accessible
Check if the vhost is loaded correctly. If there are other vhost, maybe they have the same domain or IPv4.

