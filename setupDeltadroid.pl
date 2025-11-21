#!/usr/bin/perl
use strict;
use warnings;
use File::Path qw(make_path);

my $user = "deltadroid";
my $home = "/home/$user";
my $ssh_dir = "$home/.ssh";
my $auth_keys = "$ssh_dir/authorized_keys";

# 1. Benutzer anlegen
print ">>> Erstelle Benutzer $user...\n";
system("id -u $user >/dev/null 2>&1") == 0 or
    system("useradd -m -s /bin/bash $user") == 0 or
    die "Konnte Benutzer nicht erstellen!\n";

# 2. SSH-Key von root kopieren
print ">>> Kopiere SSH-Key...\n";

if (! -d $ssh_dir) {
    make_path($ssh_dir) or die "Konnte $ssh_dir nicht erstellen!\n";
}

if (-f "/root/.ssh/authorized_keys") {
    system("cp /root/.ssh/authorized_keys $auth_keys") == 0
        or die "Konnte authorized_keys nicht kopieren!";
} else {
    die "Keine /root/.ssh/authorized_keys gefunden!\n";
}

# Berechtigungen setzen
system("chown -R $user:$user $home") == 0 or die "Chown fehlgeschlagen!";
system("chmod 700 $ssh_dir") == 0 or die "chmod 700 fehlgeschlagen!";
system("chmod 600 $auth_keys") == 0 or die "chmod 600 fehlgeschlagen!";

# 3. NOPASSWD Sudo einrichten
print ">>> Setze sudo NOPASSWD...\n";
my $sudo_file = "/etc/sudoers.d/$user";
open my $fh, ">", $sudo_file or die "Kann $sudo_file nicht schreiben!";
print $fh "$user ALL=(ALL) NOPASSWD:ALL\n";
close $fh;
system("chmod 440 $sudo_file") == 0 or die "chmod sudoers fehlgeschlagen!";

# 4. SSH neu laden
print ">>> Lade SSH neu...\n";
system("systemctl reload ssh") == 0 or die "SSH reload fehlgeschlagen!";

print "\nFERTIG! Benutzer $user ist eingerichtet.\n";
