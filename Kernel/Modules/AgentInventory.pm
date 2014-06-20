# --
# Kernel/Modules/Inventory.pm - frontend module
# Copyright (C) (2014) (Denny Bresch) (dennybresch@gmail.com) (https://github.com/dennybresch)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::Inventory;

use strict;
use warnings;

use Kernel::System::Inventory;


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
	$Self->{LayoutObject}->Block( Name => 'ActionList' );
    $Self->{LayoutObject}->Block( Name => 'Hint' );
    
    # content
    $Self->{LayoutObject}->Block( Name => 'Overview' );
    
    return;
}  	

1;