CREATE OR REPLACE package body AMD_OWNER.amd_warnings_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.5  $
     $Date:   30 Jan 2009 15:41:54  $
    $Workfile:   amd_warnings_pkg.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_warnings_pkg.pkb.-arc  $
/*   
/*      Rev 1.5   30 Jan 2009 15:41:54   zf297a
/*   Fixed the lv_str varchar2 size for the split function and made it 2000 ... which would be the max size of concatenated email addresses separated by semicolons
/*   
/*      Rev 1.4   30 Jan 2009 09:14:20   zf297a
/*   Implemented split interface and created toArray function to convert between this package's t_array type to the email_handler_pkg.array type.  Modified sendWarnings to use the email_hander_pkg.send procedure when the to email address contains more than one email address delimitted by a semicolon.
/*   
/*      Rev 1.3   29 Jan 2009 15:01:24   zf297a
/*   Added args to sendWarnings.  Implemented a sendWarnings function that returns the # of current warnings.
/*   
/*   
/*
/*      Rev 1.2   23 Jan 2009 17:57:44   zf297a
/*   Include key_1 to key_5 in the output email.
/*
/*      Rev 1.1   16 Jan 2009 23:26:06   zf297a
/*   AMD 3.7
/*
/*      Rev 1.0   16 Jan 2009 10:56:44   zf297a
/*   Initial revision.

*/

	CRLF constant varchar2(2)   := utl_tcp.CRLF ;

	FUNCTION toArray (arrayIn in t_array) RETURN email_handler_pkg.array 
	is
		strings email_handler_pkg.array := email_handler_pkg.array() ;
	begin
		for i in arrayIn.first .. arrayIn.last loop
			strings.extend ;
			strings(i) := arrayIn(i) ;
		end loop ;
		return strings ;
	end toArray ;
		

	FUNCTION SPLIT (p_in_string VARCHAR2, p_delim VARCHAR2) RETURN t_array 
	IS

		i       number :=0;
		pos     number :=0;
		lv_str  varchar2(2000) := p_in_string;

		strings t_array;

	BEGIN

		-- determine first chuck of string  
		pos := instr(lv_str,p_delim,1,1);

		-- while there are chunks left, loop 
		WHILE ( pos != 0) LOOP

			-- increment counter 
			i := i + 1;

			-- create array element for chuck of string 
			strings(i) := substr(lv_str,1,pos);

			-- remove chunk from string 
			lv_str := substr(lv_str,pos+1,length(lv_str));

			-- determine next chunk 
			pos := instr(lv_str,p_delim,1,1);

			-- no last chunk, add to array 
			IF pos = 0 THEN

				strings(i+1) := lv_str;

			END IF;

		END LOOP;

		-- return array 
		RETURN strings;

	END SPLIT; 

    	-- use this function  to make sure a field never exceeds its max length
	function trimToMax(str IN VARCHAR2, maxLen IN NUMBER) RETURN VARCHAR2 IS
	begin
		 if length(str) >maxLen then
		 	return substr(str,1,maxLen) ;
		 else
		 	 return str ;
		 end if ;
	end TrimToMax ;

	procedure insertWarningMsg (
		pData_line_no IN amd_load_warnings.data_line_no%TYPE := NULL,
		pData_line IN amd_load_warnings.data_line%TYPE := NULL,
		pKey_1 IN amd_load_warnings.key_1%TYPE := NULL,
		pKey_2 IN amd_load_warnings.key_2%TYPE := NULL,
		pKey_3 IN amd_load_warnings.key_3%TYPE := NULL,
		pKey_4 IN amd_load_warnings.key_4%TYPE := NULL,
		pKey_5 IN amd_load_warnings.key_5%TYPE := NULL,
		pWarning IN amd_load_warnings.warning%TYPE := NULL ) IS

		dataLine amd_load_warnings.data_line%TYPE := trimToMax(pData_line,2000) ;
		k1 amd_load_warnings.KEY_1%TYPE := trimToMax(pKey_1,50) ;
		k2 amd_load_warnings.KEY_2%TYPE := trimToMax(pKey_2, 50) ;
		k3 amd_load_warnings.KEY_3%TYPE := trimToMax(pKey_3, 50) ;
		k4 amd_load_warnings.KEY_4%TYPE := trimToMax(pKey_4, 40) ;
		k5 amd_load_warnings.KEY_5%TYPE := trimToMax(pKey_5, 50) ;
		msg amd_load_warnings.warning%TYPE := trimToMax(pWarning, 2000) ;

	BEGIN

		 IF msg IS NULL THEN
		 	msg := SUBSTR('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')',1,2000) ;
		 END IF ;
		insert into amd_load_warnings
		(
			load_no,
			data_line_no,
			data_line,
			key_1,
			key_2,
			key_3,
			key_4,
			key_5,
			warning
		)
		VALUES
		(
		 	amd_load_warnings_seq.NEXTVAL,
			pData_line_no,
			dataLine,
			k1,
			k2,
			k3,
			k4,
			k5,
			msg
		);
	exception when others then
		  dbms_output.enable(100000) ;
		  if not amd_utils.isNumber(to_char(dataLine)) then
		  	 dbms_output.put_line('dataLine is not a number') ;
		  end if ;
		  dbms_output.put_line('k1=' || k1) ;
		  dbms_output.put_line('k2=' || k2) ;
		  dbms_output.put_line('k3=' || k3) ;
		  dbms_output.put_line('k4=' || k4) ;
		  dbms_output.put_line('k5=' || k5) ;
		  dbms_output.put_line('msg=' || msg) ;

          raise_application_error(-20010,
                substr('amd_warnings_pkg '
                    || sqlcode || ' '
                    || dataLine || ' '
                    || k1 || ' '
                    || k2 || ' '
                    || k3 || ' '
                    || k4 || ' '
                    || k5 || ' '
                    || msg, 1,2000)) ;

	END insertWarningMsg;

	procedure addWarnings(warning in varchar2) is
	begin
		insertWarningMsg(pWarning => warning ) ;
	end addWarnings ;

	function warningsExistForCurJob return boolean is
		cnt number ;
	begin
		select count(*) into cnt
		from amd_load_warnings
		where last_update_dt >= amd_batch_pkg.getLastStartTime ;
		if cnt > 0 then
			return true ;
		else
			return false ;
		end if ;
	end warningsExistForCurJob ;

	function warningsExistForCurJobYorN return varchar2 is
	begin
		if warningsExistForCurJob then
			return 'Y' ;
		else
			return 'N' ;
		end if ;
	end warningsExistForCurJobYorN ;

	function sendWarnings(toEmailAddr in varchar2, subject in varchar2 := 'AMD Load Warnings',
        fromEmailAddr in varchar2 := 'AMDLOAD') return number is
		cnt number ;
	begin
		sendWarnings(toEmailAddr, subject, fromEmailAddr) ;

		select count(*) into cnt
		from amd_load_warnings
		where last_update_dt >= amd_batch_pkg.getLastStartTime ;

		return cnt ;

	end sendWarnings ;

	procedure append(target in out varchar2, text in varchar2) is
	begin
		null ;
	end append ;

	function toLong(text in varchar2) return long is
		msg long := text ;
	begin
		return msg ;
	end toLong ;

   	procedure sendWarnings(toEmailAddr in varchar2, subject in varchar2 := 'AMD Load Warnings',
	        fromEmailAddr in varchar2 := 'AMDLOAD') is

		cursor currentWarnings is
		select distinct data_line,key_1,key_2,key_3,key_4,key_5,warning from amd_load_warnings
		where last_update_dt >= amd_batch_pkg.getLastStartTime ;

		msgBody varchar2(32000) := '<h2>This is a system generated message. DO NOT REPLY.</h2><br><ul>';
		cnt number := 0 ;
		global_name varchar2(30) ;

	begin
		for rec in currentWarnings loop
		    msgBody := msgBody || '<li>' ||  rec.data_line || ': ' ;
		    if rec.key_1 is not null then
			    msgBody := msgBody || rec.key_1 || ' ' ;
		    end if ;
		    if rec.key_2 is not null then
			    msgBody := msgBody || rec.key_2 || ' ' ;
		    end if ;
		    if rec.key_3 is not null then
			    msgBody := msgBody || rec.key_3 || ' ' ;
		    end if ;
		    if rec.key_4 is not null then
			    msgBody := msgBody || rec.key_4 || ' ' ;
		    end if ;
		    if rec.key_5 is not null then
			    msgBody := msgBody || rec.key_5 || ' ' ;
		    end if ;
		    msgBody := msgBody || '..' || rec.warning || '</li>' ;
		    cnt := cnt + 1 ;
		end loop ;

		if cnt > 0 then
			msgBody := msgBody || '</ul>' ;
			if instr(toEmailAddr,';') > 0 then
				select lower(global_name) into global_name from global_name ;
				email_handler_pkg.send
					( p_sender_email => 'amdload@' || global_name,
					p_from => 'AMD LOAD <amdload@' || global_name || '>',
					p_to => toArray( split(toEmailAddr,';')),
					p_cc => email_handler_pkg.array(),
					p_bcc => email_handler_pkg.array(),
					p_subject => sendWarnings.subject,
					p_body => toLong(msgBody) ) ;
			else
				email_handler_pkg.send_email(subject => sendWarnings.subject,
					to_userid => toEmailAddr,
					v_body => msgBody,
					from_name => fromEmailAddr) ;
			end if ;
		end if ;

	end sendWarnings ;


end amd_warnings_pkg ;
/
