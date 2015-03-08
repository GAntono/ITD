Scriptname ITDPose extends Quest  
{This holds the main code for posing}

Actor Property PlayerRef  Auto  
{The Player}

ReferenceAlias[] Property PoserAliases Auto
{an array containing all the poser aliases}

zbfBondageShell Property zbf Auto

Idle Property zbfIdleForceReset Auto
Idle[] Property ITDRotatableIdles Auto

Faction Property ITDDontMoveFaction Auto
Faction Property ITDAbleToRotateFaction Auto



;##  ASSIGNING/REMOVING ALIASES  ##

ReferenceAlias Function GetPoserAlias(Actor akPoser)
;gets the Poser alias this Poser is assigned to
	Int i = PoserAliases.Length
	;the total number of Poser aliases
		While i > 0
			i -= 1
			;this sets the i counter to count backwards, effectively checking all the items in the array.
			;it will stop once i=0 i.e. has reached the first item of the array
				If PoserAliases[i].GetReference() == akPoser
				;if there is a Poser alias pointing to this Poser
					return PoserAliases[i]
					;return said Poser alias and stop the function
				EndIf
				
		EndWhile
		
	Return None
	;return "none" if this actor is not found in the Posers
EndFunction
				
				
				
ReferenceAlias Function GetEmptyPoserAlias()
;gets an empty Poser alias to use (for other functions, like AddPoser)
	Int i = PoserAliases.Length
	;the total number of Poser aliases
		While i > 0
			i -= 1
			;this sets the i counter to count backwards, effectively checking all the items in the array.
			;it will stop once i=0 i.e. has reached the first item of the array
				If PoserAliases[i].GetReference() == None
				;when the scan finds a Poser alias that is empty, i.e. has not been given to an actor
					Return PoserAliases[i]
					;forward this empty Poser alias to whomever asked for it (probably another function) and stops the function
				EndIf
		
		EndWhile
	
	Return None
	;if no empty Poser alias found, return "none"
EndFunction


Function AddPoser(Actor akActorToBecomePoser)
;Puts the actor in the Poser alias, effectively making her a Poser

	If GetPoserAlias(akActorToBecomePoser) != none
	;if the GetPoserAlias responds that this actor is assigned to a Poser alias i.e. she's already a Poser
		Debug.MessageBox("Already a Poser")

	ElseIf GetEmptyPoserAlias() == none
	;if there is no empty Poser alias in the quest, uses the GetEmptyPoserAlias function to test this
		Debug.MessageBox("Poser quest is full, no more posers accepted")
	
	ElseIf GetEmptyPoserAlias().ForceRefIfEmpty(akActorToBecomePoser) == true
	;assign the empty Poser alias to the actor, then return true for success, false for failure
		Debug.MessageBox("Poser added. Enjoy!")
		PoserInitialization(akActorToBecomePoser)
		;initializes the poser, so that she receives the correct ranks and setdontmove attribute
		
	Else
	;if failed for any other reason
		Debug.MessageBox("Failed to add Poser")
		
	EndIf
EndFunction

Function RemovePoser(Actor akPoserToRemove)
;removes the poser from the Poser alias
	If GetPoserAlias(akPoserToRemove) == !none
	;calls GetPoserAlias to get the alias this poser is assigned to and makes sure the role exists
		PlaceInPose(akPoserToRemove, zbfIdleForceReset)
		;makes sure the actor has resumed normal posture before clearing its alias. SetDontMove is cleared in the process.
		(GetPoserAlias(akPoserToRemove)).Clear()
		;clears the alias this poser was assigned to
		Debug.MessageBox("Poser removed. Bye Bye")
		
	Else
		Debug.MessageBox("This actor is not a poser")
	
	EndIf

EndFunction


Function PoserInitialization(Actor akPoser)
;initializes the actor by setting the correct ranks in all the factions and turning off SetDontMove
	akPoser.SetFactionRank(ITDDontMoveFaction, 0)
	akPoser.SetFactionRank(ITDAbleToRotateFaction, 1)
	akPoser.SetDontMove(False)
	Debug.Notification("Poser initialized")
EndFunction


;##  POSING  ##

Bool Function bCheckForUnboundOffsetIdle(Idle idPose)
;checks whether the idle ordered is the normal (free) idle or the poser has been ordered to resume normal posture
	If idPose == zbf.zbfIdleFree || idPose == zbfIdleForceReset
		return True
	Else
		return False
	EndIf
EndFunction

Bool Function bCheckForBoundOffsetIdle(Idle idPose)
;checks whether the idle ordered is one of the bound offset idles
	int i = zbf.HandsBoundIdles.Length
			While i > 0
				i -= 1
				If idPose == zbf.HandsBoundIdles[i]
				;checks if the idle is a bound hands offset (set in Zaz Animation Pack)
					return True	
				Else
					return False
				EndIf
			EndWhile
EndFunction
		

Bool Function bCheckForOffsetIdle(Idle idPose)
;checks whether the idle requested is an offset (either bound or unbound)
	If bCheckForUnboundOffsetIdle(idPose) == true || bCheckForBoundOffsetIdle(idPose) == true
	;if either of the above checks are true i.e. the idle is the "free" idle or a bound hands offset idle
		return True
	Else
		return False
	EndIf
