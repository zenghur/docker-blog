FROM nginx:1.17.4
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./key.pem ./cert.pem /
COPY ./blog/public /blog
EXPOSE 80 443
