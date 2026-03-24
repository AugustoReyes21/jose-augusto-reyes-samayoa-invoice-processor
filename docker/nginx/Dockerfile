FROM nginx:1.27-alpine

RUN apk add --no-cache openssl

COPY docker/nginx/start.sh /opt/start.sh

CMD ["/bin/sh", "/opt/start.sh"]
