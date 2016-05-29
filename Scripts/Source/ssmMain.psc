Scriptname ssmMain extends Quest

;TODO: Have all properties & variables initialize via a function, to allow them to take new value after version update.

zbfBondageShell Property zbf Auto			;ZAZ Animation Pack zbfBondageShell API.
zbfSlaveControl Property SlaveControl Auto	;ZAZ Animation Pack zbfSlaveControl API.

ReferenceAlias Property PlayerRef Auto
ssmSlave[] Property Slots Auto
Spell Property ssmEnslaveSpell Auto
Faction Property ssmIdleMarkersNotAllowedFaction Auto
Faction Property ssmStrugglingFaction Auto

Int Property ssmMenuKey  							Auto Hidden

Int Property ssm_menu_Top 							Auto Hidden
Int Property ssm_menu_Pose 							Auto Hidden
Int Property ssm_menu_Orders						Auto Hidden

Int Property ssm_command_OpenTopMenu		 		Auto Hidden
Int Property ssm_command_OpenBondageScreen 			Auto Hidden
Int Property ssm_command_OpenInventory 				Auto Hidden
Int Property ssm_command_OpenPoseMenu 				Auto Hidden
Int Property ssm_command_SetPoseStanding 			Auto Hidden
Int Property ssm_command_SetPoseKneeling 			Auto Hidden
Int Property ssm_command_SetPoseLying 				Auto Hidden
Int Property ssm_command_ToggleStruggling			Auto Hidden
Int Property ssm_command_OpenOrdersMenu				Auto Hidden
Int Property ssm_command_ToggleIdleMarkersUse 		Auto Hidden
Int Property ssm_command_ToggleDoingFavor			Auto Hidden

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
	ssmMenuKey  							= 47	;V key

	ssm_menu_Top 							= 1
	ssm_menu_Pose 							= 2
	ssm_menu_Orders							= 3

	ssm_command_OpenTopMenu		 			= 1
	ssm_command_OpenBondageScreen 			= 2
	ssm_command_OpenInventory 				= 3
	ssm_command_OpenPoseMenu 				= 4
	ssm_command_SetPoseStanding 			= 5
	ssm_command_SetPoseKneeling 			= 6
	ssm_command_SetPoseLying 				= 7
	ssm_command_ToggleStruggling			= 9
	ssm_command_OpenOrdersMenu				= 10
	ssm_command_ToggleIdleMarkersUse		= 11
	ssm_command_ToggleDoingFavor			= 12
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

;initialize factions that may exist on the slave
Function InitializeSlave(Actor akActor)
	If !akActor
		Return
	EndIf
	
	akActor.RemoveFromFaction(ssmIdleMarkersNotAllowedFaction)
	akActor.RemoveFromFaction(ssmStrugglingFaction)
EndFunction

Event OnKeyDown(Int Keycode)
	If keycode == ssmMenuKey && !Utility.IsInMenuMode()
		Actor actorRef = Game.GetCurrentCrosshairRef() as Actor
		If actorRef && FindSlot(actorRef)	;if there's something under the crosshair and it's an actor slotted in ssmSlave
			OpenWheelMenu(ssm_menu_Top, actorRef)
		EndIf
	EndIf
EndEvent

