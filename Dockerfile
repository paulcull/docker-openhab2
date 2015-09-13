# Openhab 2.0.0
# * configuration is injected
#
FROM java:8u66-jre
#MAINTAINER Marcus of Wetware Labs <marcus@wetwa.re>
MAINTAINER paulcull

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y unzip supervisor wget

ENV OPENHAB_VERSION SNAPSHOT 

#
# Download openHAB based on Environment OPENHAB_VERSION
#
COPY files/scripts/download_openhab.sh /root/docker-files/scripts/
RUN /root/docker-files/scripts/download_openhab.sh

#
# Download HABMIN
#
RUN echo "Download HABMin2"
RUN wget -q -P /opt/openhab/addons-available/addons/ https://github.com/cdjackson/HABmin2/releases/download/0.0.15/org.openhab.ui.habmin_2.0.0.SNAPSHOT-0.0.15.jar 

#
# Download Openhab 1.x dependencies
#
RUN echo "Download OpenHAB 1.x dependencies"
RUN wget -q -P /tmp/ https://openhab.ci.cloudbees.com/job/openHAB/lastStableBuild/artifact/distribution/target/distribution-1.8.0-SNAPSHOT-addons.zip && \
    wget -q -P /tmp/ https://openhab.ci.cloudbees.com/job/openHAB/lastStableBuild/artifact/distribution/target/distribution-1.8.0-SNAPSHOT-runtime.zip && \
    unzip -q /tmp/distribution-1.8.0-SNAPSHOT-addons.zip -d /opt/openhab/addons-available-oh1 && \
    unzip -j /tmp/distribution-1.8.0-SNAPSHOT-runtime.zip server/plugins/org.openhab.io.transport.mqtt* -d /opt/openhab/addons-available-oh1/  && \
    unzip -j /tmp/distribution-1.8.0-SNAPSHOT-runtime.zip configurations/openhab_default.cfg -d /opt/openhab/ && \
    rm -f /opt/openhab/runtime/server/plugins/org.openhab.io.transport.mqtt* && \
    rm /tmp/distribution-1.8.0-*

#RUN wget -q -P /opt/openhab/ https://raw.githubusercontent.com/openhab/openhab/master/distribution/openhabhome/configurations/openhab_default.cfg

#
# Setup other configuration files and scripts
#
COPY files/pipework /usr/local/bin/pipework
# non-openhab configs
COPY files/supervisord.conf /etc/supervisor/supervisord.conf
COPY files/openhab.conf /etc/supervisor/conf.d/openhab.conf
COPY files/openhab_debug.conf /etc/supervisor/conf.d/openhab_debug.conf
# start / stop scripts
COPY files/boot.sh /usr/local/bin/boot.sh
COPY files/openhab-restart /etc/network/if-up.d/openhab-restart
COPY files/start.sh /opt/openhab/
COPY files/start_debug.sh /opt/openhab/
#
# Fork specific changes
#
#COPY files/oh-configs/addons.cfg /etc/openhab/
#COPY files/oh-configs/addons-oh1.cfg /etc/openhab/
#COPY files/oh-configs/openhab.cfg /etc/openhab/services/openhab.cfg
#COPY files/oh-configs/timezone /etc/openhab/
COPY files/oh-configs/addons.cfg /etc/openhab/
COPY files/oh-configs/addons-oh1.cfg /etc/openhab/
COPY files/oh-configs/openhab.cfg /opt/openhab/services/openhab.cfg
COPY files/oh-configs/timezone /etc/openhab/

#RUN touch /opt/openhab/conf/DEMO_MODE 
RUN mkdir -p /opt/openhab/logs
RUN mkdir -p /opt/openhab/conf/persistence
RUN mkdir -p /opt/openhab/conf/items
RUN mkdir -p /opt/openhab/conf/rules
RUN mkdir -p /opt/openhab/conf/scripts
RUN mkdir -p /opt/openhab/conf/sitemaps
RUN mkdir -p /opt/openhab/conf/things

EXPOSE 8080 8443 5555 9001

CMD ["/usr/local/bin/boot.sh"]

