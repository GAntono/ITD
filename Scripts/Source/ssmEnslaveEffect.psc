Scriptname ssmEnslaveEffect extends activemagiceffect

ssmMain Property ssm Auto
zbfSlaveControl Property zbf_SlaveControl Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If zbf_SlaveControl.EnslaveActor(akTarget, "SSM") ;on a successful enslavement via zaz
		ssm.SlotActor(akTarget)
	EndIf
EndEvent
