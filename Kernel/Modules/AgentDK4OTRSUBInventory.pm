# --
# Copyright (C) (2014) (Denny Korsukéwitz) (https://github.com/dennykorsukewitz)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentDK4OTRSUBInventory;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::DK4OTRSUBInventory',
    'Kernel::System::Log',
    'Kernel::System::DateTime',
    'Kernel::System::User',
    'Kernel::System::Web::Request',
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject     = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $InventoryObject = $Kernel::OM->Get('Kernel::System::DK4OTRSUBInventory');
    my $UserObject      = $Kernel::OM->Get('Kernel::System::User');
    my $LogObject       = $Kernel::OM->Get('Kernel::System::Log');
    my $TimeObject      = $Kernel::OM->Create('Kernel::System::DateTime');

    # Note to notify.
    my $Note = '';

    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

# ------------------------------------------------------------ #
# UpdateSettings: update Overview Settings
# ------------------------------------------------------------ #
#   if ( $Self->{Subaction} eq 'UpdateSettings' ) {
#
#       my ( %GetParam, %Errors );
#       for my $Parameter (qw(Type Model Manufacturer Serialnumber PurchaseTime Comment CreateTime CreateBy ChangeTime ChangeBy Edit Delete)) {
#         $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
#       }
#
#       $LayoutObject->Block(
#           Name => 'TestField',
#           Data => {
#             TEST => $Additional,
#           },
#       );
#
#       $Output .= $Self->_Overview( Action => 'Select',  Key => $GetParam{Key} , Value => $GetParam{Value} );
#       $Output .= $LayoutObject->Output(
#          TemplateFile => 'DK4OTRSUBInventory',
#           Data         => \%Param,
#       );
#       $Output .= $LayoutObject->Footer();
#       return $Output;
#   }
# ------------------------------------------------------------ #
# Select:
# ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Select' ) {

        # get all parameter from the form
        my ( %GetParam, %Errors );
        for my $Parameter (qw(Key Value)) {
            $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
        }

        $Output .= $Self->_Overview(
            Action => 'Select',
            Key    => $GetParam{Key},
            Value  => $GetParam{Value}
        );
        $Output .= $LayoutObject->Output(
            TemplateFile => 'DK4OTRSUBInventory',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # Search:
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Search' ) {

        # get all parameter from the form
        my ( %GetParam, %Errors );
        for my $Parameter (qw(ID Type Model Manufacturer Serialnumber Room SAP)) {
            $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
        }

        $Output .= $Self->_Overview(
            Action => 'Search',
            %GetParam,
        );
        $Output .= $LayoutObject->Output(
            TemplateFile => 'DK4OTRSUBInventory',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # Search:
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'EditSAP' ) {

        # get all parameter from the form
        my ( %GetParam, %Errors );
        for my $Parameter (qw(Value)) {
            $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
        }

        my %ObjectID = $InventoryObject->GetObjectList(
            Key   => "sap",
            Value => $GetParam{Value}
        );

        my %ObjectData = $InventoryObject->GetObjectData( ObjectID => %ObjectID );

        $ObjectData{PurchaseTime} = $TimeObject->TimeStamp2SystemTime(
            String => $ObjectData{PurchaseTime},
        );

        (
            $ObjectData{PurchaseTimeSec}, $ObjectData{PurchaseTimeMin},   $ObjectData{PurchaseTimeHour},
            $ObjectData{PurchaseTimeDay}, $ObjectData{PurchaseTimeMonth}, $ObjectData{PurchaseTimeYear},
            $ObjectData{PurchaseTimeWeekDay}
        ) = $TimeObject->SystemTime2Date(
            SystemTime => $ObjectData{PurchaseTime},
        );

        $ObjectData{Segregation} = $TimeObject->TimeStamp2SystemTime(
            String => $ObjectData{Segregation},
        );
        (
            $ObjectData{SegregationSec}, $ObjectData{SegregationMin},   $ObjectData{SegregationHour},
            $ObjectData{SegregationDay}, $ObjectData{SegregationMonth}, $ObjectData{SegregationYear},
            $ObjectData{SegregationWeekDay}
        ) = $TimeObject->SystemTime2Date(
            SystemTime => $ObjectData{Segregation},
        );

        $Output .= $Self->_Form(
            Action => 'Edit',
            %ObjectData,
        );

        $Output .= $LayoutObject->Output(
            TemplateFile => 'DK4OTRSUBInventory',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # Add: to add a Notification
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Add' ) {

        $Output .= $Self->_Form(
            Action => 'Add',
        );
        $Output .= $LayoutObject->Output(
            TemplateFile => 'DK4OTRSUBInventory',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # AddAction
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'AddAction' ) {

        # get all parameter from the form
        my ( %GetParam, %Errors );
        for my $Parameter (
            qw(Type Model Manufacturer Serialnumber Year Month Day Comment Employee Room Phone SAP IP MAC Socket DistributionCabinet
            KeyNr PurchaseTimeYear PurchaseTimeMonth PurchaseTimeDay
            SegregationYear SegregationMonth SegregationDay SegregationStatus )
            )
        {
            $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
        }

        $GetParam{PurchaseTime} = $TimeObject->Set(
            Year   => $GetParam{PurchaseTimeYear},
            Month  => $GetParam{PurchaseTimeMonth},
            Day    => $GetParam{PurchaseTimeDay},
            Hour   => $GetParam{PurchaseTimeHour} || 0,
            Minute => $GetParam{PurchaseTimeMinute} || 0,
            Second => $GetParam{PurchaseTimeSecond} || 0,
        );
        $GetParam{PurchaseTime} = $TimeObject->ToString();

        $GetParam{Segregation} = $TimeObject->Set(
            Year   => $GetParam{SegregationYear},
            Month  => $GetParam{SegregationMonth},
            Day    => $GetParam{SegregationDay},
            Hour   => $GetParam{SegregationHour} || 0,
            Minute => $GetParam{SegregationMinute} || 0,
            Second => $GetParam{SegregationSecond} || 0,
        );
        $GetParam{Segregation} = $TimeObject->ToString();

        my $UserName = $UserObject->UserName( UserID => $Self->{UserID} );
        my $ObjectID = $InventoryObject->AddObject(
            %GetParam,
            UserID   => $Self->{UserID},
            UserName => $UserName,
        );

        if ($ObjectID) {

            # get LogEntry with type info
            $Note = $LogObject->GetLogEntry(
                Type => 'Info',
                What => 'Message',
            );

            # set LogEntry as notify
            $Output .= $Note
                ? $LayoutObject->Notify(
                Priority => 'Info',
                Info     => $Note,
                )
                : '';

            $Self->_Overview();

        }
        else
        {
            # if something went wrong (NO $InfoID)
            $Note = "Error: Could not create this Object. Please edit your input. ";
            $Note .= $LogObject->GetLogEntry(
                Type => 'Error',
                What => 'Message',
            );
            $Output .= $Note
                ? $LayoutObject->Notify(
                Priority => 'Error',
                Info     => $Note,
                )
                : '';

            $Output .= $Self->_Form(
                Action => 'Add',
                %GetParam,
            );
        }

        $Output .= $LayoutObject->Output(
            TemplateFile => 'DK4OTRSUBInventory',
            Data         => \%Param,
        );

        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # Edit: to edit a Notification
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Edit' ) {

        my ( $Set, $EditDateHash );
        my $ObjectID   = $ParamObject->GetParam( Param => 'ID' );
        my %ObjectData = $InventoryObject->GetObjectData( ObjectID => $ObjectID );

        # get dates for edit form
        $Set          = $TimeObject->Set( String => $ObjectData{PurchaseTime} );
        $EditDateHash = $TimeObject->Get();

        $ObjectData{PurchaseTimeYear}  = $EditDateHash->{Year};
        $ObjectData{PurchaseTimeMonth} = $EditDateHash->{Month};
        $ObjectData{PurchaseTimeDay}   = $EditDateHash->{Day};

        $Set          = $TimeObject->Set( String => $ObjectData{Segregation} );
        $EditDateHash = $TimeObject->Get();

        $ObjectData{SegregationYear}  = $EditDateHash->{Year};
        $ObjectData{SegregationMonth} = $EditDateHash->{Month};
        $ObjectData{SegregationDay}   = $EditDateHash->{Day};

        $ObjectData{ChangeByID} = $ObjectData{ChangeBy};
        $ObjectData{CreateByID} = $ObjectData{CreateBy};

        my $ChangeByName = $UserObject->UserName( UserID => $ObjectData{ChangeBy} );
        my $CreateByName = $UserObject->UserName( UserID => $ObjectData{CreateBy} );

        $ObjectData{ChangeBy} = $ChangeByName;
        $ObjectData{CreateBy} = $CreateByName;

        $Output .= $Self->_Form(
            Action => 'Edit',
            %ObjectData,
        );

        $Output .= $LayoutObject->Output(
            TemplateFile => 'DK4OTRSUBInventory',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # EditAction: to edit a Notification
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'EditAction' ) {

        # get all parameter from the form
        my ( %GetParam, %Errors );
        for my $Parameter (
            qw(ID Type Model Manufacturer Serialnumber Year Month Day Comment Employee Room
            Phone SAP IP MAC Socket DistributionCabinet KeyNr PurchaseTimeYear PurchaseTimeMonth
            PurchaseTimeDay SegregationYear SegregationMonth SegregationDay SegregationStatus
            )
            )
        {
            $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
        }

        if ( $GetParam{SegregationStatus} eq 'off' )
        {
            $GetParam{Segregation} = '2001-01-01 00:00:00';
        }
        else
        {
            $GetParam{Segregation} = $TimeObject->Set(
                Year   => $GetParam{SegregationYear},
                Month  => $GetParam{SegregationMonth},
                Day    => $GetParam{SegregationDay},
                Hour   => 0,
                Minute => 0,
                Second => 0,
            );
        }

        $GetParam{Segregation} = $TimeObject->ToString();

        $GetParam{PurchaseTime} = $TimeObject->Set(
            Year   => $GetParam{PurchaseTimeYear},
            Month  => $GetParam{PurchaseTimeMonth},
            Day    => $GetParam{PurchaseTimeDay},
            Hour   => 0,
            Minute => 0,
            Second => 0,
        );
        $GetParam{PurchaseTime} = $TimeObject->ToString();

        # update Object
        my $UserName = $UserObject->UserName( UserID => $Self->{UserID} );
        my $ObjectID = $InventoryObject->UpdateObject(
            %GetParam,
            ObjectID => $GetParam{ID},
            UserID   => $Self->{UserID},
            UserName => $UserName,
        );
        if ($ObjectID) {

            # get LogEntry with type info
            $Note = $LogObject->GetLogEntry(
                Type => 'Info',
                What => 'Message',
            );

            # set LogEntry as notify
            $Output .= $Note
                ? $LayoutObject->Notify(
                Priority => 'Info',
                Info     => $Note,
                )
                : '';

            ## get link view
            #$Self->_Overview();

            # get edit view
            $Self->_Form(
                Action => 'Edit',
                %GetParam,
            );
        }
        else
        {
            # if something went wrong (NO $InfoID)
            $Note = "Error: Could not update this Object. Please edit your input. ";
            $Note .= $LogObject->GetLogEntry(
                Type => 'Error',
                What => 'Message',
            );
            $Output .= $Note
                ? $LayoutObject->Notify(
                Priority => 'Error',
                Info     => $Note,
                )
                : '';

            # get edit view
            $Self->_Form(
                Action => 'Edit',
                %GetParam,
            );
        }

        $Output .= $LayoutObject->Output(
            TemplateFile => 'DK4OTRSUBInventory',
            Data         => \%Param,
        );

        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # Delete: to delete a Notification
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Delete' ) {

        my $ObjectID = $ParamObject->GetParam( Param => 'ID' );

        # delete info into DB
        my $UserName     = $UserObject->UserName( UserID => $Self->{UserID} );
        my $DeleteObject = $InventoryObject->DeleteObject(
            ObjectID => $ObjectID,
            UserName => $UserName,
        );

        if ($ObjectID) {
            $Note = $LogObject->GetLogEntry(
                Type => 'Info',
                What => 'Message',
            );
            $Output .= $Note
                ? $LayoutObject->Notify(
                Priority => 'Info',
                Info     => $Note,
                )
                : '';
        }
        else {
            $Note .= $LogObject->GetLogEntry(
                Type => 'Error',
                What => 'Message',
            );
            $Output .= $Note
                ? $LayoutObject->Notify(
                Priority => 'Info',
                Info     => $Note,
                )
                : '';
        }

        $Self->_Overview();

        $Output .= $LayoutObject->Output(
            TemplateFile => 'DK4OTRSUBInventory',
            Data         => \%Param,
        );

        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # default view: _Overview - if no subaction is selected        #
    # ------------------------------------------------------------ #

    my $Limit = $ParamObject->GetParam( Param => 'Limit' ) || '30';

    $Output .= $Self->_Overview( Limit => $Limit );
    $Output .= $LayoutObject->Output(
        TemplateFile => 'DK4OTRSUBInventory',
        Data         => \%Param,
    );
    $Output .= $LayoutObject->Footer();
    return $Output;
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    my $LayoutObject    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $InventoryObject = $Kernel::OM->Get('Kernel::System::DK4OTRSUBInventory');
    my $UserObject      = $Kernel::OM->Get('Kernel::System::User');
    my $TimeObject      = $Kernel::OM->Create('Kernel::System::DateTime');

    $Param{Action} ||= '';

    # blocks
    $LayoutObject->Block( Name => 'FilterObject' );
    $LayoutObject->Block(
        Name => 'Search',
        Data => {
            ID           => $Param{ID}           || 'UB-ID',
            Type         => $Param{Type}         || 'Type',
            Model        => $Param{Model}        || 'Model',
            Manufacturer => $Param{Manufacturer} || 'Manufacturer',
            Serialnumber => $Param{Serialnumber} || 'Serialnumber',
            SAP          => $Param{SAP}          || 'SAP',
            Room         => $Param{Room}         || 'Room',
        },
    );
    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'Hint' );
    $LayoutObject->Block( Name => 'Overview' );

    my %ObjectList;

    if ( $Param{Action} eq 'Select' ) {

        # get GetObjectList
        %ObjectList = $InventoryObject->GetObjectList(
            Key   => $Param{Key},
            Value => $Param{Value}
        );
        $Param{ObjectCount} = keys %ObjectList;
        if ( $Param{Key} eq 'change_by' || $Param{Key} eq 'create_by' ) {
            $Param{Value} = $UserObject->UserName( UserID => $Param{Value} );
        }

    }
    elsif ( $Param{Action} eq 'Search' ) {

        # get GetObjectList  ID Type Model Manufacturer Serialnumber Room)
        %ObjectList = $InventoryObject->GetObjectList(
            ID           => $Param{ID}           || '%',
            Type         => $Param{Type}         || '%',
            Model        => $Param{Model}        || '%',
            Manufacturer => $Param{Manufacturer} || '%',
            Serialnumber => $Param{Serialnumber} || '%',
            SAP          => $Param{SAP}          || '%',
            Room         => $Param{Room}         || '%',
            Limit        => $Param{Limit},
            Search       => '1'
        );
        $Param{ObjectCount} = keys %ObjectList;

    }
    else {

        # get GetObjectList
        %ObjectList = $InventoryObject->GetObjectList( Limit => $Param{Limit} );

    }

    for my $ObjectID ( sort { uc( $ObjectList{$a} ) cmp uc( $ObjectList{$b} ) } keys %ObjectList ) {

        # get GetInventoryData
        my %ObjectData = $InventoryObject->GetObjectData( ObjectID => $ObjectID );
        $ObjectData{ChangeByID} = $ObjectData{ChangeBy};
        $ObjectData{CreateByID} = $ObjectData{CreateBy};

        $ObjectData{ChangeBy} = $UserObject->UserName( UserID => $ObjectData{ChangeBy} );
        $ObjectData{CreateBy} = $UserObject->UserName( UserID => $ObjectData{CreateBy} );

        if ( $ObjectData{SegregationStatus} eq "off" )
        {
            $ObjectData{Segregation} = '';
        }

        $LayoutObject->Block(
            Name => 'ObjectList',
            Data => {
                %ObjectData,
                ID => $ObjectData{ID},
            },
        );
    }

    if ( $Param{Action} eq 'Select' ) {

        %ObjectList = $InventoryObject->GetObjectList(
            Key   => $Param{Key},
            Value => $Param{Value}
        );
        $LayoutObject->Block(
            Name => 'SelectInfo',
            Data => {
                %Param,
            },
        );
    }

    return;
}

sub _Form {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'FormHint' );

    if ( $Param{SegregationStatus} eq "on" )
    {
        $Param{SegregationOn} = 'checked="checked"';
    }
    else
    {
        $Param{SegregationOff}   = 'checked="checked"';
        $Param{SegregationYear}  = '2001';
        $Param{SegregationMonth} = '01';
        $Param{SegregationDay}   = '01';
    }

    $Param{PurchaseTime} = $LayoutObject->BuildDateSelection(
        Prefix            => 'PurchaseTime',
        PurchaseTimeYear  => $Param{PurchaseTimeYear},
        PurchaseTimeMonth => $Param{PurchaseTimeMonth},
        PurchaseTimeDay   => $Param{PurchaseTimeDay},
        Format            => 'DateInputFormat',
    );

    $Param{Segregation} = $LayoutObject->BuildDateSelection(
        Prefix           => 'Segregation',
        SegregationYear  => $Param{SegregationYear},
        SegregationMonth => $Param{SegregationMonth},
        SegregationDay   => $Param{SegregationDay},
        Format           => 'DateInputFormat',
    );

    # content
    $LayoutObject->Block(
        Name => 'Form',
        Data => \%Param,
    );

    if ( $Param{ObjectID} ) {
        $LayoutObject->Block(
            Name => 'FormObjectID',
            Data => {
                ObjectID => $Param{ObjectID},
            },
        );
    }

    # content header
    if ( $Param{Action} eq 'Add' ) {
        $LayoutObject->Block( Name => 'HeaderAdd' );
    }
    elsif ( $Param{Action} eq 'Edit' ) {
        $LayoutObject->Block(
           Name => 'HeaderEdit',
           Data => \%Param,
        );
        $LayoutObject->Block(
            Name => 'AdditionalInformation',
            Data => \%Param,
        );

    }

    return;
}

1;
