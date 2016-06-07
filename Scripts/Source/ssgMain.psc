Scriptname ssgMain extends Quest

;TODO: Have all properties & variables initialize via a function, to allow them to take new value after version update.
;TODO: Special case Hogtie: slave cannot do most actions, cannot move. Can only be placed in hogtie by binding her that way.
;TODO: Ask for iBindType to be turned into a property or returned by a function.
;TODO: Ask for a version of SetBinding() that equips but doesn't add.
;TODO: In fact, ask for all zbfSlot variables to be converted into properties.

zbfBondageShell Property zbf Auto				;ZAZ Animation Pack zbfBondageShell API.
zbfSlaveControl Property zbf_SlaveControl Auto	;ZAZ Animation Pack zbfSlaveControl API.

Import StorageUtil

ReferenceAlias Property PlayerRef Auto
ssgSlave[] Property Slots Auto
Spell Property ssgEnslaveSpell Auto
Spell Property ssgFreeSlaveSpell Auto
Faction Property ssgIdleMarkersNotAllowedFaction Auto
Faction Property ssgStrugglingFaction Auto

Int Property ssgMenuKey  							Auto Hidden

Int Property ssg_menu_Top 							Auto Hidden
Int Property ssg_menu_Pose 							Auto Hidden
Int Property ssg_menu_Orders						Auto Hidden
Int Property ssg_menu_SetAnim						Auto Hidden

Int Property ssg_command_OpenTopMenu		 		Auto Hidden
Int Property ssg_command_OpenBondageScreen 			Auto Hidden
Int Property ssg_command_OpenInventory 				Auto Hidden
Int Property ssg_command_OpenPoseMenu 				Auto Hidden
Int Property ssg_command_SetPoseStanding 			Auto Hidden
Int Property ssg_command_SetPoseKneeling 			Auto Hidden
Int Property ssg_command_SetPoseLying 				Auto Hidden
Int Property ssg_command_ToggleStruggling			Auto Hidden
Int Property ssg_command_OpenOrdersMenu				Auto Hidden
Int Property ssg_command_ToggleIdleMarkersUse 		Auto Hidden
Int Property ssg_command_SetDoingFavor				Auto Hidden
Int Property ssg_command_SetAnim					Auto Hidden
Int Property ssg_command_ToggleSlaveFollow			Auto Hidden

;makes sure that OnInit() will only fire once.
Event OnInit()
	StorageUtil.AdjustIntValue(Self, "OnInitCounter", 1)
	If StorageUtil.GetIntValue(Self, "OnInitCounter") == 2
		InitValues()
		zbf_SlaveControl.RegisterForEvents()
		PlayerRef.GetActorReference().AddSpell(ssgEnslaveSpell)
		PlayerRef.GetActorReference().AddSpell(ssgFreeSlaveSpell)
		RegisterForKey(ssgMenuKey)

		StorageUtil.UnsetIntValue(Self, "OnInitCounter")
		Debug.Trace("[SSG] Initialized")
	EndIf
EndEvent

;Initializing properties in a function to allow for version updates
Function InitValues()
	ssgMenuKey  							= 47	;V key

	ssg_menu_Top 							= 1
	ssg_menu_Pose 							= 2
	ssg_menu_Orders							= 3
	ssg_menu_SetAnim						= 4

	ssg_command_OpenTopMenu		 			= 1
	ssg_command_OpenBondageScreen 			= 2
	ssg_command_OpenInventory 				= 3
	ssg_command_OpenPoseMenu 				= 4
	ssg_command_SetPoseStanding 			= 5
	ssg_command_SetPoseKneeling 			= 6
	ssg_command_SetPoseLying 				= 7
	ssg_command_ToggleStruggling			= 9
	ssg_command_OpenOrdersMenu				= 10
	ssg_command_ToggleIdleMarkersUse		= 11
	ssg_command_SetDoingFavor				= 12
	ssg_command_SetAnim						= 13
	ssg_command_ToggleSlaveFollow			= 14
EndFunction

ssgMain Function GetAPI() Global
	Return Game.GetFormFromFile(0x0400E746, "SkyrimSlaversGuild.esp") as ssgMain
EndFunction

ssgSlave Function FindSlot(Actor akActor)
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

ssgSlave Function SlotActor(Actor akActor)
	If !akActor
		Return None
	EndIf

	ssgSlave returnSlot = FindSlot(akActor)
	Int i
	While returnSlot == None && i < Slots.Length
		If Slots[i].GetActorReference() == None
			Slots[i].SetDebugLevel(2)		;for logging purposes
			;Slots[i].ForceRefTo(akActor)	;forces ssgSlave alias to akActor - redundant
			Slots[i].Register(akActor)		;registers akActor in the zbfSlot (sub-class) and the ssgSlave (superclass) systems
			InitializeActor(akActor)		
			returnSlot = Slots[i]
		EndIf
		i += 1
	EndWhile
	Return returnSlot
