#!/bin/sh
rm -rf blog/public
cd blog && hugo && cd ..
cp ../key.pem ../cert.pem . && git pull origin master && docker build -t blog:dev ./ 
docker container stop myblog 
docker run -p 443:443 -p 80:80 --rm --name myblog -d blog:dev 
rm key.pem cert.pem
rm -rf blog/public

