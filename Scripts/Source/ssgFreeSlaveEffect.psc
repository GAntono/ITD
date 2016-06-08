Scriptname ssgFreeSlaveEffect extends activemagiceffect  

ssgMain Property ssg Auto
zbfSlaveControl Property zbf_SlaveControl Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If ssg.FindSlot(akTarget)
		ssg.UnslotActor(akTarget)
		zbf_SlaveControl.FreeSlave(akTarget, "SSG")
	EndIf
EndEvent
