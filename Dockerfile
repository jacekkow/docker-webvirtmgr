FROM debian
MAINTAINER Jacek Kowalski <Jacek@jacekk.info>

RUN apt-get -y update \
	&& apt-get -y dist-upgrade \
	&& apt-get -y install git python-pip python-ldap \
		python-libvirt python-libxml2 sudo \
	&& apt-get -y clean

RUN git clone https://github.com/retspen/webvirtmgr /webvirtmgr

WORKDIR /webvirtmgr
RUN sed -i 's/127.0.0.1:8000/0.0.0.0:8000/' conf/gunicorn.conf.py \
	&& sed -i 's/^#django-auth/django-auth/' requirements.txt \
	&& pip install -r requirements.txt \
	&& cp webvirtmgr/local/local_settings.py.example webvirtmgr/
ADD local_settings.py.initial webvirtmgr/

RUN groupadd -r -g 500 webvirtmgr \
	&& useradd -r -d /webvirtmgr -u 500 -g 500 webvirtmgr \
	&& chown -Rf webvirtmgr:webvirtmgr /webvirtmgr

VOLUME /webvirtmgr/webvirtmgr/local
EXPOSE 8000
ADD run.sh run-sudo.sh /
CMD /run.sh
