###
# Dockerfile for Tomcat.
###
FROM tomcat:10.1.0-jdk17-openjdk AS customtomcat

###
# Usual maintenance, including gosu installation.
# gosu is a non-optimal way to deal with the mismatches between Unix user and
# group IDs inside versus outside the container resulting in permission
# headaches when writing to directory outside the container.
###
RUN apt-get update && \
    apt-get install -y \
        gosu \
        zip \
        && \
    ###
    # Cleanup apt
    ###
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    ###
    # Eliminate default web applications
    ###
    rm -rf ${CATALINA_HOME}/webapps/* && \
    rm -rf ${CATALINA_HOME}/server/webapps/* && \
    ###
    # Obscuring server info
    ###
    cd ${CATALINA_HOME}/lib && \
    mkdir -p org/apache/catalina/util/ && \
    unzip -j catalina.jar org/apache/catalina/util/ServerInfo.properties \
        -d org/apache/catalina/util/ && \
    sed -i 's/server.info=.*/server.info=Apache Tomcat/g' \
        org/apache/catalina/util/ServerInfo.properties && \
    zip -ur catalina.jar \
        org/apache/catalina/util/ServerInfo.properties && \
    rm -rf org && cd ${CATALINA_HOME} && \
    ###
    # Setting restrictive umask container-wide
    ###
    echo "session optional pam_umask.so" >> /etc/pam.d/common-session && \
    sed -i 's/UMASK.*022/UMASK           007/g' /etc/login.defs

###
# Security enhanced web.xml
###
COPY TOMCAT/web.xml ${CATALINA_HOME}/conf/

###
# Security enhanced server.xml
###
COPY TOMCAT/server.xml ${CATALINA_HOME}/conf/

COPY TOMCAT/context.xml ${CATALINA_HOME}/conf/

###
# Tomcat start script
###
COPY TOMCAT/start-tomcat.sh ${CATALINA_HOME}/bin
COPY TOMCAT/entrypoint.sh /

###
# Start container
###
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start-tomcat.sh"]



###
# Dockerfile for ERDDAP.
###
FROM customtomcat
LABEL maintainer="Marco Alba <marco.alba@ettsolutions.com>"

ARG ERDDAP_VERSION=2.21
ARG ERDDAP_CONTENT_URL=https://github.com/BobSimons/erddap/releases/download/v$ERDDAP_VERSION/erddapContent.zip
ARG ERDDAP_WAR_URL=https://github.com/BobSimons/erddap/releases/download/v$ERDDAP_VERSION/erddap.war
ENV ERDDAP_bigParentDirectory /erddapData

RUN apt-get update && \
    apt-get install -y \
        unzip \
        xmlstarlet \
        git \
        maven \
        unzip \
    && if ! command -v gosu &> /dev/null; then apt-get install -y gosu; fi \
    && rm -rf /var/lib/apt/lists/*

ARG BUST_CACHE=1
RUN \
    curl -fSL "${ERDDAP_CONTENT_URL}" -o /erddapContent.zip && \
    unzip /erddapContent.zip -d ${CATALINA_HOME} && \
    rm /erddapContent.zip && \
    curl -fSL "${ERDDAP_WAR_URL}" -o /erddap.war && \
    unzip /erddap.war -d ${CATALINA_HOME}/webapps/erddap/ && \
    rm /erddap.war && \
    sed -i 's#</Context>#<Resources cachingAllowed="true" cacheMaxSize="100000" />\n&#' ${CATALINA_HOME}/conf/context.xml && \
    rm -rf /tmp/* /var/tmp/* && \
    mkdir -p ${ERDDAP_bigParentDirectory}

# Java options
COPY ERDDAP/setenv.sh ${CATALINA_HOME}/bin/setenv.sh

# Default configuration
ENV ERDDAP_baseHttpsUrl="http://localhost:8080" \
    ERDDAP_flagKeyKey="73976bb0-9cd4-11e3-a5e2-0800200c9a66" \
    ERDDAP_emailEverythingTo="nobody@example.com" \
    ERDDAP_emailDailyReportsTo="nobody@example.com" \
    ERDDAP_emailFromAddress="nothing@example.com" \
    ERDDAP_emailUserName="" \
    ERDDAP_emailPassword="" \
    ERDDAP_emailProperties="" \
    ERDDAP_emailSmtpHost="" \
    ERDDAP_emailSmtpPort="" \
    ERDDAP_adminInstitution="Axiom Docker Install" \
    ERDDAP_adminInstitutionUrl="https://github.com/axiom-data-science/docker-erddap" \
    ERDDAP_adminIndividualName="Axiom Docker Install" \
    ERDDAP_adminPosition="Software Engineer" \
    ERDDAP_adminPhone="555-555-5555" \
    ERDDAP_adminAddress="123 Irrelevant St." \
    ERDDAP_adminCity="Nowhere" \
    ERDDAP_adminStateOrProvince="AK" \
    ERDDAP_adminPostalCode="99504" \
    ERDDAP_adminCountry="USA" \
    ERDDAP_adminEmail="nobody@example.com"

COPY ERDDAP/entrypoint.sh /
COPY ERDDAP/datasets.d.sh /

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080
CMD ["catalina.sh", "run"]