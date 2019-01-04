#!/usr/bin/ksh
steps[1]="execSqlplus loadLatestRblRun"
steps[2]="execSqlplus loadCurrentBackOrder"
steps[3]="execSqlplus loadTempNsns"
steps[4]="execSqlplus autoLoadSpareNetworks"
steps[5]="execSqlplus loadAmdBssmSourceTmpAmdDemands"
steps[6]="execSqlplus loadFmsDemands"
steps[7]="execSqlplus loadBascUkDemands"
steps[8]=wait
steps[9]="checkSqlplusErrors 1-7"
steps[10]="execSqlplus loadAmdDemandsTable"
steps[11]="execSqlplus loadGoldInventory"
steps[12]="execSqlplus loadAmdPartLocations"
steps[13]=wait
steps[14]="checkSqlplusErrors 10-12"
steps[15]="execSqlplus loadAmdBaseFromBssmRaw"
steps[16]="execSqlplus updateAmdAllBaseCleaned"
steps[17]="execSqlplus loadAmdReqs"
steps[18]="execSqlplus loadTmpAmdPartFactors"
steps[19]="execSqlplus loadTmpAmdPartLocForecasts_Add"
steps[20]="execSqlplus loadTmpAmdLocPartLeadTime"
steps[21]=wait
steps[22]="checkSqlplusErrors 17-22"
steps[23]=return

 while IFS= read -r func
 do
   if echo "${steps[*]}" | grep -q "$func"
   then
      echo func=$func
      if (($?!=0)) ; then
        echo $func failed
        return
      fi
  else
    echo $func is not a valid step for AmdLoad2.ksh
    exit 4
  fi
 done < loadDemands.txt

