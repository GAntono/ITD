Scriptname ITDInCellTrigger extends ObjectReference  
{Triggers In-Cell Prisoner behaviour}

ITDCore Property ITDQuest Auto
;points to the ITDQuest which has the ITDCore script so we can use its functions

Event OnTriggerEnter(ObjectReference akActionRef)
	ITDQuest.PutPrisonerInCell(akActionRef as Actor)
	;adds the prisoner to the ITDLockedUpPrisonerFaction and forces her to evaluate her packages, effectively locking her inside a jail cell
	;see ITDCore
EndEvent

Event OnTriggerLeave(ObjectReference akActionRef)
	ITDQuest.RemovePrisonerFromCell(akActionRef as Actor)
	;removes the prisoner form the ITDLockedUpPrisonerFaction and forces her to evaluate her packages, effectively letting her out of the jail cell
	;see ITDCore
EndEvent