EndFunction

Bool Function bDontMove(Idle idPose)
;decides that the poser is not to move if she has been ordered into a non-offset idle
	If bCheckForOffsetIdle(idPose) == False
	;if the idle is not an offset idle
		return True
	Else
		return False
	EndIf
EndFunction

Function ITDSetDontMove(Actor akPoser, Idle idPose)
;calls SetDontMove on the actor if she has been ordered into a non-offset idle
	If bDontMove(idPose) == true
	;if the checks show the pose does not allow movement
		akPoser.SetDontMove(true)
		;cals don't move on the actor
		akPoser.SetFactionRank(ITDDontMoveFaction, 1)
	
	Else
	;if the checks show the pose allows movement
		akPoser.SetDontMove(false)
		;removes the don't move call on the actor
		akPoser.SetFactionRank(ITDDontMoveFaction, 0)
	
	EndIf
	
	;akPoser.SetDontMove(bDontMove(idPose))
	Debug.Notification("Don't move: " + bDontMove(idPose))
	
EndFunction

Bool Function bIsAbleToMove(Actor akPoser)
	If akPoser.GetFactionRank(ITDDontMoveFaction) == 0
		return True
	ElseIf akPoser.GetFactionRank(ITDDontMoveFaction) == 1
		return False
	EndIf
EndFunction
		


Function PlaceInPose(Actor akPoser, Idle idPose)
;puts a poser in a bondage position and restricts her movement if appropriate
	akPoser.Playidle(idPose)
	;puts the poser in the position
		If idPose == zbfIdleForceReset
		;if the poser has been ordered to resume normal posture
			zbf.ApplyAllModifiers(akPoser)
			;reapplies the effects of Zaz restraints, because they break after IdleForceReset
			;this is called only if zbfIdleForceReset because it's expensive
		EndIf
		
	ITDSetDontMove(akPoser, idPose)
	;restricts poser's movements if appropriate
	SetRotateFactionRank(akPoser, idPose)
	;restricts poser's ability to turn if appropriate
	
EndFunction

 
Function RotateToFacePlayer(Actor akPoser)
;makes the actor turn to face the player
	If bIsAbleToRotate(akPoser)
		float zOffset = akPoser.GetHeadingAngle(Game.GetPlayer())
		;calculates the angle difference between where the poser is looking at and where the player is at
			akPoser.TranslateTo(akPoser.GetPositionX(), akPoser.GetPositionY(), akPoser.GetPositionZ(), akPoser.GetAngleX(), akPoser.GetAngleY(), \
				akPoser.GetAngleZ() + zOffset, 0.0, 90)
			;rotates the poser by the angle difference
	EndIf
		
EndFunction


Function RotateToFaceAwayFromPlayer(Actor akPoser)
;makes the actor turn to face away from the player
	If bIsAbleToRotate(akPoser)
		float zOffset = akPoser.GetHeadingAngle(Game.GetPlayer()) + 180
		;calculates the angle difference between where the poser is looking at and where the player is and adds 180 to make her face away
			akPoser.TranslateTo(akPoser.GetPositionX(), akPoser.GetPositionY(), akPoser.GetPositionZ(), akPoser.GetAngleX(), akPoser.GetAngleY(), \
				akPoser.GetAngleZ() + zOffset, 0.0, 90)
			;rotates the poser by the angle difference plus 180 degrees
	EndIf
			
EndFunction


Bool Function bCheckForRotatableIdle(Idle idPose)
;checks if the ordered position will allow the actor to rotate or not
	bool bCheckResult = false
	
	int i = ITDRotatableIdles.Length
			While i > 0
				i -= 1
				If idPose == ITDRotatableIdles[i]
				;checks if the idle allows rotation
					bCheckResult = True
				
				EndIf
				
			EndWhile
			
			Return bCheckResult
			
EndFunction


Bool Function bIsAbleToRotate(Actor akPoser)
	If akPoser.GetFactionRank(ITDAbleToRotateFaction) == 1
		return True
	ElseIf akPoser.GetFactionRank(ITDAbleToRotateFaction) == 0
		return False
	EndIf
EndFunction
		


Function SetRotateFactionRank(Actor akPoser, Idle idPose)
;after checking if the position allows rotation, assigns rank 0 or 1 in the ITDAbleToRotateFaction
	If bCheckForRotatableIdle(idPose) == False && bIsAbleToMove(akPoser) == False
	;checks that position does not allow rotation AND that the actor is unable to move (an added check to prevent illogical situations)
		akPoser.SetFactionRank(ITDAbleToRotateFaction, 0)
		;gives the rank of 0 in the ITDAbleToRotateFaction
		
	ElseIf bCheckForRotatableIdle(idPose) == 1
		akPoser.SetFactionRank(ITDAbleToRotateFaction, 1)
		;gives the rank of 1 in the ITDAbleToRotateFaction
		
	Else
		Debug.MessageBox("Illogical combination of AbleToRotate and bIsAbleToMove encountered")
		
	EndIf
	
EndFunction