EndFunction

Function UnslotActor(Actor akActor)
	akActor.RemoveFromFaction(ssgIdleMarkersNotAllowedFaction)
	akActor.RemoveFromFaction(ssgStrugglingFaction)
	
	FindSlot(akActor).Clear()
EndFunction

;initialize factions that may exist on the slave
Function InitializeActor(Actor akActor)
	If !akActor
		Return
	EndIf
	
	akActor.RemoveFromFaction(ssgIdleMarkersNotAllowedFaction)
	akActor.RemoveFromFaction(ssgStrugglingFaction)
EndFunction

Event OnKeyDown(Int Keycode)
	If keycode == ssgMenuKey && !Utility.IsInMenuMode()
		Actor actorRef = Game.GetCurrentCrosshairRef() as Actor
		If actorRef && FindSlot(actorRef)	;if there's something under the crosshair and it's an actor slotted in ssgSlave
			OpenSSGMenu(ssg_menu_Top, actorRef)
		EndIf
	EndIf
EndEvent

Function OpenSSGMenu(Int aiMenuName, Actor akActor = None)
	If aiMenuName < 1
		Return
	EndIf
	;cheat sheet:
	;UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", index, "")
	;UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", index, "")
	;UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", index, True)

	Int iMenuSelected
	UIExtensions.InitMenu("UIWheelMenu")
	UIExtensions.InitMenu("UIListMenu")
	If aiMenuName == ssg_menu_Top
		Bool bPoseMenuEnabled = True
		If zbf.GetBindTypeFromWornKeywords(akActor) == zbf.iBindUnbound	;if the actor is not bound, she doesn't pose
			bPoseMenuEnabled = False
		EndIf
		String optionLabelText_ToggleSlaveFollow = "Stay"
		String optionText_ToggleSlaveFollow = "Stay here, slave"
		If akActor.GetActorValue("WaitingForPlayer")
			optionLabelText_ToggleSlaveFollow = "Follow"
			optionText_ToggleSlaveFollow = "Follow me, slave"
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
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 4, "Command")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 4, "Issue a command")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 4, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 5, optionLabelText_ToggleSlaveFollow)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 5, optionText_ToggleSlaveFollow)
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 5, True)
		
		iMenuSelected = UIExtensions.OpenMenu(menuName = "UIWheelMenu", akForm = akActor)

		If iMenuSelected == 0
			ExecuteSSGCommand(ssg_command_OpenBondageScreen, akActor)
		ElseIf iMenuSelected == 1
			ExecuteSSGCommand(ssg_command_OpenInventory, akActor)
		ElseIf iMenuSelected == 2
			ExecuteSSGCommand(ssg_command_OpenPoseMenu, akActor)
		ElseIf iMenuSelected == 3
			ExecuteSSGCommand(ssg_command_OpenOrdersMenu, akActor)
		ElseIf iMenuSelected == 4
			ExecuteSSGCommand(ssg_command_SetDoingFavor, akActor)
		ElseIf iMenuSelected == 5
			ExecuteSSGCommand(ssg_command_ToggleSlaveFollow, akActor)
		EndIf

	ElseIf aiMenuName == ssg_menu_Pose
		String optionLabelText_ToggleStruggling = "Struggle"
		String optionText_ToggleStruggling = "Struggle for me"
		If akActor.IsInFaction(ssgStrugglingFaction)
			optionLabelText_ToggleStruggling = "Stop struggling"
			optionText_ToggleStruggling = "Stop struggling"
		EndIf
		;TODO: if no poses available for iPose = iPoseStanding with any combination of aiBindType, then disable that option when standing
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 0, "Standing")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 0, "Stand up")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 0, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 1, "Kneeling")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 1, "Kneel")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 1, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 2, "Lying")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 2, "Lie down")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 2, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 3, "Back")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 3, "Back to Top Menu")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 3, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 4, optionLabelText_ToggleStruggling)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 4, optionLabelText_ToggleStruggling)
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 4, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 5, "Specific Pose")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 5, "Set specific pose")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 5, True)
		
		iMenuSelected = UIExtensions.OpenMenu(menuName = "UIWheelMenu", akForm = akActor)

		If iMenuSelected == 0
			ExecuteSSGCommand(ssg_command_SetPoseStanding, akActor)
		ElseIf iMenuSelected == 1
			ExecuteSSGCommand(ssg_command_SetPoseKneeling, akActor)
		ElseIf iMenuSelected == 2
			ExecuteSSGCommand(ssg_command_SetPoseLying, akActor)
		ElseIf iMenuSelected == 3
			ExecuteSSGCommand(ssg_command_OpenTopMenu, akActor)
		ElseIf iMenuSelected == 4
			ExecuteSSGCommand(ssg_command_ToggleStruggling, akActor)
		ElseIf iMenuSelected == 5
			ExecuteSSGCommand(ssg_command_SetAnim, akActor)
		EndIf
		
	ElseIf aiMenuName == ssg_menu_Orders
		String optionLabelText_ToggleIdleMarkersUse = "Forbid sitting"
		String optionText_ToggleIdleMarkersUse = "No sitting allowed"
		If akActor.IsInFaction(ssgIdleMarkersNotAllowedFaction)
			optionLabelText_ToggleIdleMarkersUse = "Allow sitting"
			optionText_ToggleIdleMarkersUse = "You may sit"
		EndIf
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 0, optionLabelText_ToggleIdleMarkersUse)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 0, optionText_ToggleIdleMarkersUse)
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 0, True)
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 3, "Back")
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 3, "Back to Top Menu")
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 3, True)
		
		iMenuSelected = UIExtensions.OpenMenu(menuName = "UIWheelMenu", akForm = akActor)
		
		If iMenuSelected == 0
			ExecuteSSGCommand(ssg_command_ToggleIdleMarkersUse, akActor)
		ElseIf iMenuSelected == 3
			ExecuteSSGCommand(ssg_command_OpenTopMenu, akActor)
		EndIf
	ElseIf aiMenuName == ssg_menu_SetAnim
		ssgSlave slave = FindSlot(akActor)
		String[] validAnimationsComaSeparated = zbf.GetPoseAnimList(aiPoseIndex = slave.iPose, aiBindType = zbf.GetBindTypeFromWornKeywords(akActor))
		String[] validAnimations = zbfUtil.ArgString(validAnimationsComaSeparated[0], asDelimiter = ",", bAllowEmpty = False) ;[0] means "non-struggling"
		Int validAnimationsLength = validAnimations.Length
		Int i
		While i < validAnimationsLength
			StringListAdd(ObjKey = akActor, KeyName = "ssg_SU_validAnimationsNoDupes", value = validAnimations[i], allowDuplicate = False)	;create a StorageUtil array on the fly that gets rid of duplicates
			i += 1
		EndWhile
		Int totalEntries = StringListCount(ObjKey = akActor, KeyName = "ssg_SU_validAnimationsNoDupes")
		UIExtensions.SetMenuPropertyInt("UIListMenu", "totalEntries", totalEntries)
		i = 0
		While i < totalEntries
				UIExtensions.SetMenuPropertyIndexString("UIListMenu", "entryName", i, StringListGet(ObjKey = akActor, KeyName = "ssg_SU_validAnimationsNoDupes", index = i))
				UIExtensions.SetMenuPropertyIndexInt("UIListMenu", "entryId", i, i)
				i += 1
		EndWhile
		UIExtensions.OpenMenu(menuName = "UIListMenu")
		iMenuSelected = UIExtensions.GetMenuResultInt(menuName = "UIListMenu")
		
		If iMenuSelected != -1	;-1 is returned if menu is exited without selecting anything
			SetAnimExtended(slave, StringListGet(ObjKey = akActor, KeyName = "ssg_SU_validAnimationsNoDupes", index = iMenuSelected))
			StringListClear(ObjKey = akActor, KeyName = "ssg_SU_validAnimationsNoDupes")
		EndIf
	EndIf
