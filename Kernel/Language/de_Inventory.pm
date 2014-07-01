# --
# Kernel/Language/de_Inventory.pm - german translation for Inventory frontend module
# Copyright (C) (2014) (Denny Bresch) (dennybresch@gmail.com) (https://github.com/dennybresch)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --


package Kernel::Language::de_Inventory;

use strict;
use warnings;

sub Data {
    my $Self = shift;

# Configuration
    $Self->{Translation}->{''} = '';


	
	

# Inventory
	$Self->{Translation}->{'Filter for Object'} = 'Filter nach Objekt';
	$Self->{Translation}->{'Type'} = 'Typ';
	$Self->{Translation}->{'Model'} = 'Modell';
	$Self->{Translation}->{'Manufacturer'} = 'Hersteller';
	$Self->{Translation}->{'Serialnumber'} = 'Seriennummer';
	$Self->{Translation}->{'Purchase Time'} = 'Anschaffung';
	$Self->{Translation}->{'create time'} = 'Erstelldatum';
	$Self->{Translation}->{'created by'} = 'erstellt durch';
	$Self->{Translation}->{'change time'} = 'Änderungsdatum';
	$Self->{Translation}->{'change by'} = 'geändert durch';
	$Self->{Translation}->{'Add Object'} = 'Objekt hinzufügen';
	$Self->{Translation}->{'Type of the object.'} = 'Art des Objektes.';
	$Self->{Translation}->{'Model is the Version of the Object.'} = 'Modell ist die Version des Objektes.';	
	$Self->{Translation}->{'Company that manufactures a particular item.'} = 'Unternehmen, das einen bestimmten Artikel herstellt.';
	$Self->{Translation}->{'String that is a unique identifier of an object.'} = ' Zeichenfolge, die eine eindeutige Identifizierung eines Objekts ermöglicht.';
	$Self->{Translation}->{'Date of purchase'} = 'Kaufdatum';
    $Self->{Translation}->{'PurchaseTime'} = 'Kaufdatum';
    $Self->{Translation}->{''} = '';	
	

	
	
    $Self->{Translation}->{'additional values'} = 'weitere Werte';
    $Self->{Translation}->{''} = '';


    return 1;
}
1;
