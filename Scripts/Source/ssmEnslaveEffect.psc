Scriptname ssmEnslaveEffect extends activemagiceffect

ssmMain Property ssm Auto
zbfSlaveControl Property SlaveControl Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If SlaveControl.EnslaveActor(akTarget, "SSM") ;on a successful enslavement via zaz
		If	ssm.SlotActor(akTarget)
			ssm.InitializeSlave(akTarget)
		EndIf
	EndIf
EndEvent
