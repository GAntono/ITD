Scriptname ssmSlave extends zbfSlot

ReferenceAlias Property PlayerRef Auto
Bool Property bChangeEquipState Auto

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	If bChangeEquipState
		SetBindingViaInv(akBaseItem)
	EndIf
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	If bChangeEquipState
		RemoveBindingViaInv(akBaseItem)
	EndIf
EndEvent

Function SetBindingViaInv(Form akBinding, Bool abPreventRemoval = True, Bool abUpdateSettings = True)
	If !akBinding
		Return
	EndIf
	
	Actor actorRef = Self.GetActorReference()
	SetBinding(akBinding, abAdd = False, abPreventRemoval = abPreventRemoval, abUpdateSettings = abUpdateSettings) ;update settings, doesn't hurt
	If actorRef.IsEquipped(akBinding) == False
		actorRef.EquipItem(akBinding, abPreventRemoval = abPreventRemoval, abSilent = True)
		actorRef.EvaluatePackage()	;activate package according to bindings
	;/ Else
		bChangeEquipState == False	;to remove akBinding without triggering RemoveBindingViaInv()
		actorRef.RemoveItem(akBinding, abSilent = True, akOtherContainer = PlayerRef.GetActorReference())	;put the item back into player's inventory
		bChangeEquipState == True	;resume normal functionality /;
	EndIf
EndFunction

Function RemoveBindingViaInv(Form akBinding, Bool abUpdateSettings = True)
	If !akBinding
		Return
	ElseIf Self.GetActorReference().IsEquipped(akBinding)	;if the actor is still wearing such an item, then we only removed it from her inventory
		Return
	EndIf

	;we may have removed something that was previously equiped and registered by zbfSlot - we need to update settings
	Int slot
	While slot < 10	;10 slots in zbfSlot.AllBindings
		Form currentRegisteredBinding = GetCurrentBinding(slot)
		If currentRegisteredBinding == akBinding
			RemoveBinding(akBinding, abRemove = False, abUpdateSettings = abUpdateSettings)
			slot = 10	;stop the WHILE loop
		EndIf
		slot += 1
	EndWhile
	Self.GetActorReference().EvaluatePackage()	;activate package according to bindings
EndFunction
