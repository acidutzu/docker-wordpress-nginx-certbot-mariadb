
#!/bin/bash

read -p 'Root domain (ex: matrix.org without the www subdomain): ' domain
[ -z $domain ] && echo "Domain name cannot be empty" && exit 1

read -p 'Email address for registration and recovery with EFF: ' email
[ -z $email ] && echo "Email field cannot be empty" && exit 1

# Generate an NGINX config with the given domain
[ -f ./nginx-conf/nginx.conf-sample ] && cat ./nginx-conf/nginx.conf-sample | sed "s/ROOT_DOMAIN/$domain/" > ./nginx-conf/nginx.conf

docker-compose up -d

# Create a dummy TLS certificate and private key and restart NGINX to load the dummy certificate
dirname=$(echo $(basename $(pwd)) | sed "s/\.//")
path=/var/lib/docker/volumes/${dirname}_certbot/_data/live/$domain/
mkdir -p $path && openssl req -x509 -nodes -newkey rsa:4096 -days 365 -keyout ${path}privkey.pem -out ${path}fullchain.pem -subj '/CN=localhost'
docker-compose restart nginx

########## Remove the dummy certificate and private key before requesting a signed TLS certificate with Certbot
rm -r $(dirname $path)

######### Request a signed TLS certificate with Certbot and restart NGINX to load the new certificate
docker-compose run --rm --entrypoint "certbot certonly --webroot --webroot-path=/var/www/html --email $email --agree-tos --eff-email --force-renewal -d $domain" certbot
docker-compose restart nginx

# systemctl enable docker
