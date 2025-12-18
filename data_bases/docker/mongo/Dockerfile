FROM mongo:7
COPY ./init/ /docker-entrypoint-initdb.d/
RUN chmod -R a+rX /docker-entrypoint-initdb.d

