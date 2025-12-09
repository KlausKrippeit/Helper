<?php
// countdown.php
// Usage: php countdown.php START(HH:MM) DURATION(HH:MM)
// php countdown.php 14:20 01:15

if ($argc !== 3) {
    fwrite(STDERR, "Benutzung: php {$argv[0]} START(HH:MM) DAUER(HH:MM)\n");
    exit(2);
}

$startArg = $argv[1];
$durArg   = $argv[2];

// Prüfen: Format HH:MM
if (!preg_match('/^(\d{1,2}):([0-5][0-9])$/', $startArg, $m)) {
    fwrite(STDERR, "Ungültiges START-Format. Erwartet HH:MM\n");
    exit(2);
}
list(, $sh, $sm) = $m;

if (!preg_match('/^(\d{1,2}):([0-5][0-9])$/', $durArg, $n)) {
    fwrite(STDERR, "Ungültiges DAUER-Format. Erwartet HH:MM\n");
    exit(2);
}
list(, $dh, $dm) = $n;

// Zeitzone auf Berlin setzen
date_default_timezone_set('Europe/Berlin');

try {
    // Jetzt in Berlin
    $now = new DateTimeImmutable('now', new DateTimeZone('Europe/Berlin'));

    // Startzeit: heute mit den angegebenen Stunden/Minuten
    $startTodayStr = $now->format('Y-m-d') . sprintf(" %02d:%02d:00", $sh, $sm);
    $start = new DateTimeImmutable($startTodayStr, new DateTimeZone('Europe/Berlin'));

    // Wenn Start in der Vergangenheit -> nächsten Tag
    //if ($start <= $now) {
    //    $start = $start->add(new DateInterval('P1D'));
    //}

    // Dauer als DateInterval
    $durSpec = 'PT' . intval($dh) . 'H' . intval($dm) . 'M';
    $duration = new DateInterval($durSpec);

    // Zielzeit
    $target = $start->add($duration);

    // Ausgabe
    echo "Zeitzone: Europe/Berlin\n";
    echo "Aktuell:  " . $now->format('H:i:s') . "\n";
    echo "Start:    " . $start->format('H:i:s') . "\n";
    echo "Ziel:     " . $target->format('H:i:s') . "\n\n";

    // Falls Start in Zukunft: warten (mit Anzeige)
    $now2 = new DateTimeImmutable('now', new DateTimeZone('Europe/Berlin'));
    if ($now2 < $start) {
        echo "Warte bis Startzeit erreicht ist...\n";
        while (true) {
            $now2 = new DateTimeImmutable('now', new DateTimeZone('Europe/Berlin'));
            $remaining = $start->getTimestamp() - $now2->getTimestamp();
            if ($remaining <= 0) {
                break;
            }
            $h = intdiv($remaining, 3600);
            $m = intdiv($remaining % 3600, 60);
            $s = $remaining % 60;
            printf("\rBis Start verbleibend: %02d:%02d:%02d ", $h, $m, $s);
            fflush(STDOUT);
            sleep(1);
 }
        echo "\nStartzeit erreicht. Countdown startet...\n";
    } else {
        echo "\n";
    }

    // Countdown bis Ziel
    while (true) {
        $now3 = new DateTimeImmutable('now', new DateTimeZone('Europe/Berlin'));
        $remaining = $target->getTimestamp() - $now3->getTimestamp();
        if ($remaining <= 0) {
            break;
        }
        $h = intdiv($remaining, 3600);
        $m = intdiv($remaining % 3600, 60);
        $s = $remaining % 60;

        $timeS = $now3->format('H:i:s');
        printf("\rTime: %s: Counter: %02d:%02d:%02d ", $timeS, $h, $m, $s);

        fflush(STDOUT);
        sleep(1);
    }

    echo "\n\nFertig!\n";
    exit(0);

} catch (Exception $e) {
    fwrite(STDERR, "Fehler: " . $e->getMessage() . "\n");
    exit(1);
}
    
