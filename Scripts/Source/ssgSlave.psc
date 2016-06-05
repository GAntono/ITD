Scriptname ssgSlave extends zbfSlot

ReferenceAlias Property PlayerRef Auto
Bool Property bForceEquip Auto Hidden
Bool Property bHasAnimSet Auto Hidden

Event OnItemAdded(Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	If !bForceEquip
		Return
	EndIf
	Actor actorRef = Self.GetActorReference()
	If actorRef.IsEquipped(akBaseItem)
		Return
	EndIf
	
	If akBaseItem.GetType() == 26	;type: armor
		Form previousItem = actorRef.GetWornForm((akBaseItem as Armor).GetSlotMask())
			If previousItem
				RemoveBinding(akBinding = previousItem, abRemove = False, abUpdateSettings = True)
				actorRef.UnequipItem(akItem = previousItem, abPreventEquip = False, abSilent = True)
			EndIf
		actorRef.EquipItem(akItem = akBaseItem, abPreventRemoval = True, abSilent = True)
		SetBinding(akBinding = akBaseItem, abAdd = False, abPreventRemoval = True, abUpdateSettings = True)
	Else	;type: weapon, shield etc
		actorRef.EquipItem(akItem = akBaseItem, abPreventRemoval = False, abSilent = True)
	EndIf
	actorRef.EvaluatePackage()	;activate package according to bindings
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	;OnObjectUnequipped doesn't work as intended
	;TODO: check if keys are available
	Actor actorRef = Self.GetActorReference()
	If actorRef.IsEquipped(akBaseItem)	;if the actor is still wearing such an item, then we only removed it from her inventory
		Return
	EndIf
	
	;we may have removed something that was previously equiped and registered by zbfSlot - we need to update settings
	Int slot
	While slot < 10	;10 slots in zbfSlot.AllBindings
		Form currentRegisteredBinding = GetCurrentBinding(slot)
		If currentRegisteredBinding == akBaseItem
			RemoveBinding(akBinding = akBaseItem, abRemove = False, abUpdateSettings = True)
			slot = 10	;stop the while loop
		EndIf
		slot += 1
	EndWhile
	actorRef.EvaluatePackage()	;activate package according to bindings
EndEvent
