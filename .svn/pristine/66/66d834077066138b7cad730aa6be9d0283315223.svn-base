CREATE OR REPLACE PACKAGE BODY AMD_OWNER.email_handler_pkg  is

/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   10 Apr 2009 15:31:08  $
    $Workfile:   email_handler_pkg.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\EMAIL_HANDLER_PKG.pkb.-arc  $
/*
/*      Rev 1.4   07 Apr 2009 23:58:22   zf297a
/*   Add time zone to Date: email sent.
/*
/*      Rev 1.3   18 Feb 2009 08:15:10   zf297a
/*   Change the content type to html for the send procedure.
/*
/*      Rev 1.2   30 Jan 2009 09:17:50   zf297a
/*   Fixed address_email function
/*
/*      Rev 1.1   23 Jan 2009 17:59:24   zf297a
/*   Implemented interface for a more flexible send procedure
/*
/*      Rev 1.0   16 Jan 2009 11:02:16   zf297a
/*   Initial revision.
*/


	g_crlf        char(2) default chr(13)||chr(10);
	g_mail_conn   utl_smtp.connection;
	g_mailhost    varchar2(255) := 'relay.boeing.com';

	function address_email( p_string in varchar2,
		p_recipients in array ) return varchar2 is
		l_recipients long;
	begin
		for i in 1 .. p_recipients.count loop
            dbms_output.put_line(p_recipients(i)) ;
			utl_smtp.rcpt(g_mail_conn, p_recipients(i) );
			if ( l_recipients is null ) then
				l_recipients := p_string || p_recipients(i) ;
			else
				l_recipients := l_recipients || ', ' || p_recipients(i);
			end if;
		end loop;
		return l_recipients;
    exception when others then
        dbms_output.put_line('sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm) ;
        return '' ;
	end address_email ;

	procedure send( p_sender_email in varchar2,
		p_from         in varchar2,
		p_to           in array default array(),
		p_cc           in array default array(),
		p_bcc          in array default array(),
		p_subject      in varchar2,
		p_body         in long )
	is
		l_to_list   long;
		l_cc_list   long;
		l_bcc_list  long;
		l_date      varchar2(255) default
        to_char(systimestamp,'dd Mon yy hh24:mi:ss tzr tzd') ;
				--to_char( SYSDATE, 'dd Mon yy hh24:mi:ss' );

		procedure writeData( p_text in varchar2 )
		as
		begin
			if ( p_text is not null )
			then
				utl_smtp.write_data( g_mail_conn, p_text || g_crlf );
			end if;
		end writeData ;

	begin
		g_mail_conn := utl_smtp.open_connection(g_mailhost, 25);

		utl_smtp.helo(g_mail_conn, g_mailhost);
		utl_smtp.mail(g_mail_conn, p_sender_email);

		l_to_list  := address_email( 'To: ', p_to );
		l_cc_list  := address_email( 'Cc: ', p_cc );
		l_bcc_list := address_email( 'Bcc: ', p_bcc );

		utl_smtp.open_data(g_mail_conn );

		writeData( 'Date: ' || l_date );
		writeData( 'From: ' || nvl( p_from, p_sender_email ) );
		writeData( 'Subject: ' || nvl( p_subject, '(no subject)' ) );
		writeData('Content-Type: text/html');

		writeData( l_to_list );
		writeData( l_cc_list );

		utl_smtp.write_data( g_mail_conn, '' || g_crlf );
		utl_smtp.write_data(g_mail_conn, p_body );
		utl_smtp.close_data(g_mail_conn );
		utl_smtp.quit(g_mail_conn);

	end send ;


	procedure send_email(subject in varchar2,
		to_userid in varchar2 := NULL,
		v_body in varchar2 := NULL,
		from_name in varchar2 := NULL,
		to_name in varchar2 := NULL,
		content_type in varchar2 := NULL) IS

		c utl_smtp.connection;
		-- from_userid varchar2(40) := 'webmaster@boeing.com';
		from_userid varchar2(40) := 'amdload@mail.boeing.com';
		send_user varchar2(40);
		from_domain VARCHAR2(200) := SUBSTR(from_userid,INSTR(from_userid,'@')+1);
		smtp_server varchar2(50) := 'mail.boeing.com';
		my_body varchar2(32000);

		procedure header(name varchar2, value varchar2) is
		begin
			utl_smtp.write_data(c, name || ': ' || value || utl_tcp.CRLF);
		end header ;

	BEGIN

		if to_userid is null then
			send_user := user || '@boeing.com';
		else
			send_user := to_userid;
		end if;

		my_body := v_body;

		c := utl_smtp.open_connection(smtp_server);
		utl_smtp.helo(c, from_domain );
		utl_smtp.mail(c, from_userid );
		utl_smtp.rcpt(c, send_user );
		utl_smtp.open_data(c);

		header('From','"'|| NVL(from_name,from_userid)
			||'" <'||from_userid||'>');  header('To','"'
			||NVL(to_name,to_userid)||'" <'||to_userid||'>');

		header('Subject', subject );
		header('Content-Type', NVL(content_type,'text/html'));
		utl_smtp.write_data(c, utl_tcp.CRLF || my_body );
		utl_smtp.close_data(c);
		utl_smtp.quit(c);

	EXCEPTION WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
		utl_smtp.quit(c);

	end send_email;

end email_handler_pkg ;
/