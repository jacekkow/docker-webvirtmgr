#!/bin/bash

cd /webvirtmgr

python manage.py collectstatic --noinput

if [ ! -f "webvirtmgr/local/__init__.py" ]; then
	touch webvirtmgr/local/__init__.py
fi

if [ ! -f "webvirtmgr/local/local_settings.py" ]; then
	cp webvirtmgr/local_settings.py.initial webvirtmgr/local/local_settings.py
	cp webvirtmgr/local_settings.py.example webvirtmgr/local/
fi

INITIALIZE=0
if [ ! -f "webvirtmgr/local/webvirtmgr.sqlite3" ]; then
	INITIALIZE=1
fi

python manage.py syncdb --noinput

if [ $INITIALIZE -ne 0 ]; then
	echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@localhost', '1234')" | python manage.py shell
	touch webvirtmgr/local/webvirtmgr.sqlite3
fi

exec python manage.py run_gunicorn -c /webvirtmgr/conf/gunicorn.conf.py
