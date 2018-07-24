
Set colArgs = WScript.Arguments
Set fso = CreateObject("Scripting.FileSystemObject")

Set reFileMask = New RegExp
reFileMask.Pattern = "^.*\.Tests\.bat$"
reFileMask.IgnoreCase = True

Set reTestLabel = New RegExp
reTestLabel.Pattern = "^:test \d"
reTestLabel.IgnoreCase = False

Dim arrFiles
arrFiles = Array()

If colArgs.Unnamed.Count > 0 Then
	For i = 0 To colArgs.Unnamed.Count - 1
		strFileName = colArgs.Unnamed.Item(i)
		If fso.FileExists(strFileName) Then
			ReDim Preserve arrFiles(UBound(arrFiles) + 1)
			arrFiles(i) = fso.GetFile(strFileName)
		End If
	Next
Else
	Set objFiles = fso.GetFolder(".").Files
	ReDim arrFiles(objFiles.Count - 1)

	intCounter = 0
	For Each objFile In objFiles
		arrFiles(intCounter) = objFile
		intCounter = intCounter + 1
	Next
End If

For Each objFile In fso.GetFolder(".").Files
	strFileName = objFile.Name
	If strFileName <> WScript.ScriptName Then
		If reFileMask.Test(strFileName) Then
			strContent = ""
			strTestNum = 1

			With fso.OpenTextFile(objFile.Path)
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

			With fso.CreateTextFile(objFile.Path, True)
				.Write(strContent)
				.Close
			End With
		End If
	End If
Next
