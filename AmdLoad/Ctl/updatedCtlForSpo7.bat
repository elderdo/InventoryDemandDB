@echo off
if "%1"=="" goto error
> c:\script.txt echo open %1
>> c:\script.txt echo amduser
>> c:\script.txt echo amd444
>> c:\script.txt echo cd /apps/CRON/AMD/SUBMIT
>> c:\script.txt echo put BomDetail.ctl
>> c:\script.txt echo put BomLocationContract.ctl
>> c:\script.txt echo put ConfirmedRequest.ctl
>> c:\script.txt echo put ConfirmedRequestLine.ctl
>> c:\script.txt echo put LPInTransitLoad.ctl
>> c:\script.txt echo put LPOverrideLoad.ctl
>> c:\script.txt echo put LpAttribute.ctl
>> c:\script.txt echo put LpBackorder.ctl
>> c:\script.txt echo put LpDemand.ctl
>> c:\script.txt echo put LpDemandForecast.ctl
>> c:\script.txt echo put LpInTransit.ctl
>> c:\script.txt echo put LpLeadTime.ctl
>> c:\script.txt echo put LpOnHand.ctl
>> c:\script.txt echo put LpOverride.ctl
>> c:\script.txt echo put NetworkPart.ctl
>> c:\script.txt echo put PartCausalType.ctl
>> c:\script.txt echo put PartMtbf.ctl
>> c:\script.txt echo put PartPlannedPart.ctl
>> c:\script.txt echo put SpoPart.ctl
>> c:\script.txt echo put SpoPartLeadTime.ctl
>> c:\script.txt echo put SpoUser.ctl
>> c:\script.txt echo put UserPart.ctl
>> c:\script.txt echo put UserUserType.ctl
start "ftp%1" /w %systemroot%\system32\ftp.exe -s:c:\\script.txt
goto end
:error
echo "You must select hs1189, hs1186, or hs1185"
:end

