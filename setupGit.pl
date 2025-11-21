#!/usr/bin/perl
use strict;
use warnings;

# Farben für Ausgabe
sub green { return "\e[32m$_[0]\e[0m"; }
sub yellow { return "\e[33m$_[0]\e[0m"; }

print green("=== Git Installation & Konfiguration Script ===\n\n");

# 1. Git installieren
print yellow(">>> Installiere Git...\n");
system("sudo apt update -y");
system("sudo apt install -y git bash-completion") == 0
    or die "Konnte Git nicht installieren!\n";

print green("Git wurde erfolgreich installiert.\n\n");

# 2. Prüfe Git-Version
system("git --version");

print "\n";

# 3. Benutzer fragen nach Konfiguration
print yellow(">>> Git Benutzer-Konfiguration:\n");

print "Git Benutzername: ";
chomp(my $name = <STDIN>);

print "Git Email-Adresse: ";
chomp(my $email = <STDIN>);

print "Default Branch (main/master)? [main]: ";
chomp(my $branch = <STDIN>);
$branch = $branch eq "" ? "main" : $branch;

print "Standard Editor (nano/vim/code)? [nano]: ";
chomp(my $editor = <STDIN>);
$editor = $editor eq "" ? "nano" : $editor;

print "\nGit farbig anzeigen? (y/n) [y]: ";
chomp(my $color = <STDIN>);
$color = $color eq "" ? "y" : $color;

# 4. Git konfigurieren
print yellow("\n>>> Setze globale Git-Konfiguration...\n");

system("git config --global user.name \"$name\"");
system("git config --global user.email \"$email\"");
system("git config --global init.defaultBranch \"$branch\"");
system("git config --global core.editor \"$editor\"");

if ($color =~ /^y/i) {
    system("git config --global color.ui auto");
    print "Farbiges UI aktiviert.\n";
}

# 5. Autovervollständigung einrichten
print yellow("\n>>> Aktiviere Bash-Autovervollständigung für Git...\n");

my $bashrc = $ENV{'HOME'} . "/.bashrc";

open(my $fh, ">>", $bashrc) or die "Kann .bashrc nicht schreiben!";
print $fh "\n# Git Autocompletion\n";
print $fh "[ -f /usr/share/bash-completion/completions/git ] && . /usr/share/bash-completion/completions/git\n";
close($fh);

print green("Git Autovervollständigung aktiviert.\n");

# 6. GPG-Signing optional aktivieren
print "\nGPG-Key automatisch zum Signieren verwenden? (y/n) [n]: ";
chomp(my $gpg = <STDIN>);
$gpg = "n" if $gpg eq "";

if ($gpg =~ /^y/i) {
    print "GPG-Key-ID eingeben (z. B. ABC12345): ";
    chomp(my $key = <STDIN>);
    if ($key ne "") {
        system("git config --global user.signingkey \"$key\"");
        system("git config --global commit.gpgsign true");
        print green("GPG-Signing aktiviert.\n");
    }
}

print green("\n=== Git Setup abgeschlossen! ===\n");
print "Bitte Terminal neu öffnen oder:\n";
print yellow("    source ~/.bashrc\n");
print "ausführen, damit Autovervollständigung aktiv wird.\n";
