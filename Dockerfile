FROM python:2-alpine3.6

ENV PYTHONDONTWRITEBYTECODE=1

ARG PGADMIN_VERSION=2.0
ARG PGADMIN_SHA256=96b63080bbd50e92f9c6713885ed5b3a51248a98116cb26644db42d2c225e92c

# Install postgresql tools for backup/restore
RUN apk add --no-cache postgresql \
 && cp /usr/bin/psql /usr/bin/pg_dump /usr/bin/pg_dumpall /usr/bin/pg_restore /usr/local/bin/ \
 && apk del postgresql

RUN addgroup -g 50 -S pgadmin \
 && adduser -D -S -h /pgadmin -s /sbin/nologin -u 1000 -G pgadmin pgadmin \
 && mkdir -p /pgadmin/config /pgadmin/storage \
 && chown -R 1000:50 /pgadmin

RUN echo curl https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v${PGADMIN_VERSION}/pip/pgadmin4-${PGADMIN_VERSION}-py2.py3-none-any.whl \
 && apk add --no-cache alpine-sdk postgresql-dev curl \
 && pip install --upgrade pip \
 && curl https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v${PGADMIN_VERSION}/pip/pgadmin4-${PGADMIN_VERSION}-py2.py3-none-any.whl > /tmp/pgadmin4-${PGADMIN_VERSION}-py2.py3-none-any.whl \
 && sha256sum /tmp/pgadmin4-${PGADMIN_VERSION}-py2.py3-none-any.whl | grep -q ${PGADMIN_SHA256} \
 && pip install --no-cache-dir /tmp/pgadmin4-${PGADMIN_VERSION}-py2.py3-none-any.whl \
 && rm /tmp/pgadmin4-${PGADMIN_VERSION}-py2.py3-none-any.whl  \
 && apk del alpine-sdk curl

EXPOSE 5050

COPY LICENSE config_distro.py /usr/local/lib/python2.7/site-packages/pgadmin4/

USER pgadmin:pgadmin
CMD ["python", "./usr/local/lib/python2.7/site-packages/pgadmin4/pgAdmin4.py"]
VOLUME /pgadmin/
