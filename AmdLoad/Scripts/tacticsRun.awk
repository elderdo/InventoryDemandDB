BEGIN {
	months["Jan"] = "01"
	months["Feb"] = "02"
	months["Mar"] = "03"
	months["Apr"] = "04"
	months["May"] = "05"
	months["Jun"] = "06"
	months["Jul"] = "07"
	months["Aug"] = "08"
	months["Sep"] =  "09"
	months["Oct"] = "10"
	months["Nov"] = "11"
	months["Dec"] = "12"

	if (CSV=="") {
		CSV="N";
	} 
	if (SHOW_AVG=="") {
		SHOW_AVG="N";
	} 

}


function resetTimes() {
	startRecNum=NR ;
	startRecord=$0 ;
	endTime="00:00:00";
	endSecs=0;
	duration=0;
	hh=0;
	mi=0;
	ss=0;
}

function myMktime(s, cmd,res) {
  cmd="./mktime " s 
  cmd | getline res
  close(cmd)
  return res
}


{
	if (match($0,/^environment/)) {
		# find the time field
		startRec=NR ;
		mm = months[$8]
		dd = $9
		yyyy = $12
		cnt=split($10,a,":")
		startTime=$10
		hh=a[1]
		mi=a[2]
		ss=a[3]
		# use the c app mktime to get the number of seconds
		startSecs = myMktime(yyyy " " mm " " dd " " hh " " mi " " ss)
		resetTimes();
	} else if (match($0,/^tactics   [A-Z][a-z][a-z] /)) {
		startRec=NR ;
		mm = months[$3]
		dd = $4
		yyyy = $7
		cnt=split($5,a,":")
		startTime=$5
		hh=a[1]
		mi=a[2]
		ss=a[3]
		startSecs = myMktime(yyyy " " mm " " dd " " hh " " mi " " ss)
		resetTimes();
	} else if (match($0,/^end of tactics_/)) {
		if (startSecs!=0 && startRecNum!=0) {
			endRecNum=NR ;
			endRecord=$0 ;
			mm = months[$5]
			dd = $6
			yyyy = $9
			cnt=split($7,a,":")
			endTime=$7
			hh=a[1]
			mi=a[2]
			ss=a[3]
			endSecs = myMktime(yyyy " " mm " " dd " " hh " " mi " " ss)
			if (endSecs == 0) {
				print "endSecs=" endSecs
				print "./mktime " yyyy " " mm " " dd " " hh " " mi " " ss 
			}
			duration = endSecs - startSecs ;
			hh = duration/(60*60) ;
			mi = duration%(60*60)/60;
			ss = duration%60; 
			if (endSecs < startSecs) {
				printf("For recs:\n%d. %s\n%d. %s\n end time %s (%d) < %s (%d %d:%d:%d)\n",
					  startRecNum,startRecord,endRecNum,endRecord,endTime,endSecs,startTime,startSecs,a[1],a[2],a[3]) ;
			} else {
				if (CSV=="N") {
					printf("For %s %s %s %s post processing ran for %02d:%02d:%02d\n",$4,$5,$6,$9,hh,mi,ss) ;
				} else if (CSV=="Y") {
					printf("%s/%02d/%s,%02d:%02d:%02d\n",months[$5],$6,$9,hh,mi,ss) ;
				} 
				totrecs++
				totTime=totTime+duration
			}
		} else {
			startSecs = 0 ;
			resetTimes() ;
		}
	}
}
END { 
      avg = totTime / totrecs
      hh = avg/(60*60)
      mi = avg%(60*60)/60
      ss = avg%60
      if (SHOW_AVG=="Y")
      	printf("avgerage run time is %02d:%02d:%02d\n",hh,mi,ss)
}
	
