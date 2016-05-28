Scriptname ssmEnslaveEffect extends activemagiceffect

ssmMain Property ssm Auto
zbfSlaveControl Property SlaveControl Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If SlaveControl.EnslaveActor(akTarget, "Skyrim Slave Master") ;on a successful enslavement via zaz
			ssm.SlotActor(akTarget)
	EndIf
EndEvent
