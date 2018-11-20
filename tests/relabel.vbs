
Set colArgs = WScript.Arguments
Set fso = CreateObject("Scripting.FileSystemObject")

Set reFileMask = New RegExp
reFileMask.Pattern = "^.*\.Tests\.bat$"
reFileMask.IgnoreCase = True

Set reTestLabel = New RegExp
reTestLabel.Pattern = "^:test \d"
reTestLabel.IgnoreCase = False

If colArgs.Unnamed.Count > 0 Then
	For i = 0 To colArgs.Unnamed.Count - 1
		strFileName = colArgs.Unnamed.Item(i)
		If fso.FileExists(strFileName) Then
			ReDim Preserve arrFiles(UBound(arrFiles) + 1)
			arrFiles(i) = fso.GetFile(strFileName)
		End If
	Next
Else
	Set colFiles = fso.GetFolder(".").Files
	ReDim arrFiles(colFiles.Count - 1)

	intCounter = 0
	For Each objFile In colFiles
		arrFiles(intCounter) = objFile
		intCounter = intCounter + 1
	Next
End If

For Each objFile In fso.GetFolder(".").Files
	strFileFullName = objFile.Path
	strFileName = objFile.Name
	If strFileName <> WScript.ScriptName Then
		If reFileMask.Test(strFileName) Then
			strContent = ""
			strTestNum = 1

			With fso.OpenTextFile(strFileFullName)
				Do Until .AtEndOfStream
					strLine = .ReadLine

					If reTestLabel.Test(strLine) Then
						strContent = strContent & ":test " & strTestNum & vbCrLf
						strTestNum = strTestNum + 1
					Else
						strContent = strContent & strLine & vbCrLf
					End If
				Loop

				.Close
			End With

			strBackupFileName = strFileFullName + ".bak"
			If fso.FileExists(strBackupFileName) Then
				fso.DeleteFile(strBackupFileName)
			End If
			fso.MoveFile strFileFullName, strBackupFileName

			With fso.CreateTextFile(strFileFullName, True)
				.Write(strContent)
				.Close
			End With
		End If
	End If
Next
