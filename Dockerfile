FROM balenalib/nuc-node:0.10.22-wheezy

# Enable systemd
ENV INITSYSTEM on

# versions
ENV PROMETHEUS_VERSION 0.20.0
ENV ALERTMANAGER_VERSION 0.2.0
# arch
ENV DIST_ARCH linux-amd64

# Target discovery configs
ENV RESIN_EMAIL en.mouna@gmail.com
ENV RESIN_PASS mouna1991
ENV RESIN_APP_NAME test123
ENV DISCOVERY_INTERVAL 30000

# Alert Manager configs
ENV GMAIL_ACCOUNT en.mouna@gmail.com
ENV GMAIL_AUTH_TOKEN eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTM0MjYxLCJ1c2VybmFtZSI6ImdfbW91bmFfYm91anJhZCIsImVtYWlsIjoiZW4ubW91bmFAZ21haWwuY29tIiwiY3JlYXRlZF9hdCI6IjIwMTktMTAtMzFUMTE6MDY6MzQuNjg2WiIsImp3dF9zZWNyZXQiOiJUTUdZSE83N0xKSERKUzdBUFYySkdSVURYTENJN01NRSIsImhhc19kaXNhYmxlZF9uZXdzbGV0dGVyIjpmYWxzZSwiZmlyc3RfbmFtZSI6Im1vdW5hIiwibGFzdF9uYW1lIjoiYm91anJhZCIsImFjY291bnRfdHlwZSI6InBlcnNvbmFsIiwic29jaWFsX3NlcnZpY2VfYWNjb3VudCI6W3siY3JlYXRlZF9hdCI6IjIwMTktMTAtMzFUMTE6MDY6MzQuNjg2WiIsImlkIjo0MDUxMSwiYmVsb25nc190b19fdXNlciI6eyJfX2RlZmVycmVkIjp7InVyaSI6Ii9yZXNpbi91c2VyKDEzNDI2MSkifSwiX19pZCI6MTM0MjYxfSwicHJvdmlkZXIiOiJnb29nbGUiLCJyZW1vdGVfaWQiOiIxMTY5NzI1MzQ4NDYyMDYyNzgyODYiLCJkaXNwbGF5X25hbWUiOiJtb3VuYSBib3VqcmFkIiwiX19tZXRhZGF0YSI6eyJ1cmkiOiIvcmVzaW4vc29jaWFsX3NlcnZpY2VfYWNjb3VudChAaWQpP0BpZD00MDUxMSJ9fV0sImNvbXBhbnkiOiJub25lIiwiaGFzUGFzc3dvcmRTZXQiOmZhbHNlLCJuZWVkc1Bhc3N3b3JkUmVzZXQiOmZhbHNlLCJwdWJsaWNfa2V5Ijp0cnVlLCJmZWF0dXJlcyI6W10sImludGVyY29tVXNlck5hbWUiOiJnX21vdW5hX2JvdWpyYWQiLCJpbnRlcmNvbVVzZXJIYXNoIjoiNjRiOThiZmU3Njk2NjM0NDFlYTY2OGY4NDQ5NDNkNjM0YzFmMTBlYjY5OTczNzJiNWIzMWE5MzdiMmQwNTU2MyIsInBlcm1pc3Npb25zIjpbXSwiYXV0aFRpbWUiOjE1NzI1Mzc0MTEyNDcsImFjdG9yIjo0MTU0NzkzLCJpYXQiOjE1NzMxNDA5OTAsImV4cCI6MTU3Mzc0NTc5MH0.-7MEVvAHiB3CzvKZoCPi5Tit5rmJMc6YBPLApRH07P0
ENV THRESHOLD_CPU 50
ENV THRESHOLD_FS 50
ENV THRESHOLD_MEM 500
ENV STORAGE_LOCAL_RETENTION 360h0m0s

VOLUME ["/var/lib/grafana"]

EXPOSE 3000 80

RUN apt-get update && apt-get install apt-transport-https
RUN echo 'deb https://packagecloud.io/grafana/stable/debian/ wheezy main' >> /etc/apt/sources.list
RUN curl https://packagecloud.io/gpg.key | sudo apt-key add -

# downloading utils
RUN apt-get update && apt-get install -y wget build-essential libc6-dev grafana

WORKDIR /etc

# get prometheus server
RUN wget https://github.com/prometheus/prometheus/releases/download/$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.$DIST_ARCH.tar.gz  \
	&& tar xvfz prometheus-$PROMETHEUS_VERSION.$DIST_ARCH.tar.gz \
	&& rm prometheus-$PROMETHEUS_VERSION.$DIST_ARCH.tar.gz

# get prometheus alertmanager
RUN wget https://github.com/prometheus/alertmanager/releases/download/$ALERTMANAGER_VERSION/alertmanager-$ALERTMANAGER_VERSION.$DIST_ARCH.tar.gz  \
	&& tar xvfz alertmanager-$ALERTMANAGER_VERSION.$DIST_ARCH.tar.gz \
	&& rm alertmanager-$ALERTMANAGER_VERSION.$DIST_ARCH.tar.gz

# add discovery service
COPY discovery/ ./prometheus-$PROMETHEUS_VERSION.$DIST_ARCH/discovery/

RUN cd prometheus-$PROMETHEUS_VERSION.$DIST_ARCH/discovery && npm install

# Add config files
COPY config/ ./config/

# move all config files into place and insert config vars
RUN bash /etc/config/config.sh

WORKDIR /

COPY start.sh ./

CMD ["bash", "start.sh"]
