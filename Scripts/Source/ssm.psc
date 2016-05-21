Scriptname ssm extends Quest  

Import StorageUtil

ssmSlave[] Property Slots Auto

; makes sure that OnInit() will only fire once.
Event OnInit()
	AdjustIntValue(Self, "OnInitCounter", 1)
	If GetIntValue(Self, "OnInitCounter") == 2
		zbfSlaveControl SlaveControl = zbfSlaveControl.GetAPI()
		If SlaveControl	; if ZAP is installed
			SlaveControl.RegisterForEvents()
		Else
			Debug.Trace("[SSM] ZAP not detected")
		EndIf
	EndIf
EndEvent

ssmSlave Function FindSlot(Actor akActor)
	Int i
	While i < Slots.Length
		If Slots[i].GetReference() == akActor
			Return Slots[i]
		EndIf
		i += 1
	EndWhile
	Return None
EndFunction

ssmSlave Function SlotActor(Actor akActor)
	ssmSlave returnSlot = FindSlot(akActor)
	Int i
	While returnSlot == None && i < Slots.Length
		If Slots[i].GetReference() == None
			Slots[i].ForceRefTo(akActor)
			returnSlot = Slots[i]
		EndIf
		i += 1
	EndWhile
	Return returnSlot
EndFunction
