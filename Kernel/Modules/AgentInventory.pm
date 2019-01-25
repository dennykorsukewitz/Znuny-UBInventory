# --
# Kernel/Modules/Inventory.pm - frontend module
# Copyright (C) (2014) (Denny Bresch) (dennybresch@gmail.com) (https://github.com/dennybresch)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentInventory;

use strict;
use warnings;

use Kernel::System::Inventory;
use Kernel::System::Time;
use Kernel::System::Notify;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless ($Self, $Type);
        
    # check needed objects
    for (qw(ParamObject DBObject TicketObject LayoutObject LogObject QueueObject ConfigObject EncodeObject MainObject TimeObject)) {
        if ( !$Self->{$_} ) {
            $Self->{LayoutObject}->FatalError( Message => "Got no $_ in Inventory!" );
        }
    }   
        
    # create Objects
    $Self->{InventoryObject} = Kernel::System::Inventory->new(%Param);	
    $Self->{TimeObject} = Kernel::System::Time->new(%Param);	    
    $Self->{NotifyObject} = Kernel::System::Notify->new(%Param);
    
    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

	# Note to notify.
 	my $Note = ''; 	
 	
 	
 	     
    my $Output = $Self->{LayoutObject}->Header();
    $Output .= $Self->{LayoutObject}->NavigationBar();    
    # ------------------------------------------------------------ #
    # UpdateSettings: update Overview Settings
    # ------------------------------------------------------------ #	
