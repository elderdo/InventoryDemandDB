#   $Author:   zf297a  $
# $Revision:   1.0  $
#     $Date:   27 Feb 2009 10:04:24  $
# $Workfile:   pErrorLocationAwk.awk  $
#
# This awk procedure resequences the error location number used by
# errorMsg PL/SQL procedures and debug PL/SQL procedures
# using awk or GNU gawk invoke as follows:
# gawk -f pErrorLocationAwk.awk fileIn.txt > fileOut.txt
# where fileIn.txt is the procedure body containing routines using
# numeric variable pError_Location to help track the flow of control
# when recording data to column amd_load_details.data_line_no
#
{ if ($0 ~ /p[Ee]rror_[Ll]ocation[ \t]*=>[ \t]*[0-9]*[ ]*[,)]/) {
	cnt=cnt+10
	sub("p[Ee]rror_[Ll]ocation[ \t]*=>[ \t]*[0-9]*","pError_location => " cnt) 
  }
  print 
}

