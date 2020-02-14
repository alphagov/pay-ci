FROM fluent/fluentd:latest

RUN apk add --no-cache --update --virtual .build-deps \
        sudo build-base ruby-dev \
 && sudo gem install fluent-plugin-splunk-hec \
 && sudo gem sources --clear-all \
 && apk del .build-deps \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

WORKDIR /app
COPY ./fluent_template.conf /app
COPY ./docker-startup.sh /app
RUN chmod +x /app/docker-startup.sh
EXPOSE 9880
ENV PORT 9880

CMD ["/bin/sh","-c","/app/docker-startup.sh"]