Function OpenWheelMenu(Int aiMenuName, Actor akActor = None)
	If aiMenuName < 1
		Return
	EndIf
	;cheat sheet:
	;UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", index, "")
	;UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", index, "")
	;UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", index, True)

	Int iMenuSelected
	UIExtensions.InitMenu("UIWheelMenu")
	If aiMenuName == ssm_menu_Top
		Bool bPoseMenuEnabled = True
		If zbf.GetBindTypeFromWornKeywords(akActor) == zbf.iBindUnbound	;if the actor is not bound, she doesn't pose
			bPoseMenuEnabled = False
		EndIf
		String optionLabelText_ToggleDoingFavor = "Command"
		String optionText_ToggleDoingFavor = "Issue a command"
		If akActor.IsDoingFavor()
			optionLabelText_ToggleDoingFavor = "Cancel command"
			optionText_ToggleDoingFavor = "I changed my mind"
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
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 3, "Orders")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 3, "Slave orders")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 3, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 4, optionLabelText_ToggleDoingFavor)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 4, optionText_ToggleDoingFavor)
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 4, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 5, "Follow/Wait")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 5, "Follow/Wait")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 5, True)
		
		iMenuSelected = UIExtensions.OpenMenu(menuName = "UIWheelMenu", akForm = akActor)

		If iMenuSelected == 0
			ExecuteWheelCommand(ssm_command_OpenBondageScreen, akActor)
		ElseIf iMenuSelected == 1
			ExecuteWheelCommand(ssm_command_OpenInventory, akActor)
		ElseIf iMenuSelected == 2
			ExecuteWheelCommand(ssm_command_OpenPoseMenu, akActor)
		ElseIf iMenuSelected == 3
			ExecuteWheelCommand(ssm_command_OpenOrdersMenu, akActor)
		ElseIf iMenuSelected == 4
			ExecuteWheelCommand(ssm_command_ToggleDoingFavor, akActor)
		EndIf

	ElseIf aiMenuName == ssm_menu_Pose
		String optionLabelText_ToggleStruggling = "Struggle"
		String optionText_ToggleStruggling = "Struggle for me"
		If akActor.IsInFaction(ssmStrugglingFaction)
			optionLabelText_ToggleStruggling = "Stop struggling"
			optionText_ToggleStruggling = "Stop struggling"
		EndIf
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 0, "Standing")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 0, "Stand up")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 0, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 1, "Kneeling")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 1, "Kneel")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 1, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 2, "Lying")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 2, "Lie down")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 2, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 4, "Back")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 4, "Back to Top Menu")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 4, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 7, optionLabelText_ToggleStruggling)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 7, optionLabelText_ToggleStruggling)
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 7, True)
		
		iMenuSelected = UIExtensions.OpenMenu(menuName = "UIWheelMenu", akForm = akActor)

		If iMenuSelected == 0
			ExecuteWheelCommand(ssm_command_SetPoseStanding, akActor)
		ElseIf iMenuSelected == 1
			ExecuteWheelCommand(ssm_command_SetPoseKneeling, akActor)
		ElseIf iMenuSelected == 2
			ExecuteWheelCommand(ssm_command_SetPoseLying, akActor)
		ElseIf iMenuSelected == 4
			ExecuteWheelCommand(ssm_command_OpenTopMenu, akActor)
		ElseIf iMenuSelected == 7
			ExecuteWheelCommand(ssm_command_ToggleStruggling, akActor)
		EndIf
		
	ElseIf aiMenuName == ssm_menu_Orders
		String optionLabelText_ToggleIdleMarkersUse = "No sitting"
		String optionText_ToggleIdleMarkersUse = "Don't use furniture"
		If akActor.IsInFaction(ssmIdleMarkersNotAllowedFaction)
			optionLabelText_ToggleIdleMarkersUse = "Sitting allowed"
			optionText_ToggleIdleMarkersUse = "You may sit"
		EndIf
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 0, optionLabelText_ToggleIdleMarkersUse)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 0, optionText_ToggleIdleMarkersUse)
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 0, True)
		
		iMenuSelected = UIExtensions.OpenMenu(menuName = "UIWheelMenu", akForm = akActor)
		
		If iMenuSelected == 0
			ExecuteWheelCommand(ssm_command_ToggleIdleMarkersUse, akActor)
		EndIf
	EndIf
EndFunction

Function ExecuteWheelCommand(Int aiCommand, Actor akActor = None)
	If aiCommand < 1
		Return
	EndIf

	If aiCommand == ssm_command_OpenTopMenu
		OpenWheelMenu(ssm_menu_Top, akActor)
	ElseIf aiCommand == ssm_command_OpenBondageScreen
		FindSlot(akActor).bChangeEquipState = True	;bChangeEquipState is a property in the ssmSlave sub-class of akActor
		akActor.OpenInventory(abForceOpen = True)
	ElseIf aiCommand == ssm_command_OpenInventory
		FindSlot(akActor).bChangeEquipState = False
		akActor.OpenInventory(abForceOpen = True)
	ElseIf aiCommand == ssm_command_OpenPoseMenu
		OpenWheelMenu(ssm_menu_Pose, akActor)
	ElseIf aiCommand == ssm_command_SetPoseStanding
		FindSlot(akActor).SetPose(zbf.iPoseStanding)
	ElseIf aiCommand == ssm_command_SetPoseKneeling
		FindSlot(akActor).SetPose(zbf.iPoseKneeling)
	ElseIf aiCommand == ssm_command_SetPoseLying
		FindSlot(akActor).SetPose(zbf.iPoseLying)
	ElseIf aiCommand == ssm_command_ToggleStruggling
		If akActor.IsInFaction(ssmStrugglingFaction)
			FindSlot(akActor).SetStruggle(abStruggle = False)
			akActor.RemoveFromFaction(ssmStrugglingFaction)
		Else
			FindSlot(akActor).SetStruggle(abStruggle = True)
			akActor.AddToFaction(ssmStrugglingFaction)
		EndIf
	ElseIf aiCommand == ssm_command_OpenOrdersMenu
		OpenWheelMenu(ssm_menu_Orders, akActor)
	ElseIf aiCommand == ssm_command_ToggleIdleMarkersUse
		If akActor.IsInFaction(ssmIdleMarkersNotAllowedFaction)
			Debug.Trace("Previous package: " + akActor.GetCurrentPackage())
			akActor.RemoveFromFaction(ssmIdleMarkersNotAllowedFaction)
			akActor.EvaluatePackage()
			Debug.Trace("New package: " + akActor.GetCurrentPackage())
		Else
			Debug.Trace("Previous package: " + akActor.GetCurrentPackage())
			akActor.AddToFaction(ssmIdleMarkersNotAllowedFaction)
			akActor.EvaluatePackage()
			Debug.Trace("New package: " + akActor.GetCurrentPackage())
		EndIf
	ElseIf aiCommand == ssm_command_ToggleDoingFavor
		If akActor.IsDoingFavor()
			akActor.SetDoingFavor(abDoingFavor = False)
		Else
			akActor.SetDoingFavor(abDoingFavor = True)
		EndIf
	EndIf
EndFunction
