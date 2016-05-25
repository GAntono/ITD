Scriptname ssmSlave extends zbfSlot

Bool Property bForceEquip Auto

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	If bForceEquip
		SetBindingViaInv(akBaseItem)
	EndIf
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	If bForceEquip
		RemoveBindingViaInv(akBaseItem)
	EndIf
EndEvent

Function SetBindingViaInv(Form akBinding, Bool abPreventRemoval = True, Bool abUpdateSettings = True)
	If !akBinding
		Return
	EndIf

	SetBinding(akBinding, abAdd = False, abPreventRemoval = abPreventRemoval, abUpdateSettings = abUpdateSettings)
	Actor ActorRef = Self.GetActorReference()
	If !ActorRef.IsEquipped(akBinding)
		ActorRef.EquipItem(akBinding, abPreventRemoval = abPreventRemoval, abSilent = True)
	EndIf
EndFunction

Function RemoveBindingViaInv(Form akBinding, Bool abUpdateSettings = True)
	If !akBinding
		Return
	EndIf

	RemoveBinding(akBinding, abRemove = False, abUpdateSettings = abUpdateSettings)
	Actor ActorRef = Self.GetActorReference()
	If ActorRef.IsEquipped(akBinding)
		ActorRef.UnequipItem(akBinding, abSilent = True)
	EndIf
EndFunction
