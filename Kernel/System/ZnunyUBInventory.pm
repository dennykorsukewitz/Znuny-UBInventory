# --
# Copyright (C) (2014) (Denny Korsukéwitz) (https://github.com/dennykorsukewitz)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::ZnunyUBInventory;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub GetObjectList {
    my ( $Self, %Param ) = @_;

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $SQL = "SELECT id  FROM inventory";

    if ( $Param{Key} && $Param{Value} ) {
        if ( $Param{Key} eq 'purchase_time' || $Param{Key} eq 'create_time' || $Param{Key} eq 'change_time' ) {

            $Param{Value} = substr( $Param{Value}, 0, 10 );
            $SQL .= " WHERE DATE($Param{Key}) like '%$Param{Value}%'";

        }
        else {

            $SQL .= " WHERE $Param{Key} like '%$Param{Value}%'";
        }
    }

    if ( $Param{Search} ) {

        $SQL .= " WHERE id like '%$Param{ID}%'
            AND type like '%$Param{Type}%'
            AND model like '%$Param{Model}%'
            AND manufacturer like '%$Param{Manufacturer}%'
            AND serialnumber like '%$Param{Serialnumber}%'
            AND sap like '%$Param{SAP}%'
            AND room like '%$Param{Room}%'
        ";
    }

    if ( $Param{Limit} && !$Param{Key} ) {
        $SQL .= " ORDER BY `id` DESC LIMIT $Param{Limit}";
    }

    # sql
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    my %InventoryList;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $InventoryList{ $Row[0] } = $Row[0];
    }
    return %InventoryList;
}

sub GetObjectData {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject  = $Kernel::OM->Get('Kernel::System::DB');

    # check needed stuff
    if ( !$Param{ObjectID} ) {
        $LogObject->Log(
            Priority => 'error',
            Message  => 'Need ObjectID for GetInventoryData function.'
        );
        return;
    }

    # sql
    return if !$DBObject->Prepare(
        SQL => 'SELECT * '
            . 'FROM inventory WHERE id = ?',
        Bind => [ \$Param{ObjectID} ],
    );

    my %InventoryData;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        %InventoryData = (
            ID                  => $Param{ObjectID},
            Type                => $Row[1],
            Model               => $Row[2],
            Manufacturer        => $Row[3],
            Serialnumber        => $Row[4],
            PurchaseTime        => $Row[5],
            Comment             => $Row[6],
            CreateTime          => $Row[7],
            CreateBy            => $Row[8],
            ChangeTime          => $Row[9],
            ChangeBy            => $Row[10],
            Employee            => $Row[11],
            Room                => $Row[12],
            Phone               => $Row[13],
            SAP                 => $Row[14],
            IP                  => $Row[15],
            MAC                 => $Row[16],
            Socket              => $Row[17],
            DistributionCabinet => $Row[18],
            KeyNr               => $Row[19],
            Segregation         => $Row[20],
            SegregationStatus   => $Row[21],

        );
    }
    return %InventoryData;
}

sub AddObject {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject  = $Kernel::OM->Get('Kernel::System::DB');

    # check needed stuff
    for my $Needed (qw(Type Model Manufacturer Serialnumber PurchaseTime UserID)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed for AddInfo function."
            );
            return;
        }
    }

    return if !$DBObject->Do(
        SQL => 'INSERT INTO inventory (type, model, manufacturer, serialnumber, purchase_time, comment, '
            . ' create_time, create_by, change_time, change_by, employee, room, phone, sap, ip, mac, socket, distribution_cabinet, keynr, segregation,segregationstatus)'
            . ' VALUES (?, ?, ?, ?, ?, ?,current_timestamp, ?, current_timestamp, ? , ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)',
        Bind => [
            \$Param{Type},         \$Param{Model},   \$Param{Manufacturer}, \$Param{Serialnumber},
            \$Param{PurchaseTime}, \$Param{Comment}, \$Param{UserID},       \$Param{UserID},
            \$Param{Employee},     \$Param{Room},    \$Param{Phone},        \$Param{SAP},
            \$Param{IP},           \$Param{MAC},     \$Param{Socket},       \$Param{DistributionCabinet},
            \$Param{KeyNr}, \$Param{Segregation}, \$Param{SegregationStatus},
        ],
    );

    # get new info id
    return if !$DBObject->Prepare(
        SQL  => 'SELECT id FROM inventory WHERE serialnumber = ?',
        Bind => [ \$Param{Serialnumber} ],
    );
    my $ObjectID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $ObjectID = $Row[0];
    }

    # log
    $LogObject->Log(
        Priority => 'info',
        Message  => "Type '$Param{Type}' was created successfully by ($Param{UserName})!",
    );
    return $ObjectID;

}

sub DeleteObject {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject  = $Kernel::OM->Get('Kernel::System::DB');

    # check needed stuff
    for my $Needed (qw(ObjectID)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed for DeleteObject function."
            );
            return;
        }
    }

    # sql
    my $DeletedObject = $DBObject->Do(
        SQL => 'DELETE FROM inventory'
            . ' WHERE id = ?',
        Bind => [
            \$Param{ObjectID}
        ],
    );

    if ( !$DeletedObject ) {
        $LogObject->Log(
            Priority => 'error',
            Message  => "Error: Info '$Param{ObjectID}' could not delete!",
        );
        return;
    }
    else {

        $LogObject->Log(
            Priority => 'info',
            Message  => "Info: Info '$Param{ObjectID}' was deleted successfully by ($Param{UserName})!",
        );
        return $Param{ObjectID};
    }
}

sub UpdateObject {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject  = $Kernel::OM->Get('Kernel::System::DB');

    # check needed stuff
    for my $Needed (qw(ObjectID)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed for UpdateObject function."
            );
            return;
        }
    }

    # sql
    my $UpdateObject = $DBObject->Do(
        SQL =>
            'UPDATE inventory SET type = ?, model = ?, manufacturer = ?, serialnumber = ?, purchase_time = ?, comment = ?, '
            . ' change_time = current_timestamp, change_by = ?, employee = ?, room = ?, phone = ?, sap = ?, ip = ?, mac = ?, socket = ?, distribution_cabinet = ?, keynr = ?, segregation = ?, segregationstatus = ?  WHERE id = ?',
        Bind => [
            \$Param{Type}, \$Param{Model}, \$Param{Manufacturer}, \$Param{Serialnumber},
            \$Param{PurchaseTime}, \$Param{Comment},     \$Param{UserID},
            \$Param{Employee},     \$Param{Room},        \$Param{Phone}, \$Param{SAP},
            \$Param{IP},           \$Param{MAC},         \$Param{Socket}, \$Param{DistributionCabinet},
            \$Param{KeyNr},        \$Param{Segregation}, \$Param{SegregationStatus}, \$Param{ObjectID},
        ],
    );

    if ( !$UpdateObject ) {
        $LogObject->Log(
            Priority => 'error',
            Message  => "Error: Info '$Param{ObjectID}' could not be updated!"
        );
        return;
    }
    $LogObject->Log(
        Priority => 'info',
        Message  => "ObjectID '$Param{ObjectID}' - '$Param{Type}' was updated successfully by ($Param{UserName})!",
    );
    return $Param{ObjectID};
}

1;
