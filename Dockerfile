FROM httpd:alpine



ENV CGIT_TITLE="CGit"
ENV CGIT_DESC="The hyperfast web frontend for Git repositories"
ENV CGIT_VROOT="/"
ENV CGIT_SECTION_FROM_STARTPATH=0
ENV CGIT_MAX_REPO_COUNT=50



RUN apk add --no-cache ca-certificates tzdata sudo gettext dumb-init \
                       vim htop bash git curl \
                       xz zlib \
                       python3 py3-markdown py3-pygments \
                       cgit 

RUN mkdir -p /var/cache/cgit && chown www-data:www-data /var/cache/cgit
RUN mkdir -p /var/www/cgit   && chown www-data:www-data /var/www/cgit

COPY docker-entrypoint.sh /
COPY cgit-simple-authentication /opt/cgit-simple-authentication 
COPY scripts/* /usr/local/bin/

COPY cgitrc /tmp/cgitrc.tmpl    
COPY httpd.conf /usr/local/apache2/conf/httpd.conf

WORKDIR "/var/www/"

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD "httpd-foreground"


EXPOSE 80
