Scriptname ssmSlave extends zbfslot  

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	SetBinding(akBaseItem)
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	RemoveBinding(akBaseItem)
EndEvent
