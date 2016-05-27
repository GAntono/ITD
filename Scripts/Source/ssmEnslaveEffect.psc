Scriptname ssmEnslaveEffect extends activemagiceffect

ssmMain Property ssm Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	zbfSlaveControl SlaveControl = zbfSlaveControl.GetAPI()
	If SlaveControl.EnslaveActor(akTarget, "Skyrim Slave Master") ;if ZAP is installed, then enslave the target
			ssm.SlotActor(akTarget)
			Debug.Trace("[SSM] Actor enslaved")
		Else
			Debug.Trace("[SSM] Actor enslavement failed")
		EndIf
EndEvent
