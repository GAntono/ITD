Scriptname ssmMain extends Quest

;TODO: Have all properties & variables initiate via a function, to allow them to take new value after version update.

zbfBondageShell Property zbf Auto			;ZAZ Animation Pack zbfBondageShell API.
zbfSlaveControl Property SlaveControl Auto	;ZAZ Animation Pack zbfSlaveControl API.

ReferenceAlias Property PlayerRef Auto
ssmSlave[] Property Slots Auto
Spell Property ssmEnslaveSpell Auto
Int ssmMenuKey = 47	;V key.


Int Property ssm_Menu_Top 						= 1 AutoReadOnly Hidden
Int Property ssm_Menu_Pose 						= 2 AutoReadOnly Hidden

Int Property ssm_action_Open_Menu_Top		 	= 1 AutoReadOnly Hidden
Int Property ssm_action_Open_Bondage_Screen 	= 2 AutoReadOnly Hidden
Int Property ssm_action_Open_Inventory 			= 3 AutoReadOnly Hidden
Int Property ssm_action_Open_Menu_Pose 			= 4 AutoReadOnly Hidden
Int Property ssm_action_Set_Pose_Standing 		= 5 AutoReadOnly Hidden
Int Property ssm_action_Set_Pose_Kneeling 		= 6 AutoReadOnly Hidden
Int Property ssm_action_Set_Pose_Lying 			= 7 AutoReadOnly Hidden

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
		Actor actorRef = Game.GetCurrentCrosshairRef() as Actor
		If actorRef && FindSlot(actorRef)	;if there's something under the crosshair and it's an actor slotted in ssmSlave
			Int iOptionSelected = ShowWheelMenu(ssm_Menu_Top, actorRef)
			Debug.Trace("iOptionSelected: " + iOptionSelected)
			ActOnOptionSelected(iOptionSelected, actorRef)
		EndIf
	EndIf
EndEvent

Int Function ShowWheelMenu(Int aiMenuName, Actor akActor = None)
	If aiMenuName < 1
		Return -1
	EndIf
	;cheat sheet: 
	;UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", index, "")
	;UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "OptionText", index, "")
	;UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", index, True)
	
	UIExtensions.InitMenu("UIWheelMenu")
	If aiMenuName == ssm_Menu_Top
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 0, "Bondage & Attire")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 0, "Bind & Dress")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 0, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 1, "Inventory")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 1, "Give & Take")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 1, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 2, "Poses")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 2, "Pose commands")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 2, True)
		Int iMenuSelected = UIExtensions.OpenMenu(menuName = "UIWheelMenu", akForm = akActor)
		
		If iMenuSelected == 0
			Return ssm_action_Open_Bondage_Screen
		ElseIf iMenuSelected == 1
			Return ssm_action_Open_Inventory
		ElseIf iMenuSelected == 2
			Return ssm_action_Open_Menu_Pose
		EndIf
		
	ElseIf aiMenuName == ssm_Menu_Pose
		Debug.Trace("Entered ssm_Menu_Pose")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 0, "Standing")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "OptionText", 0, "Stand up")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 0, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 1, "Kneeling")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "OptionText", 1, "Kneel")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 1, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 2, "Lying")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "OptionText", 2, "Lie down")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 2, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 3, "Back")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "OptionText", 3, "Back to Top Menu")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 3, True)
		Int iMenuSelected = UIExtensions.OpenMenu(menuName = "UIWheelMenu", akForm = akActor)
		Debug.Trace("iMenuSelected is " + iMenuSelected)

		If iMenuSelected == 0
			Return ssm_action_Set_Pose_Standing
		ElseIf iMenuSelected == 1
			Return ssm_action_Set_Pose_Kneeling
		ElseIf iMenuSelected == 2
			Return ssm_action_Set_Pose_Lying
		ElseIf iMenuSelected == 3
			Return ssm_action_Open_Menu_Top
		EndIf
	EndIf
EndFunction

Function ActOnOptionSelected(Int aiOptionSelected, Actor akActor = None)
	If aiOptionSelected < 1
		Return
	EndIf
	
	If aiOptionSelected == ssm_action_Open_Menu_Top
		ShowWheelMenu(ssm_Menu_Top, akActor)
	ElseIf aiOptionSelected == ssm_action_Open_Bondage_Screen
		FindSlot(akActor).bChangeEquipState = True	;bChangeEquipState is a property in the ssmSlave sub-class of akActor
		akActor.OpenInventory(abForceOpen = True)
	ElseIf aiOptionSelected == ssm_action_Open_Inventory
		FindSlot(akActor).bChangeEquipState = False
		akActor.OpenInventory(abForceOpen = True)
	ElseIf aiOptionSelected == ssm_action_Open_Menu_Pose
		Debug.Trace("Calling Menu Pose")
		ShowWheelMenu(ssm_Menu_Pose, akActor)
		Debug.Trace("Menu Pose called")
	ElseIf aiOptionSelected == ssm_action_Set_Pose_Standing
		FindSlot(akActor).SetPose(zbf.iPoseStanding)
	ElseIf aiOptionSelected == ssm_action_Set_Pose_Kneeling
		FindSlot(akActor).SetPose(zbf.iPoseKneeling)
	ElseIf aiOptionSelected == ssm_action_Set_Pose_Lying
		FindSlot(akActor).SetPose(zbf.iPoseLying)
	EndIf
EndFunction
