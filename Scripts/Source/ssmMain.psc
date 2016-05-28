Scriptname ssmMain extends Quest

;TODO: Have all properties & variables initiate via a function, to allow them to take new value after version update.

zbfSlaveControl Property SlaveControl Auto	;ZAZ Animation Pack zbfSlaveControl API.

ReferenceAlias Property PlayerRef Auto
ssmSlave[] Property Slots Auto
Spell Property ssmEnslaveSpell Auto
Int ssmMenuKey = 47	;V key.


Int Property ssm_Menu_Top = 1 AutoReadOnly Hidden

Int Property ssm_action_open_bondage_screen = 1 AutoReadOnly Hidden
Int Property ssm_action_open_inventory = 2 AutoReadOnly Hidden


;makes sure that OnInit() will only fire once.
Event OnInit()
	StorageUtil.AdjustIntValue(Self, "OnInitCounter", 1)
	If StorageUtil.GetIntValue(Self, "OnInitCounter") == 2
		SlaveControl.RegisterForEvents()
		PlayerRef.GetActorReference().AddSpell(ssmEnslaveSpell)
		RegisterForKey(ssmMenuKey)

		StorageUtil.UnsetIntValue(Self, "OnInitCounter")
		Debug.Trace("[SSM] Initialized")
	EndIf
EndEvent

ssmSlave Function FindSlot(Actor akActor)
	If !akActor
		Return None
	EndIf

	Int i
	While i < Slots.Length
		If Slots[i].GetActorReference() == akActor
			Return Slots[i]
		EndIf
		i += 1
	EndWhile
	Return None
EndFunction

ssmSlave Function SlotActor(Actor akActor)
	If !akActor
		Return None
	EndIf

	ssmSlave returnSlot = FindSlot(akActor)
	Int i
	While returnSlot == None && i < Slots.Length
		If Slots[i].GetActorReference() == None
			Slots[i].SetDebugLevel(2)		;for logging purposes
			;Slots[i].ForceRefTo(akActor)	;forces ssmSlave alias to akActor - redundant
			Slots[i].Register(akActor)		;registers akActor in the zbfSlot (sub-class) and the ssmSlave (superclass) systems
			returnSlot = Slots[i]
		EndIf
		i += 1
	EndWhile
	Return returnSlot
EndFunction

Event OnKeyDown(Int Keycode)
	If keycode == ssmMenuKey && !Utility.IsInMenuMode()
		Actor slave = Game.GetCurrentCrosshairRef() as Actor
		If slave && FindSlot(slave)	;if there's something under the crosshair and it's an actor slotted in ssmSlave
			Int iOptionSelected = ShowWheelMenu(ssm_Menu_Top, slave)
			ActOnOptionSelected(iOptionSelected, slave)
		EndIf
	EndIf
EndEvent

Int Function ShowWheelMenu(Int aiMenuName, Actor akActor = None)
	If aiMenuName < ssm_Menu_Top
		Return -1
	EndIf
	;cheat sheet: SetMenuPropertyIndexString(string menuName, string propertyName, int index, string value)
	;cheat sheet: SetMenuPropertyIndexBool(string menuName, string propertyName, int index, bool value)
	
	Int iMenuSelected
	UIExtensions.InitMenu("UIWheelMenu")
	If aiMenuName == ssm_Menu_Top
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 0, "Bondage & Attire")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 1, "Inventory")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 0, "Equip & Unequip")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 1, "Give & Take")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 0, True)
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 1, True)
		iMenuSelected == UIExtensions.OpenMenu(menuName = "UIWheelMenu", akForm = akActor)
		
		If iMenuSelected == 0
			Return ssm_action_open_bondage_screen
		ElseIf iMenuSelected == 1
			Return ssm_action_open_inventory
		EndIf
	EndIf
EndFunction

Function ActOnOptionSelected(Int aiOptionSelected, Actor akActor = None)
	If aiOptionSelected < ssm_action_open_bondage_screen
		Return
	EndIf
	
	If aiOptionSelected == ssm_action_open_bondage_screen
		FindSlot(akActor).bChangeEquipState = True	;bChangeEquipState is a property in the ssmSlave sub-class of akActor
		akActor.OpenInventory(abForceOpen = True)
	ElseIf aiOptionSelected == ssm_action_open_inventory
		FindSlot(akActor).bChangeEquipState = False
		akActor.OpenInventory(abForceOpen = True)
	EndIf
EndFunction
