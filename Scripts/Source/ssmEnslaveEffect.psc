Scriptname ssmEnslaveEffect extends activemagiceffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
	zbfSlaveControl SlaveControl = zbfSlaveControl.GetAPI()
	If SlaveControl && SlaveControl.EnslaveActor(akTarget, "Skyrim Slave Master") ; if ZAP is installed, then enslave the target
			Debug.Trace("[SSM] Actor enslaved")
		Else
			Debug.Trace("[SSM] Actor enslavement failed")
		EndIf
EndEvent