#	if ( $Self->{Subaction} eq 'UpdateSettings' ) {
#		
#		my ( %GetParam, %Errors );
#		for my $Parameter (qw(Type Model Manufacturer Serialnumber PurchaseTime Comment CreateTime CreateBy ChangeTime ChangeBy Edit Delete)) {
#	     	$GetParam{$Parameter} = $Self->{ParamObject}->GetParam( Param => $Parameter ) || '';      
#		}
#		
#		$Self->{LayoutObject}->Block(
#	        Name => 'TestField',
#	        Data => {
#	        	TEST => $Additional,
#	        },
#	    );  
#		
#		$Output .= $Self->_Overview( Action => 'Select',  Key => $GetParam{Key} , Value => $GetParam{Value} );
#	    $Output .= $Self->{LayoutObject}->Output(
#	       TemplateFile => 'Inventory',
#	        Data         => \%Param,
#	    );
#	    $Output .= $Self->{LayoutObject}->Footer();
#	    return $Output;
#	} 	
	# ------------------------------------------------------------ #
    # Select: 
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Select' ) {
    	
		# get all parameter from the form       
		my ( %GetParam, %Errors );
		for my $Parameter (qw(Key Value)) {
	     	$GetParam{$Parameter} = $Self->{ParamObject}->GetParam( Param => $Parameter ) || '';      
		}
	

		$Output .= $Self->_Overview( Action => 'Select',  Key => $GetParam{Key} , Value => $GetParam{Value} );
	    $Output .= $Self->{LayoutObject}->Output(
	       TemplateFile => 'Inventory',
	        Data         => \%Param,
	    );
	    $Output .= $Self->{LayoutObject}->Footer();
	    return $Output;
	} 
	# ------------------------------------------------------------ #
    # Search:  
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Search' ) {		
		
		# get all parameter from the form       
		my ( %GetParam, %Errors );
		for my $Parameter (qw(ID Type Model Manufacturer Serialnumber Room SAP)) {
	     	$GetParam{$Parameter} = $Self->{ParamObject}->GetParam( Param => $Parameter ) || '';      
		}
	

		$Output .= $Self->_Overview(Action => 'Search', %GetParam, );
	    $Output .= $Self->{LayoutObject}->Output(
	       TemplateFile => 'Inventory',
	        Data         => \%Param,
	    );
	    $Output .= $Self->{LayoutObject}->Footer();
	    return $Output;
	} 
	# ------------------------------------------------------------ #
    # Search:  
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'EditSAP' ) {		
		
		# get all parameter from the form       
		my ( %GetParam, %Errors );
		for my $Parameter (qw(Value)) {
	     	$GetParam{$Parameter} = $Self->{ParamObject}->GetParam( Param => $Parameter ) || '';      
		}
		
		my %ObjectID = $Self->{InventoryObject}->GetObjectList( Key => "sap", Value => $GetParam{Value} );
 
		my %ObjectData = $Self->{InventoryObject}->GetObjectData( ObjectID => %ObjectID );	
		
		$ObjectData{PurchaseTime} = $Self->{TimeObject}->TimeStamp2SystemTime(
	        String => $ObjectData{PurchaseTime},
	    ); 
	    
	    ($ObjectData{PurchaseTimeSec}, $ObjectData{PurchaseTimeMin}, $ObjectData{PurchaseTimeHour}, $ObjectData{PurchaseTimeDay}, $ObjectData{PurchaseTimeMonth}, $ObjectData{PurchaseTimeYear}, $ObjectData{PurchaseTimeWeekDay}) = $Self->{TimeObject}->SystemTime2Date(
	        SystemTime => $ObjectData{PurchaseTime},
	    );
	    
	    ### NEW ###
	    $ObjectData{Segregation} = $Self->{TimeObject}->TimeStamp2SystemTime(
	        String => $ObjectData{Segregation},
	    ); 
	    ($ObjectData{SegregationSec}, $ObjectData{SegregationMin}, $ObjectData{SegregationHour}, $ObjectData{SegregationDay}, $ObjectData{SegregationMonth}, $ObjectData{SegregationYear}, $ObjectData{SegregationWeekDay}) = $Self->{TimeObject}->SystemTime2Date(
	        SystemTime => $ObjectData{Segregation},
	    );
	    ### NEW ###
	    


		$Output .= $Self->_Form(
        	Action => 'Edit',
            %ObjectData,         
        );
		
        $Output .=  $Self->{LayoutObject}->Output(
	        TemplateFile => 'Inventory',
	        Data         => \%Param,
	    );
        $Output .= $Self->{LayoutObject}->Footer();
        return $Output;
	} 
	# ------------------------------------------------------------ #
    # Add: to add a Notification
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Add' ) {		
		
		$Output .= $Self->_Form(
			Action	=>	'Add',
		);
		$Output .=  $Self->{LayoutObject}->Output(
			TemplateFile => 'Inventory',
			Data         => \%Param,
		);
	    $Output .= $Self->{LayoutObject}->Footer();
	    return $Output;
	} 
	# ------------------------------------------------------------ #
    # AddAction
    # ------------------------------------------------------------ #	
    elsif ( $Self->{Subaction} eq 'AddAction' ) {   
    	 	
		# get all parameter from the form       
		my ( %GetParam, %Errors );
		for my $Parameter (qw(Type Model Manufacturer Serialnumber Year Month Day Comment Employee Room Phone SAP IP MAC Socket DistributionCabinet
							 KeyNr PurchaseTimeYear PurchaseTimeMonth PurchaseTimeDay 
							 SegregationYear SegregationMonth SegregationDay SegregationStatus )) {
	       	$GetParam{$Parameter} = $Self->{ParamObject}->GetParam( Param => $Parameter ) || '';      
		} 
		
		$GetParam{PurchaseTime} =  $Self->{TimeObject}->Date2SystemTime(
	        Year   => $GetParam{PurchaseTimeYear},
	        Month  => $GetParam{PurchaseTimeMonth},
	        Day    => $GetParam{PurchaseTimeDay},
	        Hour   => $GetParam{PurchaseTimeHour} 	|| 0,
	        Minute => $GetParam{PurchaseTimeMinute} || 0,
	        Second => $GetParam{PurchaseTimeSecond} || 0,
	    );
	    $GetParam{PurchaseTime} = $Self->{TimeObject}->SystemTime2TimeStamp(
	        SystemTime => $GetParam{PurchaseTime},
	    );
	    
	    $GetParam{Segregation} =  $Self->{TimeObject}->Date2SystemTime(
	        Year   => $GetParam{SegregationYear},
	        Month  => $GetParam{SegregationMonth},
	        Day    => $GetParam{SegregationDay},
	        Hour   => $GetParam{SegregationHour} 	|| 0,
	        Minute => $GetParam{SegregationMinute} || 0,
	        Second => $GetParam{SegregationSecond} || 0,
	    );
	    $GetParam{Segregation} = $Self->{TimeObject}->SystemTime2TimeStamp(
	        SystemTime => $GetParam{Segregation},
	    );	
	       

		my $ObjectID = $Self->{InventoryObject}->AddObject(
			%GetParam,
			UserID => $Self->{UserID},
			UserName => $Self->{UserObject}->UserName( UserID =>  $Self->{UserID} ),
		);
		
		if ($ObjectID) {
    		# get LogEntry with type info     
        	$Note = $Self->{LogObject}->GetLogEntry(
                    Type => 'Info',
                    What => 'Message',
            );   
            
            # set LogEntry as notify
            $Output .= $Note
            	? $Self->{LayoutObject}->Notify(
		            Priority => 'Info',
		            Info     => $Note,
           		) : '';
		    
		    $Self->_Overview();

			                  		
        }
        else
        {
        	# if something went wrong (NO $InfoID)   
        	$Note = "Error: Could not create this Object. Please edit your input. ";  
        	$Note .= $Self->{LogObject}->GetLogEntry(
                    Type => 'Error',
                    What => 'Message',
            );   
            $Output .= $Note
	            ? $Self->{LayoutObject}->Notify(
		            Priority => 'Error',
		            Info     => $Note,
	            )  : '';
	            
			 $Output .= $Self->_Form(
	            Action => 'Add',
	            %GetParam,
	        );
        }
        		
        $Output .= $Self->{LayoutObject}->Output(
			    	TemplateFile => 'Inventory',
		            Data         => \%Param,
		);
        	                 	        	         	             
	    $Output .= $Self->{LayoutObject}->Footer();	       
	    return $Output;	              	
	}
	# ------------------------------------------------------------ #
    # Edit: to edit a Notification
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Edit' ) {
		
		my $ObjectID = $Self->{ParamObject}->GetParam( Param => 'ID' );    
		my %ObjectData = $Self->{InventoryObject}->GetObjectData( ObjectID => $ObjectID );	
		
		$ObjectData{PurchaseTime} = $Self->{TimeObject}->TimeStamp2SystemTime(
	        String => $ObjectData{PurchaseTime},
	    ); 
	    
	    ($ObjectData{PurchaseTimeSec}, $ObjectData{PurchaseTimeMin}, $ObjectData{PurchaseTimeHour}, $ObjectData{PurchaseTimeDay}, $ObjectData{PurchaseTimeMonth}, $ObjectData{PurchaseTimeYear}, $ObjectData{PurchaseTimeWeekDay}) = $Self->{TimeObject}->SystemTime2Date(
	        SystemTime => $ObjectData{PurchaseTime},
	    );
	    
	    ### NEW ###
	    $ObjectData{Segregation} = $Self->{TimeObject}->TimeStamp2SystemTime(
	        String => $ObjectData{Segregation},
	    ); 
	    ($ObjectData{SegregationSec}, $ObjectData{SegregationMin}, $ObjectData{SegregationHour}, $ObjectData{SegregationDay}, $ObjectData{SegregationMonth}, $ObjectData{SegregationYear}, $ObjectData{SegregationWeekDay}) = $Self->{TimeObject}->SystemTime2Date(
	        SystemTime => $ObjectData{Segregation},
	    );
	    ### NEW ###
	    
	    
	    $ObjectData{ChangeByID} = $ObjectData{ChangeBy};
		$ObjectData{CreateByID} = $ObjectData{CreateBy};							
		$ObjectData{ChangeBy} = $Self->{UserObject}->UserName( UserID =>  $ObjectData{ChangeBy} );
		$ObjectData{CreateBy} = $Self->{UserObject}->UserName( UserID =>  $ObjectData{CreateBy} );


		$Output .= $Self->_Form(
        	Action => 'Edit',
            %ObjectData,         
        );
		
        $Output .=  $Self->{LayoutObject}->Output(
	        TemplateFile => 'Inventory',
	        Data         => \%Param,
	    );
        $Output .= $Self->{LayoutObject}->Footer();
        return $Output;
	}
    # ------------------------------------------------------------ #
    # EditAction: to edit a Notification
    # ------------------------------------------------------------ #
	elsif ( $Self->{Subaction} eq 'EditAction' ) {
	
		# get all parameter from the form       
		my ( %GetParam, %Errors );
		for my $Parameter (qw(ID Type Model Manufacturer Serialnumber Year Month Day Comment Employee Room
							 Phone SAP IP MAC Socket DistributionCabinet KeyNr PurchaseTimeYear PurchaseTimeMonth
							 PurchaseTimeDay SegregationYear SegregationMonth SegregationDay SegregationStatus 
						  ))
		{
	     	$GetParam{$Parameter} = $Self->{ParamObject}->GetParam( Param => $Parameter ) || '';      
		}
			
		
		if ( $GetParam{SegregationStatus} eq 'off')
		{
			 $GetParam{Segregation} = 	'2001-01-01 00:00:00'	
		}	
		else
		{
			$GetParam{Segregation} =  $Self->{TimeObject}->Date2SystemTime(
		        Year   => $GetParam{SegregationYear},
		        Month  => $GetParam{SegregationMonth},
		        Day    => $GetParam{SegregationDay},
		        Hour   => 0,
	       		Minute => 0,
	       		Second => 0,
		    );
			
		}	
				
		$GetParam{Segregation} = $Self->{TimeObject}->SystemTime2TimeStamp(
	        SystemTime => $GetParam{Segregation},
	    );
	    
		$GetParam{PurchaseTime} =  $Self->{TimeObject}->Date2SystemTime(
		        Year   => $GetParam{PurchaseTimeYear},
		        Month  => $GetParam{PurchaseTimeMonth},
		        Day    => $GetParam{PurchaseTimeDay},
		        Hour   => 0,
	       		Minute => 0,
	       		Second => 0,
		    );
		    $GetParam{PurchaseTime} = $Self->{TimeObject}->SystemTime2TimeStamp(
		        SystemTime => $GetParam{PurchaseTime},
		    );	    
	    
	    
	   
	    
		
		# update Object 
	    my $ObjectID = $Self->{InventoryObject}->UpdateObject(
			%GetParam,
			ObjectID => $GetParam{ID},
			UserID => $Self->{UserID},
			UserName => $Self->{UserObject}->UserName( UserID =>  $Self->{UserID} ),
		);	
		if ($ObjectID) {
    		# get LogEntry with type info     
        	$Note = $Self->{LogObject}->GetLogEntry(
                    Type => 'Info',
                    What => 'Message',
            );   
            
            # set LogEntry as notify
            $Output .= $Note
            	? $Self->{LayoutObject}->Notify(
		            Priority => 'Info',
		            Info     => $Note,
           		) : '';

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
        	$Note .= $Self->{LogObject}->GetLogEntry(
                    Type => 'Error',
                    What => 'Message',
            );   
            $Output .= $Note
	            ? $Self->{LayoutObject}->Notify(
		            Priority => 'Error',
		            Info     => $Note,
	            )  : '';
            
          	# get edit view
			$Self->_Form(	
				Action => 'Edit',				   
		    	%GetParam,
		    );
        } 
        	
	    $Output .= $Self->{LayoutObject}->Output(
	    	TemplateFile => 'Inventory',
            Data         => \%Param,
        );
        	                 	        	         	             
	    $Output .= $Self->{LayoutObject}->Footer();	       
	    return $Output;		        
	}
	# ------------------------------------------------------------ #
    # Delete: to delete a Notification
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Delete' ) {
		
		my $ObjectID = $Self->{ParamObject}->GetParam( Param => 'ID' );
		
		# delete info into DB
	    my $DeleteObject = $Self->{InventoryObject}->DeleteObject(
			ObjectID => $ObjectID,
			UserName => $Self->{UserObject}->UserName( UserID =>  $Self->{UserID} ),
		);
		
		if ($ObjectID){
			$Note = $Self->{LogObject}->GetLogEntry(
                    Type => 'Info',
                    What => 'Message',
            ); 		
            $Output .= $Note
	          	 ?  $Self->{LayoutObject}->Notify(
		            Priority => 'Info',
		            Info     => $Note,
	            )  : '';
		}
		else{			
			$Note .= $Self->{LogObject}->GetLogEntry(
                    Type => 'Error',
                    What => 'Message',
            );
            $Output .= $Note
	          	 ?  $Self->{LayoutObject}->Notify(
		            Priority => 'Info',
		            Info     => $Note,
	            )  : '';
		}
		
