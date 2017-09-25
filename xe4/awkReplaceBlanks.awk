#        $Author:   zf297a  $
#      $Revision:   1.0  $
#          $Date:   04 Jun 2007 11:47:58  $
#      $Workfile:   awkReplaceBlanks.awk  $

#	This script is used to produce an xe4 file.

{ print substr($0,1,55) "00" substr($0,58,3) "00" substr($0,63,18) }
