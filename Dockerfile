FROM nginx:1.17.4
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./blog/public /blog
