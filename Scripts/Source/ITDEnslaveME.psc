Scriptname ITDEnslaveME extends activemagiceffect  
{Enslaves an NPC, using the Paradise Halls AddSlave function}

PAHCore Property PAH Auto
{Points to the PAHCore Paradise Halls main script so that we can call its functions}

Event OnEffectStart(Actor akTarget, Actor akCaster)
	;when the spell hits an NPC
	Actor NewCapturedSlave = PAH.Capture(akTarget as Actor)
	;use the Paradise Halls system to capture her as a slave
	;PAH.Addslave(NewCapturedSlave)
	;make the new slave submit to the player
EndEvent
