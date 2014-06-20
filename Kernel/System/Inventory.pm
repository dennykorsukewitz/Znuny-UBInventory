# --
# Kernel/System/Inventory.pm - core functions for Inventory frontend module
# Copyright (C) (2014) (Denny Bresch) (dennybresch@gmail.com) (https://github.com/dennybresch)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Inventory;

use strict;
use warnings;


sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless ($Self, $Type);
        
    # check needed objects
    for (qw(ParamObject DBObject TicketObject LayoutObject LogObject QueueObject ConfigObject EncodeObject MainObject TimeObject)) {
        if ( !$Self->{$_} ) {
            $Self->{$_} = $Param{$_} || die "Got no $_!";
        }
    }   


    return $Self;
}


sub GetInventoryList {
    my ( $Self, %Param ) = @_;

	my $SQL = "SELECT id  FROM inventory";

	
	if($Param{Limit}){
		$SQL .= " ORDER BY `id` DESC LIMIT $Param{Limit}";
	}
	
	# sql
    return if !$Self->{DBObject}->Prepare(
        SQL  => $SQL,        
    );
    
    my %InventoryList;
    while ( my @Row  = $Self->{DBObject}->FetchrowArray() ) {
        $InventoryList{ $Row[0] } = $Row[0];	            
    }
    return %InventoryList;
}

sub GetInventoryData {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ItemID} ) {
        $Self->{LogObject}->Log( Priority => 'error', Message => 'Need ItemID for GetInventoryData function.' );
        return;
    }

    # sql
    return if !$Self->{DBObject}->Prepare(
        SQL => 'SELECT * '
            . 'FROM inventory WHERE id = ?',
        Bind => [ \$Param{ItemID} ],
    );
    
    my %InventoryData;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        %InventoryData = (
            ID         		=> $Param{ItemID},
            Typ       		=> $Row[1],
            Model      		=> $Row[2],
            Manufacturer	=> $Row[3],
            Serialnumber   	=> $Row[4],
            PurchaseTime	=> $Row[5],
            Comment    		=> $Row[6],            
            CreateTime 		=> $Row[7],
            CreateBy   		=> $Row[8],
            ChangeTime 		=> $Row[9],
            ChangeBy   		=> $Row[10],
            
        );
    }
    return %InventoryData;
}


1;