##################### 
#       FEHLT       #
#####################
#
# delete of additional table
#
##################### 
#       FEHLT       #
#####################


		$Self->_Overview();
		
				    
        $Output .= $Self->{LayoutObject}->Output(
            TemplateFile => 'Inventory',
            Data         => \%Param,
        );
		
        $Output .= $Self->{LayoutObject}->Footer();
        return $Output;
	}
		
    # ------------------------------------------------------------ #
    # default view: _Overview - if no subaction is selected        #
    # ------------------------------------------------------------ #
    
    my $Limit = $Self->{ParamObject}->GetParam( Param => 'Limit' ) || '30';
	
    $Output .= $Self->_Overview(Limit => $Limit);
    $Output .= $Self->{LayoutObject}->Output(
       TemplateFile => 'Inventory',
        Data         => \%Param,
    );
    $Output .= $Self->{LayoutObject}->Footer();
    return $Output;  
}

sub _Overview {
	
    my ( $Self, %Param ) = @_;
    
#    $Self->{UserObject}->SetPreferences(
#        Key    => 'UserInventoryOverviewColumn-Typ',
#        Value  => '1',
#        UserID => $Self->{UserID},
#    );
#    
#    my %Preferences = $Self->{UserObject}->GetPreferences(
#        UserID => $Self->{UserID},
#    );
    
    
    # blocks
    $Self->{LayoutObject}->Block( Name => 'FilterObject' );
    $Self->{LayoutObject}->Block(
	            Name => 'Search',
	            Data => {            	
	            	ID => $Param{ID} || 'UB-ID',
					Type => $Param{Type} || 'Type',
					Model => $Param{Model} || 'Model',
					Manufacturer => $Param{Manufacturer} || 'Manufacturer',
					Serialnumber => $Param{Serialnumber} || 'Serialnumber',
					SAP => $Param{SAP}  || 'SAP',
					Room => $Param{Room}  || 'Room',
	            },
	        );
	$Self->{LayoutObject}->Block( Name => 'ActionList' );
    $Self->{LayoutObject}->Block( Name => 'Hint' );    
    $Self->{LayoutObject}->Block( Name => 'Overview' );
    
	my %ObjectList;
    
    if($Param{Action} eq 'Select'){
    	
    	# get GetObjectList
		%ObjectList = $Self->{InventoryObject}->GetObjectList( Key => $Param{Key}, Value => $Param{Value} );
		$Param{ObjectCount} = keys %ObjectList;
		if($Param{Key} eq 'change_by' || $Param{Key} eq 'create_by' ){
			$Param{Value} = $Self->{UserObject}->UserName( UserID =>  $Param{Value} );			
		}
	
    }
    elsif($Param{Action} eq 'Search'){
    	
    	
    	
    	
    	# get GetObjectList  ID Type Model Manufacturer Serialnumber Room)
		%ObjectList = $Self->{InventoryObject}->GetObjectList(	
																ID => $Param{ID} || '%',
																Type => $Param{Type} || '%',
																Model => $Param{Model} || '%',
																Manufacturer => $Param{Manufacturer} || '%',
																Serialnumber => $Param{Serialnumber} || '%',
																SAP => $Param{SAP}  || '%',
																Room => $Param{Room}  || '%',
																Limit => $Param{Limit} ,
																Search => '1'
															);
		$Param{ObjectCount} = keys %ObjectList;
    
    }
    else{
    	
    	# get GetObjectList
		%ObjectList = $Self->{InventoryObject}->GetObjectList( Limit => $Param{Limit});
    	
    }    
    
	for my $ObjectID ( sort { uc( $ObjectList{$a} ) cmp uc( $ObjectList{$b} ) } keys %ObjectList ) {
		
	    # get GetInventoryData       
		my %ObjectData = $Self->{InventoryObject}->GetObjectData( ObjectID => $ObjectID );	
		$ObjectData{ChangeByID} = $ObjectData{ChangeBy};
		$ObjectData{CreateByID} = $ObjectData{CreateBy};
							
		$ObjectData{ChangeBy} = $Self->{UserObject}->UserName( UserID =>  $ObjectData{ChangeBy} );
		$ObjectData{CreateBy} = $Self->{UserObject}->UserName( UserID =>  $ObjectData{CreateBy} );
		
		if ( $ObjectData{SegregationStatus}  eq "off" ) 
	    {
	        $ObjectData{Segregation} = '';
	    }
	    
	    
		
    	$Self->{LayoutObject}->Block(
            Name => 'ObjectList',
            Data => {            	
            	%ObjectData,
            	ID => $ObjectData{ID},				
            },
        );
	}
	
	
		
   
	
	if($Param{Action} eq 'Select'){
    	
    	# get GetObjectList
		%ObjectList = $Self->{InventoryObject}->GetObjectList( Key => $Param{Key}, Value => $Param{Value} );
    	$Self->{LayoutObject}->Block(
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
	
	# blocks
    $Self->{LayoutObject}->Block( Name => 'ActionList' );
    $Self->{LayoutObject}->Block( Name => 'FormHint' ); 
    
    if ( $Param{SegregationStatus}  eq "on" ) 
    {
        $Param{SegregationOn} = 'checked="checked"';
    }
    else
    {
        $Param{SegregationOff} = 'checked="checked"';
        $Param{SegregationYear}		= '2000';
        $Param{SegregationMonth}	= '01';
        $Param{SegregationDay}		= '01';
    } 
          
    $Param{PurchaseTime} = $Self->{LayoutObject}->BuildDateSelection(
    	Prefix 			=> 'PurchaseTime',
    	PurchaseTimeYear			=>	$Param{PurchaseTimeYear}  ,
    	PurchaseTimeMonth			=>	$Param{PurchaseTimeMonth} ,
    	PurchaseTimeDay				=>	$Param{PurchaseTimeDay}  ,
    	Format          => 'DateInputFormat',    	
	);
   	
   	$Param{Segregation} = $Self->{LayoutObject}->BuildDateSelection(
   		Prefix 					=> 'Segregation',
    	SegregationYear			=>	$Param{SegregationYear}  ,
    	SegregationMonth		=>	$Param{SegregationMonth} ,
    	SegregationDay			=>	$Param{SegregationDay}   ,
    	Format                  => 'DateInputFormat',    	
	);
	
	   
 
   
   
        
##################### 
#       TEST        #
#####################     
    
#    $Self->{LayoutObject}->Block(Name => 'Test',);
##    for my $Additional ( @{ $Self->{ConfigObject}->Get('Inventory')->{'Additional'}} )     
##    {
#    
#    	$Self->{LayoutObject}->Block(
#	        Name => 'TestField',
#	        Data
#	        
##	        Data => {
##	        	TEST => $Additional,
##	        },
#	    );  
#    }
#    
#    my %AddionalKeyList = $Self->{InventoryObject}->GetAddionalKeyList( );
#    for my $AddionalKeyListID ( sort { uc( $AddionalKeyList{$a} ) cmp uc( $AddionalKeyList{$b} ) } keys %AddionalKeyList ) {
#		
#
#		
#    	$Self->{LayoutObject}->Block(
#            Name => 'TestFieldAdd',
#            Data => {            	
#            	TESTADD => $AddionalKeyListID,            	
#            },
#        );
#	} 	  
##################### 
#       TEST        #
#####################   
          
         
    # content
    $Self->{LayoutObject}->Block(
        Name => 'Form',
        Data => \%Param,
    );   
    
    if ($Param{ObjectID}){
	    $Self->{LayoutObject}->Block(
	        Name => 'FormObjectID',
	        Data => {
	        	ObjectID => $Param{ObjectID},
			},
	    );	   	
    }
    
    # content header
    if ( $Param{Action} eq 'Add' ) {
    	$Self->{LayoutObject}->Block( Name => 'HeaderAdd' );        
    }
    elsif ( $Param{Action} eq 'Edit' ) {		
        $Self->{LayoutObject}->Block( Name => 'HeaderEdit' );
       $Self->{LayoutObject}->Block( Name => 'AdditionalInformation', Data => \%Param, );
                
    }    
    
            
    # return output
	return;
}

1;