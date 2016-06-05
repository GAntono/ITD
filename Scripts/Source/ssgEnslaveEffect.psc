Scriptname ssgEnslaveEffect extends activemagiceffect

ssgMain Property ssg Auto
zbfSlaveControl Property zbf_SlaveControl Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If ssg.SlotActor(akTarget)
		zbf_SlaveControl.EnslaveActor(akTarget, "SSG")
	EndIf
EndEvent
