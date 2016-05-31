Scriptname ssmEnslaveEffect extends activemagiceffect

ssmMain Property ssm Auto
zbfSlaveControl Property zbf_SlaveControl Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If ssm.SlotActor(akTarget)
		zbf_SlaveControl.EnslaveActor(akTarget, "SSM")
	EndIf
EndEvent
