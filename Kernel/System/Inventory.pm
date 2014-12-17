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

use Kernel::System::Time;

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
	
	$Self->{TimeObject} = Kernel::System::Time->new(%Param);	
	
    return $Self;
}


sub GetObjectList {
    my ( $Self, %Param ) = @_;

	my $SQL = "SELECT id  FROM inventory";

	if($Param{Key} && $Param{Value}){
		if($Param{Key} eq 'purchase_time' || $Param{Key} eq 'create_time' || $Param{Key} eq 'change_time'){			
			
			$Param{Value} = substr($Param{Value}, 0, 10);
			$SQL .= " WHERE DATE($Param{Key}) like '%$Param{Value}%'";		
			
		}
		else{
			
			$SQL .= " WHERE $Param{Key} like '%$Param{Value}%'";					
		}		
	}
	
	
##################### 
#       Search      #
#####################   
	if($Param{Search}){
				 
		$SQL .= " WHERE id like '%$Param{ID}%' 
				AND type like '%$Param{Type}%' 
				AND model like '%$Param{Model}%' 
				AND manufacturer like '%$Param{Manufacturer}%'
				AND serialnumber like '%$Param{Serialnumber}%'
				AND sap like '%$Param{SAP}%'
				AND room like '%$Param{Room}%'
				 ";					
	}
	
	
##################### 
#       Search      #
#####################   


		
	if($Param{Limit} && !$Param{Key}){
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

sub GetObjectData {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ObjectID} ) {
        $Self->{LogObject}->Log( Priority => 'error', Message => 'Need ObjectID for GetInventoryData function.' );
        return;
    }

    # sql
    return if !$Self->{DBObject}->Prepare(
        SQL => 'SELECT * '
            . 'FROM inventory WHERE id = ?',
        Bind => [ \$Param{ObjectID} ],
    );
    
    my %InventoryData;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        %InventoryData = (
            ID         		=> $Param{ObjectID},
            Type       		=> $Row[1],
            Model      		=> $Row[2],
            Manufacturer	=> $Row[3],
            Serialnumber   	=> $Row[4],
            PurchaseTime	=> $Row[5],
            Comment    		=> $Row[6],            
            CreateTime 		=> $Row[7],
            CreateBy   		=> $Row[8],
            ChangeTime 		=> $Row[9],
            ChangeBy   		=> $Row[10],
            Employee 		=> $Row[11],
            Room 			=> $Row[12],
            Phone 			=> $Row[13],
            SAP 			=> $Row[14],
            IP 				=> $Row[15],
            MAC 			=> $Row[16],
            Socket 			=> $Row[17],
            DistributionCabinet => $Row[18],
            KeyNr				=> $Row[19],
            Segregation			=> $Row[20],
            SegregationStatus	=> $Row[21],
            
            
        );
    }
    return %InventoryData;
}


sub AddObject {
	
	    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Type Model Manufacturer Serialnumber PurchaseTime UserID)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_ for AddInfo function." );
            return;
        }
    }

    return if !$Self->{DBObject}->Do(
        SQL => 'INSERT INTO inventory (type, model, manufacturer, serialnumber, purchase_time, comment, '
            . ' create_time, create_by, change_time, change_by, employee, room, phone, sap, ip, mac, socket, distribution_cabinet, keynr, segregation,segregationstatus)'
            . ' VALUES (?, ?, ?, ?, ?, ?,current_timestamp, ?, current_timestamp, ? , ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)',
        Bind => [
            \$Param{Type}, \$Param{Model}, \$Param{Manufacturer}, \$Param{Serialnumber},
            \$Param{PurchaseTime}, \$Param{Comment},  \$Param{UserID}, \$Param{UserID},
            \$Param{Employee}, \$Param{Room},  \$Param{Phone}, \$Param{SAP}, 
            \$Param{IP}, \$Param{MAC},  \$Param{Socket}, \$Param{DistributionCabinet}, 
            \$Param{KeyNr}, \$Param{Segregation}, \$Param{SegregationStatus},
        ],
    );
    
    # get new info id
    return if !$Self->{DBObject}->Prepare(
        SQL  => 'SELECT id FROM inventory WHERE serialnumber = ?',
        Bind => [ \$Param{Serialnumber} ],
    );
    my $ObjectID;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $ObjectID = $Row[0];
   } 
    
    # log
    $Self->{LogObject}->Log(
        Priority => 'info',
        Message  => "Type '$Param{Type}' was created successfully by ($Param{UserName})!",
    );
    return $ObjectID;
	
}

