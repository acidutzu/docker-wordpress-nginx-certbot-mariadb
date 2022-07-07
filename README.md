## ---=== Birth of a website LAMP server ===---

                          
                               
                               
                               
                               
                               
## REQUIREMENTS:

- a raspberry pi 4
- a microSD card 32GB
- rpi-imager for PC (to write microSD for the raspberry pi)


- open rpi-imager:
    – chose user and password to be added on your linux instalation from rpi-imager tool
    – enable SSH for the linux instalation from the rpi-imager tool
    - debian bullseye server linux chosen with the help of rpi-imager GUI tool (no monitor or keyboard/mouse with raspberry, just the LAN cable, all it will be done trough SSH cli tool )
after the microSD card is flashed with a linux using rpi-imager, plug it into raspberry pi and power ON
connect via SSH into raspberry pi ( you can find raspberry pi IP into your router at DHCP Clients )

## Install docker and docker-compose :

i like this 3 commands to do that:
```
 curl -fsSL https://get.docker.com -o get-docker.sh
 sudo sh get-docker.sh
 sudo apt install docker-compose
 ```
- a domain name is needed for the website (digi offers a free one):
    – go to https://www.digi.ro/ (contul meu digi)
    – login and then go to:
        – Serviciile mele:
            – Internet:
                – DNS dinamic
                    – chose a domain name (in my case is devop.go.ro and hit Salveaza )

- shutdown the router and plug it back in ( it needs to see wan link down completely )
make sure that ports 80 and 443 are opened (forwarded ) for the raspberry pi IP from the router otherwise the INSTALLATION Scenario 1 will not work, Let`s Encrypt needs to “see” those ports opened

## INSTALLATION

commands:
```
mkdir website
cd website
git clone https://github.com/acidutzu/docker-wordpress-nginx-certbot-mariadb.git
cd docker-wordpress-nginx-certbot-mariadb
sudo sh runFirst-certbot-tls.sh 
```

## Scenario 1
- you will be prompted to enter a domain name and an email, youll need to enter the domain name that you have chosen from the https://www.digi.ro/ or a domain name that you have registered from elsewhere, in my case when prompted I enter devop.go.ro without http or https or www - this prompt is an automatic way to get an Lets Encrypt https certification for your domain name

- the https DNS challange certificate is valid for 3 months but it will automaticaly renew itself, thanks to the command:
entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'"
from the docker-compose.yml file, sleep 12h can be changed to your needs.
-----------------------------------------------------------------------------------------

## Scenario 2
- if you do not want a Lets Encrypt certificate yet, but just wanna test the website, then comment the folowing lines from the file: runFirst-certbot-tls.sh | a self signed certificate will be issued, but if you choose this "Scenario" then when prompted to enter a domain name, enter the local IP of the raspberry pi for example: 192.168.1.234, in this way you`ll be able to access the website at https://192.168.1.234

so then to edit runFirst-certbot-tls.sh run this command:
```
nano runFirst-certbot-tls.sh
and comment :
#rm -r $(dirname $path)

#docker-compose run --rm --entrypoint "certbot certonly --webroot --webroot-path=/var/www/html --email $email --agree-tos --eff-email --force-renewal -d $domain" certbot
#docker-compose restart nginx                               
```

