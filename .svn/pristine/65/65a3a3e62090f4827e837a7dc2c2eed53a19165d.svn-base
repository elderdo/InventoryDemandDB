sub batchRun()
	if execBatch("bssmd","c970183", ".\sos.flo", ".\batch.xls") = 0 then
		run App.Path & "\nextJob.bat"
		MsgBox "batchRun competed."
	else
		msgbox "batchRun failed."
	end if
end sub