sub DeleteObject {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(ObjectID)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_ for DeleteObject function." );
            return;
        }
    }        
    
    # sql
    my $DeletedObject = $Self->{DBObject}->Do(
        SQL => 'DELETE FROM inventory'
            . ' WHERE id = ?',
        Bind => [
        	\$Param{ObjectID}
        ],
    );  	
 	
 	if (!$DeletedObject){
 		$Self->{LogObject}->Log(
 			Priority => 'error',
 			Message  => "Error: Info '$Param{ObjectID}' could not delete!",
 		);
 		return;
 	}
 	else{
 			
 	 	$Self->{LogObject}->Log(
			Priority => 'info',
			Message  => "Info: Info '$Param{ObjectID}' was deleted successfully by ($Param{UserName})!",	
		);
		return $Param{ObjectID};
 	}
}

sub UpdateObject {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(ObjectID)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_ for UpdateObject function." );
            return;
        }
    }        
    # sql
    my $UpdateObject = $Self->{DBObject}->Do(
        SQL => 'UPDATE inventory SET type = ?, model = ?, manufacturer = ?, serialnumber = ?, purchase_time = ?, comment = ?, '
            . ' change_time = current_timestamp, change_by = ?, employee = ?, room = ?, phone = ?, sap = ?, ip = ?, mac = ?, socket = ?, distribution_cabinet = ?, keynr = ?, segregation = ?, segregationstatus = ?  WHERE id = ?',
        Bind => [
             \$Param{Type}, \$Param{Model}, \$Param{Manufacturer}, \$Param{Serialnumber},
             \$Param{PurchaseTime}, \$Param{Comment},  \$Param{UserID}, 
             \$Param{Employee}, \$Param{Room},  \$Param{Phone}, \$Param{SAP}, 
            \$Param{IP}, \$Param{MAC},  \$Param{Socket}, \$Param{DistributionCabinet}, 
            \$Param{KeyNr}, \$Param{Segregation}, \$Param{SegregationStatus}, \$Param{ObjectID},
        ],
    );  	
 		 
 	
 	if (!$UpdateObject){
 		$Self->{LogObject}->Log(
 			Priority => 'error',
 			Message  => "Error: Info '$Param{ObjectID}' could not be updated!"
 		);
 		return;
 	}
 	$Self->{LogObject}->Log(
		Priority => 'info',
		Message  => "ObjectID '$Param{ObjectID}' - '$Param{Type}' was updated successfully by ($Param{UserName})!",	
	);
	return $Param{ObjectID};
}






#
#sub GetAddionalKeyList {
#    my ( $Self, %Param ) = @_;
#
#	my $SQL = "SELECT DISTINCT additional_key  FROM inventory_additional";
#
#	if($Param{ObjectID}){
#		$SQL .= " WHERE object_id = $Param{ObjectID}";
#	}
#	
#	if($Param{Limit}){
#		$SQL .= " ORDER BY `key` DESC LIMIT $Param{Limit}";
#	}
#	
#	# sql
#    return if !$Self->{DBObject}->Prepare(
#        SQL  => $SQL,        
#    );
#    
#    my %AddionalKeyList;
#    while ( my @Row  = $Self->{DBObject}->FetchrowArray() ) {
#        $AddionalKeyList{ $Row[0] } = $Row[0];	            
#    }
#    return %AddionalKeyList;
#}


1;
