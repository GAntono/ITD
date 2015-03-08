Scriptname ITDZazIdleMarkerTrigger extends ObjectReference  
{Prevents the prisoner from becoming stuck on
a Zaz animation when using a Zaz idle marker.}

Package Property ITDInCellPrisonerPackage Auto

zbfBondageShell Property zbf Auto

Idle Property zbfIdleForceReset Auto


Event OnTriggerLeave(ObjectReference akActionRef)
;when the prisoner exits the trigger (i.e. leaves the idle marker)
	(akActionRef as Actor).PlayIdle(zbfIdleForceReset)
	;makes the prisoner resume normal posture i.e. un-stucks her
	zbf.ApplyAllModifiers(akActionRef as Actor)
	;re-applies Zaz bondage effects if appropriate

EndEvent
