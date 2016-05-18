Scriptname ssmEnslaveEffect extends activemagiceffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
	zbfSlaveControl SlaveControl = zbfSlaveControl.GetAPI()
	If (SlaveControl.EnslaveActor(akTarget, "Skyrim Slave Master"))
		Debug.Trace("SSM Actor enslaved")
	Else
		Debug.Trace("SSM Actor enslavement failed")
	EndIf
EndEvent
