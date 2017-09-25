CREATE OR REPLACE PACKAGE AMD_OWNER.email_handler_pkg is 

/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   23 Jan 2009 17:59:06  $
    $Workfile:   EMAIL_HANDLER_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\EMAIL_HANDLER_PKG.pks.-arc  $
/*   
/*      Rev 1.1   23 Jan 2009 17:59:06   zf297a
/*   Added interface for a more flexible send procedure
/*   
/*      Rev 1.0   16 Jan 2009 11:02:16   zf297a
/*   Initial revision.
*/

	type array is table of varchar2(255);
  
	procedure send( p_sender_email in varchar2,
		p_from         in varchar2,
		p_to           in array default array(),
		p_cc           in array default array(),
		p_bcc          in array default array(),
		p_subject      in varchar2,
		p_body         in long );

    procedure send_email(subject in varchar2, 
        to_userid in varchar2 := NULL, 
        v_body in varchar2 := NULL, 
        from_name in varchar2 := NULL, 
        to_name in varchar2 := NULL, 
        content_type in varchar2 := NULL); 

end email_handler_pkg ;
/
