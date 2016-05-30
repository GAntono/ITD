Scriptname ssmSlave extends zbfSlot

ReferenceAlias Property PlayerRef Auto
Bool Property bForceEquip Auto Hidden

Event OnItemAdded(Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	If bForceEquip
		Actor actorRef = Self.GetActorReference()
		SetBinding(akBinding = akBaseItem, abAdd = False, abPreventRemoval = True, abUpdateSettings = True) ;update settings, doesn't hurt
		If !actorRef.IsEquipped(akBaseItem)
			actorRef.EquipItem(akBaseItem, abPreventRemoval = True, abSilent = True)
			actorRef.EvaluatePackage()	;activate package according to bindings
		EndIf
	EndIf
EndEvent



Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	;we may have removed something that was previously equiped and registered by zbfSlot - we need to update settings
	Int slot
	While slot < 10	;10 slots in zbfSlot.AllBindings
		Form currentRegisteredBinding = GetCurrentBinding(slot)
		If currentRegisteredBinding == akBaseObject
			RemoveBinding(akBinding = akBaseObject, abRemove = False, abUpdateSettings = True)
			slot = 10	;stop the while loop
		EndIf
		slot += 1
	EndWhile
	Self.GetActorReference().EvaluatePackage()	;activate package according to bindings
EndEvent
