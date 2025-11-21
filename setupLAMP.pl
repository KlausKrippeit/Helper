#!/usr/bin/perl
use strict;
use warnings;

# Farben
sub green { "\e[32m$_[0]\e[0m" }
sub yellow { "\e[33m$_[0]\e[0m" }

print green("=== Symfony 6.4 Server Setup (Debian Standard PHP) ===\n\n");

# 1️⃣ PHP 8.1 installieren (Debian Standard-Repo)
print yellow(">>> PHP 8.1 + FPM und benötigte Pakete installieren...\n");

system("sudo apt update -y");
system("sudo apt install -y php php-fpm php-cli php-mbstring php-intl php-xml php-curl php-zip php-gd php-bcmath php-mysql") == 0
    or die "PHP Pakete konnten nicht installiert werden!\n";

# 2️⃣ Redis
print yellow(">>> Redis installieren...\n");
system("sudo apt install -y redis-server php-redis") == 0
    or die "Redis konnte nicht installiert werden!\n";

# 3️⃣ Supervisor
print yellow(">>> Supervisor installieren...\n");
system("sudo apt install -y supervisor") == 0
    or die "Supervisor konnte nicht installiert werden!\n";

# 4️⃣ Apache2
print yellow(">>> Apache2 installieren...\n");
system("sudo apt install -y apache2 libapache2-mod-fcgid") == 0
    or die "Apache2 konnte nicht installiert werden!\n";

# Apache Modul für PHP-FPM aktivieren
system("sudo a2enmod proxy_fcgi setenvif") == 0;
system("sudo a2enconf php-fpm") == 0;

# 5️⃣ Composer
print yellow(">>> Composer installieren...\n");
system("curl -sS https://getcomposer.org/installer | php") == 0
    or die "Composer Installer fehlgeschlagen!\n";
system("sudo mv composer.phar /usr/local/bin/composer");
system("composer --version");

# 6️⃣ MariaDB
print yellow(">>> MariaDB installieren...\n");
system("sudo apt install -y mariadb-server mariadb-client") == 0
    or die "MariaDB konnte nicht installiert werden!\n";

print "\n--- MariaDB Setup ---\n";
print "Datenbankname: ";
chomp(my $dbname = <STDIN>);

print "DB Benutzername: ";
chomp(my $dbuser = <STDIN>);

print "DB Passwort: ";
chomp(my $dbpass = <STDIN>);

# Datenbank und User erstellen
my $create_db = qq{sudo mysql -e "CREATE DATABASE $dbname CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"};
my $create_user = qq{sudo mysql -e "CREATE USER '$dbuser'\@'localhost' IDENTIFIED BY '$dbpass';"};
my $grant_privs = qq{sudo mysql -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'\@'localhost';"};
my $flush = qq{sudo mysql -e "FLUSH PRIVILEGES;"};

system($create_db) == 0 or die "Datenbank konnte nicht erstellt werden!\n";
system($create_user) == 0 or die "User konnte nicht erstellt werden!\n";
system($grant_privs) == 0 or die "Rechte konnten nicht vergeben werden!\n";
system($flush) == 0 or die "Privileges Flush fehlgeschlagen!\n";

# 7️⃣ Apache vhost interaktiv
print "\n--- Apache VirtualHost Setup ---\n";
print "Domainname / Projektname: ";
chomp(my $domain = <STDIN>);

my $vhost_file = "/etc/apache2/sites-available/$domain.conf";
open my $fh, ">", $vhost_file or die "Konnte $vhost_file nicht schreiben!\n";

print $fh <<"EOF";
<VirtualHost *:80>
    ServerName $domain
    DocumentRoot /var/www/$domain/public

    <Directory /var/www/$domain/public>
        AllowOverride All
        Require all granted
    </Directory>

    <FilesMatch \.php\$>
        SetHandler "proxy:unix:/run/php/php8.1-fpm.sock|fcgi://localhost/"
    </FilesMatch>

    ErrorLog \${APACHE_LOG_DIR}/$domain-error.log
    CustomLog \${APACHE_LOG_DIR}/$domain-access.log combined
</VirtualHost>
EOF

close($fh);

system("sudo a2ensite $domain") == 0;
system("sudo systemctl reload apache2") == 0;

print green("\n=== Setup abgeschlossen! ===\n");
print "Apache vhost: $vhost_file\n";
print "Datenbank: $dbname, Benutzer: $dbuser\n";
print "Symfony 6.4 ready, PHP 8.1, Redis, Supervisor, Composer installiert.\n";
