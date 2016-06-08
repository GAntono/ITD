Scriptname ssgQ1Slaver extends ReferenceAlias  

Event OnInit()
	Actor slaver = Self.GetActorReference()
	slaver.SetNoBleedoutRecovery(True)
	slaver.AllowBleedoutDialogue(abCanTalk = True)
EndEvent
