FROM ubuntu
EXPOSE 80
RUN apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y nginx curl python2.7 python-minimal build-essential python2.7-dev uwsgi-plugin-python && \
  cd /tmp && \
  curl -O https://bootstrap.pypa.io/get-pip.py && \
  python2.7 get-pip.py && \
  pip install awscli flask uwsgi && \
  rm -rf /tmp/* && \
  rm -rf /var/lib/apt/lists/*
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./cats_uwsgi.ini /etc/uwsgi/apps-enabled/cats_uwsgi.ini
COPY ./index.html /var/www/html/index.html
COPY ./app.js /var/www/html/app.js
COPY ./cats-api.py /var/www/html/cats-api.py
#COPY ./default.conf /etc/nginx/conf.d/default.conf
#COPY ./index.html /usr/share/nginx/html/index.html
#COPY ./app.js /usr/share/nginx/html/app.js
COPY ./init.sh /tmp/init.sh
RUN mkdir /var/log/uwsgi
RUN chmod +x /tmp/init.sh
CMD  /tmp/init.sh && uwsgi --ini /etc/uwsgi/apps-enabled/cats_uwsgi.ini --daemonize=/var/log/uwsgi/buzzy.log && nginx -g "daemon off;"