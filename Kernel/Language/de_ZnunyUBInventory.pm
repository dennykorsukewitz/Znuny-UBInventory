# --
# Copyright (C) (2014) (Denny Korsukéwitz) (https://github.com/dennykorsukewitz)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_ZnunyUBInventory;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;

    # Inventory
    $Self->{Translation}->{'Add Object'}          = 'Objekt hinzufügen';
    $Self->{Translation}->{'Edit Object'}         = 'Objekt bearbeiten';
    $Self->{Translation}->{'Filter for Object'}   = 'Filter nach Objekt';
    $Self->{Translation}->{'Type'}                = 'Typ';
    $Self->{Translation}->{'Model'}               = 'Modell';
    $Self->{Translation}->{'Manufacturer'}        = 'Hersteller';
    $Self->{Translation}->{'Serialnumber'}        = 'Seriennummer';
    $Self->{Translation}->{'Purchase Time'}       = 'Anschaffung';
    $Self->{Translation}->{'create time'}         = 'Erstelldatum';
    $Self->{Translation}->{'created by'}          = 'erstellt durch';
    $Self->{Translation}->{'change time'}         = 'Änderungsdatum';
    $Self->{Translation}->{'change by'}           = 'geändert durch';
    $Self->{Translation}->{'Type of the object.'} = 'Art des Objektes.';

    $Self->{Translation}->{'Model is the Version of the Object.'}              = 'Modell ist die Version des Objektes.';
    $Self->{Translation}->{'Company that manufactures a particular item.'}     = 'Unternehmen, das einen bestimmten Artikel herstellt.';
    $Self->{Translation}->{'String that is a unique identifier of an object.'} = 'Zeichenfolge, die eine eindeutige Identifizierung eines Objekts ermöglicht.';

    $Self->{Translation}->{'ID'}                   = 'UB-ID';
    $Self->{Translation}->{'Date of purchase'}     = 'Kaufdatum';
    $Self->{Translation}->{'PurchaseTime'}         = 'Kaufdatum';
    $Self->{Translation}->{'Segregation'}          = 'Aussonderung';
    $Self->{Translation}->{'Search for Object'}    = 'Suche nach Objekt';
    $Self->{Translation}->{'Actions'}              = 'Aktionen';
    $Self->{Translation}->{'Select Information'}   = 'Auswahlinformationen';
    $Self->{Translation}->{'selected key'}         = 'ausgewähltes Attribut';
    $Self->{Translation}->{'selected value'}       = 'ausgewählter Wert';
    $Self->{Translation}->{'count'}                = 'Anzahl';
    $Self->{Translation}->{'reset'}                = 'zurücksetzen';
    $Self->{Translation}->{'Room'}                 = 'Raum';
    $Self->{Translation}->{'Employee'}             = 'Mitarbeiter';
    $Self->{Translation}->{'ID'}                   = 'UB-ID';
    $Self->{Translation}->{'Distribution Cabinet'} = 'Verteilerschrank';
    $Self->{Translation}->{'KeyNr'}                = 'SchlüsselNr.';
    $Self->{Translation}->{'Socket'}               = 'Netzwerkdose';
    $Self->{Translation}->{'additional values'}    = 'weitere Werte';

    $Self->{Translation}->{'Use the comment field for some additional information.'} = 'Nutzen Sie das Kommentarfeld für weitere Informationen.';


    return 1;
}

1;
