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
    # Add: to add a Notification
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Add' ) {
		
		
		
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
		for my $Parameter (qw(Type Model Manufacturer Serialnumber Year Month Day Comment)) {
	       	$GetParam{$Parameter} = $Self->{ParamObject}->GetParam( Param => $Parameter ) || '';      
		} 
		$GetParam{PurchaseTime} =  $Self->{TimeObject}->Date2SystemTime(
	        Year   => $GetParam{Year},
	        Month  => $GetParam{Month},
	        Day    => $GetParam{Day},
	        Hour   => $GetParam{Hour} 	|| 0,
	        Minute => $GetParam{Minute} || 0,
	        Second => $GetParam{Second} || 0,
	    );
	    $GetParam{PurchaseTime} = $Self->{TimeObject}->SystemTime2TimeStamp(
	        SystemTime => $GetParam{PurchaseTime},
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
	    ($ObjectData{Sec}, $ObjectData{Min}, $ObjectData{Hour}, $ObjectData{Day}, $ObjectData{Month}, $ObjectData{Year}, $ObjectData{WeekDay}) = $Self->{TimeObject}->SystemTime2Date(
	        SystemTime => $ObjectData{PurchaseTime},
	    );


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
		for my $Parameter (qw(ID Type Model Manufacturer Serialnumber Year Month Day Comment)) {
	     	$GetParam{$Parameter} = $Self->{ParamObject}->GetParam( Param => $Parameter ) || '';      
		}	
		$GetParam{PurchaseTime} =  $Self->{TimeObject}->Date2SystemTime(
	        Year   => $GetParam{Year},
	        Month  => $GetParam{Month},
	        Day    => $GetParam{Day},
	        Hour   => $GetParam{Hour} 	|| 0,
	        Minute => $GetParam{Minute} || 0,
	        Second => $GetParam{Second} || 0,
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

            # get link view
			$Self->_Overview();      		
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
    
    
    $Output .= $Self->_Overview();
    $Output .= $Self->{LayoutObject}->Output(
       TemplateFile => 'Inventory',
        Data         => \%Param,
    );
    $Output .= $Self->{LayoutObject}->Footer();
    return $Output;  
}

sub _Overview {
	
    my ( $Self, %Param ) = @_;
    
    # blocks
    $Self->{LayoutObject}->Block( Name => 'FilterObject' );
	$Self->{LayoutObject}->Block( Name => 'ActionList' );
    $Self->{LayoutObject}->Block( Name => 'Hint' );
    
    $Self->{LayoutObject}->Block( Name => 'Overview' );
    
    # get GetObjectList
	my %ObjectList = $Self->{InventoryObject}->GetObjectList( Limit => '30');
	for my $ObjectID ( sort { uc( $ObjectList{$a} ) cmp uc( $ObjectList{$b} ) } keys %ObjectList ) {
		
	    # get GetInventoryData       
		my %ObjectData = $Self->{InventoryObject}->GetObjectData( ObjectID => $ObjectID );	
		$ObjectData{ChangeBy} = $Self->{UserObject}->UserName( UserID =>  $ObjectData{ChangeBy} );
		$ObjectData{CreateBy} = $Self->{UserObject}->UserName( UserID =>  $ObjectData{CreateBy} );
		
    	$Self->{LayoutObject}->Block(
            Name => 'ObjectList',
            Data => {            	
            	%ObjectData,
            	ID => $ObjectID,
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
        
        
    $Param{PurchaseTime} = $Self->{LayoutObject}->BuildDateSelection(
    	Year			=>	$Param{Year},
    	Month			=>	$Param{Month},
    	Day				=>	$Param{Day},
    	Format          => 'DateInputFormat',    	
	);
   
   
        
##################### 
#       TEST        #
#####################     
    
    $Self->{LayoutObject}->Block(Name => 'Test',);
    for my $Additional ( @{ $Self->{ConfigObject}->Get('Inventory')->{'Additional'}} )     
    {
    
    	$Self->{LayoutObject}->Block(
	        Name => 'TestField',
	        Data => {
	        	TEST => $Additional,
	        },
	    );  
    }
    
    my %AddionalKeyList = $Self->{InventoryObject}->GetAddionalKeyList( );
    for my $AddionalKeyListID ( sort { uc( $AddionalKeyList{$a} ) cmp uc( $AddionalKeyList{$b} ) } keys %AddionalKeyList ) {
		

		
    	$Self->{LayoutObject}->Block(
            Name => 'TestFieldAdd',
            Data => {            	
            	TESTADD => $AddionalKeyListID,            	
            },
        );
	} 	  
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
#        $Self->{LayoutObject}->Block( Name => 'AdditionalInformation', Data => \%Param, );
                
    }    
    
            
    # return output
	return;
}

1;