FROM httpd:alpine3.15
ARG domain
ARG prefix="http://"
RUN test -n "$domain" || (echo "ERROR: domain is not set" && false)
COPY . /usr/local/apache2/htdocs/
RUN sed -i -e "s|{domain}|$domain|" -e "s|{PREFIX}|$prefix|" /usr/local/apache2/htdocs/msx/start.json
# CORS: Media Station X загружает start.json со своего домена — без этого заголовка будет "Failed to load"
RUN sed -i 's|^#LoadModule headers_module|LoadModule headers_module|' /usr/local/apache2/conf/httpd.conf \
 && printf '\n<IfModule headers_module>\n  Header always set Access-Control-Allow-Origin "*"\n  Header always set Access-Control-Allow-Headers "*"\n  Header always set Access-Control-Allow-Methods "GET, POST, OPTIONS"\n</IfModule>\n' >> /usr/local/apache2/conf/httpd.conf