EndFunction


Function ExecuteSSGCommand(Int aiCommand, Actor akActor = None)
	If aiCommand < 1
		Return
	ElseIf !akActor
		Debug.Trace("[SSG] ERROR: ExecuteSSGCommand() has been passed a non-object for argument akActor")
		Return
	EndIf
	
	ssgSlave slave = FindSlot(akActor)

	If aiCommand == ssg_command_OpenTopMenu
		OpenSSGMenu(ssg_menu_Top, akActor)
	ElseIf aiCommand == ssg_command_OpenBondageScreen
		slave.bForceEquip = True	;bForceEquip is a property in the ssgSlave sub-class of akActor
		akActor.OpenInventory(abForceOpen = True)
	ElseIf aiCommand == ssg_command_OpenInventory
		slave.bForceEquip = False
		akActor.OpenInventory(abForceOpen = True)
	ElseIf aiCommand == ssg_command_OpenPoseMenu
		OpenSSGMenu(ssg_menu_Pose, akActor)
	ElseIf aiCommand == ssg_command_SetPoseStanding
		SetPoseExtended(slave, zbf.iPoseStanding)
	ElseIf aiCommand == ssg_command_SetPoseKneeling
		SetPoseExtended(slave, zbf.iPoseKneeling)
	ElseIf aiCommand == ssg_command_SetPoseLying
		SetPoseExtended(slave, zbf.iPoseLying)
	ElseIf aiCommand == ssg_command_ToggleStruggling
		If akActor.IsInFaction(ssgStrugglingFaction)
			SetStruggleExtended(slave, abStruggle = False)
		Else
			SetStruggleExtended(slave, abStruggle = True)
		EndIf
	ElseIf aiCommand == ssg_command_OpenOrdersMenu
		OpenSSGMenu(ssg_menu_Orders, akActor)
	ElseIf aiCommand == ssg_command_ToggleIdleMarkersUse
		If akActor.IsInFaction(ssgIdleMarkersNotAllowedFaction)
			akActor.RemoveFromFaction(ssgIdleMarkersNotAllowedFaction)
			akActor.EvaluatePackage()
		Else
			akActor.AddToFaction(ssgIdleMarkersNotAllowedFaction)
			akActor.EvaluatePackage()
			If akActor.GetSitState() > 2	;if the actor is sitting
				If zbf.GetBindTypeFromWornKeywords(akActor)	!= zbf.iBindUnbound	;if the actor is bound
					slave.ApplyAnimEffects()	;make them stand by using the Zaz framework
				Else
					akActor.PlayIdle(zbf.zbfIdleForceDefault)		;make them stand the vanilla method
				EndIf
			EndIf
		EndIf
	ElseIf aiCommand == ssg_command_SetDoingFavor
		SetPoseExtended(slave, zbf.iPoseStanding)	;make her stand before she starts moving
		akActor.SetDoingFavor(abDoingFavor = True)
	ElseIf aiCommand == ssg_command_SetAnim
		OpenSSGMenu(ssg_menu_SetAnim, akActor)
	ElseIf aiCommand == ssg_command_ToggleSlaveFollow
		ToggleSlaveFollow(akSlave = akActor)
	EndIf
