/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   30 Apr 2009 10:16:56  $
    $Workfile:   ReadMe.txt  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\xe4\ReadMe.txt.-arc  $
/*   
/*      Rev 1.1   30 Apr 2009 10:16:56   zf297a
/*   Updated the text with the latest share path's.  Added links to DOS, sqlplus and gawk web pages.
/*   
/*      Rev 1.0   04 Jun 2007 09:59:56   zf297a
/*   Initial revision.
*/

The xe4 utility consists of the following:
	1. The main controlling DOS batch command file with a bat file extension that executes the following:
		a. sqlplus using an Oracle account that has access to the GOLD Data Base Link pgoldlb
			(1) sqlplus runs commands stored in a file with an extension of sql by using the @ symbol 
			followed by the filename minus the sql extension.  The sql file does the following:
				(a) truncates table mils_xe4
		                (b) prompts for a 5 character "from" julian date 
				(c) prompts for a 5 character "to" julian date
				(d) loads table mils_xe4 with data from table mils@pgoldlb and cat1@pgoldlb using
				a select/insert query that filters the mils.status_line by its julian date, sran, and code1
				(e) extract data from the mils_xe4 table and write the data to file0.txt, file1.txt
				and file2.txt using a SELECT query and the sqplus spool command.  
				The spool command overwrites any existing file

		b. gawk using an awk script that replaces blanks that 
		are in columns 56-57 and columns 61-62 with zeros for file file1.txt and outputs newFile1.txt.
		This overwrites any existing newFile1.txt 
		(see http://www.gnu.org/software/gawk/manual/html_node/String-Functions.html#String-Functions
		for information regarding awk's builtin substr string function)
	 


DOS batch file help: http://www.computerhope.com/batch.htm

sqlplus setup:
You must have Oracle sqlplus installed and it must be able to run from the DOS command window.
If the bat file cannot find sqlplus, you must add its location to your Path environment variable by
going to the Control Panel, System, Advanced tab, Environment Variables button, User variables
for <your Window user id>

	Either Edit the existing variable called Path or create a new one.  For an existing
	variable add C:\ORANT\BIN; to the begining of the variable value.  For a new Variable
	name called Path just enter C:\ORANT\BIN for the Variable value.
	Click OK for the Edit User Variable window, click OK for the Environment Variables
	window, and click OK for the System Properties window.

sqlplus frequently asked questsions, FAQS: http://www.orafaq.com/wiki/SQL*Plus

sqlplus commands: http://www.sc.ehu.es/siwebso/KZCC/Oracle_10g_Documentacion/server.101/b10758/sqlqraa.htm


gawk setup:
You must install gawk to it in a DOS batch script.  
To install select start, run... 
Enter \\sw.nos.boeing.com\c17data\data197$\gawk\gawk-3.1.6-1-setup.exe in the Open text box
click OK

Now add C:\Program Files\GNUWin32\gawk\bin to your Environtment Path variable by
going to the Control Panel, System, Advanced tab, Environment Variables button, User variables
for <Window user id>

	Either Edit the existing variable called Path
	add ;C:\Program Files\GNUWin32\gawk\bin to the end of the variable value.
	Click OK for the Edit User Variable window, click OK for the Environment Variables
	window, and click OK for the System Properties window.

gawk (GNU awk) home page:  http://www.gnu.org/software/gawk/
GNU awk's builtin string manipulation functions: http://www.gnu.org/manual/gawk/html_node/String-Functions.html
