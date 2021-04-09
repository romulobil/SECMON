import os, subprocess
from time import sleep
print("| SECMON - DockerAutoInstall |")
print("1. Certificate : ")
print("Note 1 : You can delete this self signed cert and put your CA signed cert after install. ")
sleep(2)
print("Note 2 : Don't forget to enter a good value for CN (FQDN of your server)")
sleep(2)
os.system("openssl req -newkey rsa:4096 -x509 -sha512 -days 3650 -nodes -out secmon.crt -keyout secmon.key")
print("Your certificate is available on /etc/ssl/secmon ! ")
print("----------------------------------------------------------------------------------------------------------------------")
print("2. SECMON Install : ")
sender = input("Sender email address :")
password = input("Sender email account password :") 
smtpsrv = input("SMTP Server FQDN or IP :") 
smtpport = input("SMTP used port :") 
tls = input("Using TLS SMTP auth ? (yes/no) :")
lang = input("Language (en/fr) :")
receivers = input("SECMON email receivers (single or many seperated by ;):")
os.system(f"chown -R www-data:www-data /var/www/secmon && chmod -R 744 /var/www/secmon")
os.system(f"python3 /var/www/secmon/setup.py -sender {sender} -p '{password}' -server {smtpsrv} -port {smtpport} -tls {tls} -lang {lang} -r {receivers}")
print("Executing secmon in background...")
os.system("nohup python3 /var/www/secmon/secmon.py >/dev/null 2>&1 &")
print("Executing cve_updater in background...")
os.system("nohup python3 /var/www/secmon/cve_updater.py >/dev/null 2>&1 &")
print("SECMON is successfully installed and configured !")
print("----------------------------------------------------------------------------------------------------------------------")
print("3. Apache configuration : ")
fqdn = input("Enter the FQDN of the web server :")
f = open("/var/www/secmon/docker/secmon.conf").read()
content = f.replace("{FQDN}",fqdn)
f = open("/etc/apache2/sites-enabled/secmon.conf","w")
f.write(content)
f.close()
os.system("a2enmod ssl && service apache2 restart")
print("Apache is successfully configured !")
print("You can now access the web interface at the following address: https://$fqdn")
print("----------------------------------------------------------------------------------------------------------------------")