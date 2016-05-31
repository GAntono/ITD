Scriptname ssmFreeSlaveEffect extends activemagiceffect  

ssmMain Property ssm Auto
zbfSlaveControl Property zbf_SlaveControl Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If ssm.FindSlot(akTarget)
		ssm.UnslotActor(akTarget)
		zbf_SlaveControl.FreeSlave(akTarget, "SSM")
	EndIf
EndEvent
