Scriptname ssmMain extends Quest

;TODO: Have all properties & variables initialize via a function, to allow them to take new value after version update.

zbfBondageShell Property zbf Auto			;ZAZ Animation Pack zbfBondageShell API.
zbfSlaveControl Property SlaveControl Auto	;ZAZ Animation Pack zbfSlaveControl API.

ReferenceAlias Property PlayerRef Auto
ssmSlave[] Property Slots Auto
Spell Property ssmEnslaveSpell Auto


Int Property ssmMenuKey  						Auto Hidden

Int Property ssm_Menu_Top 						Auto Hidden
Int Property ssm_Menu_Pose 						Auto Hidden

Int Property ssm_command_Open_Menu_Top		 	Auto Hidden
Int Property ssm_command_Open_Bondage_Screen 	Auto Hidden
Int Property ssm_command_Open_Inventory 		Auto Hidden
Int Property ssm_command_Open_Menu_Pose 		Auto Hidden
Int Property ssm_command_Set_Pose_Standing 		Auto Hidden
Int Property ssm_command_Set_Pose_Kneeling 		Auto Hidden
Int Property ssm_command_Set_Pose_Lying 		Auto Hidden

;makes sure that OnInit() will only fire once.
Event OnInit()
	StorageUtil.AdjustIntValue(Self, "OnInitCounter", 1)
	If StorageUtil.GetIntValue(Self, "OnInitCounter") == 2
		InitValues()
		SlaveControl.RegisterForEvents()
		PlayerRef.GetActorReference().AddSpell(ssmEnslaveSpell)
		RegisterForKey(ssmMenuKey)

		StorageUtil.UnsetIntValue(Self, "OnInitCounter")
		Debug.Trace("[SSM] Initialized")
	EndIf
EndEvent

;Initializing properties in a function to allow for version updates
Function InitValues()
	ssmMenuKey  						= 47	;V key

	ssm_Menu_Top 						= 1
	ssm_Menu_Pose 						= 2

	ssm_command_Open_Menu_Top		 	= 1
	ssm_command_Open_Bondage_Screen 	= 2
	ssm_command_Open_Inventory 			= 3
	ssm_command_Open_Menu_Pose 			= 4
	ssm_command_Set_Pose_Standing 		= 5
	ssm_command_Set_Pose_Kneeling 		= 6
	ssm_command_Set_Pose_Lying 			= 7
EndFunction

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
			OpenWheelMenu(ssm_Menu_Top, actorRef)
		EndIf
	EndIf
EndEvent

Function OpenWheelMenu(Int aiMenuName, Actor akActor = None)
	If aiMenuName < 1
		Return
	EndIf
	;cheat sheet:
	;UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", index, "")
	;UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "OptionText", index, "")
	;UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", index, True)

	Int iMenuSelected
	UIExtensions.InitMenu("UIWheelMenu")
	If aiMenuName == ssm_Menu_Top
		Bool bPoseMenuEnabled = True
		If zbf.GetBindTypeFromWornKeywords(akActor) == zbf.iBindUnbound	;if the actor is not bound, she doesn't pose
			bPoseMenuEnabled = False
		EndIf
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 0, "Bondage & Attire")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 0, "Bind & Dress")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 0, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 1, "Inventory")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 1, "Give & Take")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 1, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 2, "Poses")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 2, "Pose commands")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 2, bPoseMenuEnabled)
		iMenuSelected = UIExtensions.OpenMenu(menuName = "UIWheelMenu", akForm = akActor)

		If iMenuSelected == 0
			ExecuteWheelCommand(ssm_command_Open_Bondage_Screen, akActor)
			Return
		ElseIf iMenuSelected == 1
			ExecuteWheelCommand(ssm_command_Open_Inventory, akActor)
			Return
		ElseIf iMenuSelected == 2
			ExecuteWheelCommand(ssm_command_Open_Menu_Pose, akActor)
			Return
		EndIf

	ElseIf aiMenuName == ssm_Menu_Pose
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
		iMenuSelected = UIExtensions.OpenMenu(menuName = "UIWheelMenu", akForm = akActor)

		If iMenuSelected == 0
			ExecuteWheelCommand(ssm_command_Set_Pose_Standing, akActor)
			Return
		ElseIf iMenuSelected == 1
			ExecuteWheelCommand(ssm_command_Set_Pose_Kneeling, akActor)
			Return
		ElseIf iMenuSelected == 2
			ExecuteWheelCommand(ssm_command_Set_Pose_Lying, akActor)
			Return
		ElseIf iMenuSelected == 3
			ExecuteWheelCommand(ssm_command_Open_Menu_Top, akActor)
			Return
		EndIf
	EndIf
EndFunction

Function ExecuteWheelCommand(Int aiCommand, Actor akActor = None)
	If aiCommand < 1
		Return
	EndIf

	If aiCommand == ssm_command_Open_Menu_Top
		OpenWheelMenu(ssm_Menu_Top, akActor)
	ElseIf aiCommand == ssm_command_Open_Bondage_Screen
		FindSlot(akActor).bChangeEquipState = True	;bChangeEquipState is a property in the ssmSlave sub-class of akActor
		akActor.OpenInventory(abForceOpen = True)
	ElseIf aiCommand == ssm_command_Open_Inventory
		FindSlot(akActor).bChangeEquipState = False
		akActor.OpenInventory(abForceOpen = True)
	ElseIf aiCommand == ssm_command_Open_Menu_Pose
		OpenWheelMenu(ssm_Menu_Pose, akActor)
	ElseIf aiCommand == ssm_command_Set_Pose_Standing
		FindSlot(akActor).SetPose(zbf.iPoseStanding)
	ElseIf aiCommand == ssm_command_Set_Pose_Kneeling
		FindSlot(akActor).SetPose(zbf.iPoseKneeling)
	ElseIf aiCommand == ssm_command_Set_Pose_Lying
		FindSlot(akActor).SetPose(zbf.iPoseLying)
	EndIf
EndFunction
