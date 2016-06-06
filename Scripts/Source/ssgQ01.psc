Scriptname ssgQ01 extends Quest  

ReferenceAlias[] Property QuestAliases Auto
ReferenceAlias Property PlayerRef Auto

;/ 
Quest stages:

00: Not talked with Hulda about this.
10: Talked with Hulda about this, but declined.
20: Talked with Hulda and accepted.
30: Killed the kidnappers.
40: Accepted the slavers' offer.
50: Declined the slavers' offer.
 /;
 
Event OnInit()
	Debug.Trace("OnInit() fired for quest ssgQ01")
	;StorageUtil.AdjustIntValue(Self, "OnInitCounter", 1)
	;If StorageUtil.GetIntValue(Self, "OnInitCounter") == 2
		Int i
		While i < QuestAliases.Length
			Actor actorRef = QuestAliases[i].GetActorReference()
			If actorRef
				Debug.Trace(QuestAliases[i] + " is filled with actor " + actorRef)
			Else
				Debug.Trace(QuestAliases[i] + " is empty")
			EndIf
			i += 1
		EndWhile
		RegisterForSingleUpdate(5.0)
		;StorageUtil.UnsetIntValue(Self, "OnInitCounter")
	;EndIf
EndEvent

Event OnUpdate()
	Int i
	While i < QuestAliases.Length
		Actor actorRef = QuestAliases[i].GetActorReference()
		If actorRef
			Debug.Trace(QuestAliases[i] + " is filled with actor " + actorRef)
		Else
			Debug.Trace(QuestAliases[i] + " is empty")
		EndIf
		i += 1
	EndWhile
EndEvent
 