Scriptname ssm extends Quest  

Import StorageUtil

; makes sure that OnInit() will only fire once.
Event OnInit()
	AdjustIntValue(Self, "OnInitCounter", 1)
	If (GetIntValue(Self, "OnInitCounter")) == 2
		zbfSlaveControl SlaveControl = zbfSlaveControl.GetAPI()
		If (SlaveControl)	; if ZAP is installed
			SlaveControl.RegisterForEvents()
		Else
			Debug.Trace("[SSM] ZAP not detected")
		EndIf
	EndIf
EndEvent