EndFunction

Function SetPoseExtended(ssgSlave akSlave, Int aiPoseIndex)
	;iPoseStanding = 0
	;iPoseKneeling = 1
	;iPoseHogtie = 2
	;iPoseLying = 3
	;iPoseFurnitureBase = 200
	;automates standard tasks when calling SetPose()
	If !akSlave
		Debug.Trace("[SSG] ERROR: SetPoseExtended() has been passed a non-object for argument akSlave")
		Return
	EndIf
	
	akSlave.bHasAnimSet = True
	If aiPoseIndex == zbf.iPoseStanding
		akSlave.UnpinActor()
	Else
		akSlave.PinActor()
	EndIf
	akSlave.SheatheWeapon()
	akSlave.SetPose(aiPoseIndex)
EndFunction

Function SetAnimExtended(ssgSlave akSlave, String asAnim)
	;automates standard tasks when calling SetAnim()
	If !akSlave
		Debug.Trace("[SSG] ERROR: SetAnimExtended() has been passed a non-object for argument akSlave")
		Return
	EndIf
	
	akSlave.PinActor()
	If akSlave.bHasAnimSet	;breaks animation continuity (slave stands up) but cannot be avoided if bHasAnimSet otherwise the slave will be automatically switching animations
		akSlave.SetAnimSet("")	;stop automatic animation selection - same as StopIdleAnim()
		Utility.WaitMenuMode(1.0)	;required otherwise SetAnimSet("") makes the actor stay in standing position
		akSlave.bHasAnimSet = False
	EndIf
	akSlave.SheatheWeapon()
	akSlave.SetAnim(asAnim)
EndFunction

Function SetStruggleExtended(ssgSlave akSlave, Bool abStruggle)
	;automates standard tasks when calling SetStruggle()
	If !akSlave
		Debug.Trace("[SSG] ERROR: SetStruggleExtended() has been passed a non-object for argument akSlave")
		Return
	EndIf
	
	Actor actorRef = akSlave.GetActorReference()
	If abStruggle
		akSlave.SetStruggle(abStruggle = True)
		actorRef.AddToFaction(ssgStrugglingFaction)
	Else
		akSlave.SetStruggle(abStruggle = False)
		actorRef.RemoveFromFaction(ssgStrugglingFaction)
	EndIf
EndFunction

Function ToggleSlaveFollow(Actor akSlave, Int abFollow = -1)
	;toggles between follow/wait. Can force-set Follow if abFollow is set to 1, Wait if abFollow is set to 0.
	If !akSlave
		Debug.Trace("[SSG] ERROR: SetSlaveFollow() has been passed a non-object for argument akSlave")
		Return
	EndIf
	
	If abFollow == 1
		akSlave.SetActorValue("WaitingForPlayer", 0)
		Return
	ElseIf abFollow == 0
		akSlave.SetActorValue("WaitingForPlayer", 1)
		Return
	EndIf
	
	If akSlave.GetActorValue("WaitingForPlayer")
		akSlave.SetActorValue("WaitingForPlayer", 0)
	Else
		akSlave.SetActorValue("WaitingForPlayer", 1)
	EndIf
EndFunction
