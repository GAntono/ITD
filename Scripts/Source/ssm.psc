Scriptname ssm extends Quest

zbfSlaveControl Property SlaveControl Auto	; ZAZ Animation Pack zbfSlaveControl API.

ReferenceAlias Property PlayerRef Auto
ssmSlave[] Property Slots Auto
Spell Property ssmEnslaveSpell Auto
Int Property ssmMenuKey = 47 AutoReadOnly	; V key.

; makes sure that OnInit() will only fire once.
Event OnInit()
	StorageUtil.AdjustIntValue(Self, "OnInitCounter", 1)
	If StorageUtil.GetIntValue(Self, "OnInitCounter") == 2
		If SlaveControl	; if ZAP is installed
			SlaveControl.RegisterForEvents()
		Else
			Debug.Trace("[SSM] ZAP not detected")
		EndIf
		PlayerRef.GetActorReference().AddSpell(ssmEnslaveSpell)
		RegisterForKey(ssmMenuKey)

		StorageUtil.UnsetIntValue(Self, "OnInitCounter")
		Debug.Trace("[SSM] Initialized")
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

Event OnKeyDown(Int Keycode)
	If keycode == ssmMenuKey && Utility.IsInMenuMode() == False
		ObjectReference crossHairRef = Game.GetCurrentCrosshairRef()
		If crossHairRef != None && SlaveControl.IsSlave(crossHairRef as Actor)
			Actor slave = crossHairRef as Actor
			UIExtensions.InitMenu("UIWheelMenu")
			UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 0, "Items")
			Int ssmMenuSelection = UIExtensions.OpenMenu("UIWheelMenu")
			If ssmMenuSelection == 0
				slave.OpenInventory(abForceOpen = True)
			EndIf
		EndIf
	EndIf
EndEvent
