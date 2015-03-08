Scriptname ITDCore extends Quest  
{This holds the main ITD code}

Actor Property PlayerRef  Auto  
{The Player}

ReferenceAlias[] Property PrisonerAliases  Auto  
{An array containing all the prisoner aliases}

Faction Property ITDPrisonerFaction Auto
Faction Property ITDInCellPrisonerFaction Auto
Faction Property ITDPrisonerFollowerFaction Auto

zbfBondageShell Property zbf Auto

Idle Property zbfIdleForceReset Auto

Quest Property ITDConfigMenuQuest Auto
Quest Property ITDPosingQuest Auto

Keyword Property zbfEffectWrist Auto


;##  ASSIGNING/REMOVING ALIASES  ##

ReferenceAlias Function GetPrisonerAlias(Actor akPrisoner)
;gets the prisoner alias this prisoner is assigned to
	Int i = PrisonerAliases.Length
	;the total number of prisoner aliases
		While i > 0
			i -= 1
			;this sets the i counter to count backwards, effectively checking all the items in the array.
			;it will stop once i=0 i.e. has reached the first item of the array
				If PrisonerAliases[i].GetReference() == akPrisoner
				;if there is a prisoner alias pointing to this prisoner
					return PrisonerAliases[i]
					;return said prisoner alias and stop the function
				EndIf
				
		EndWhile
		
	Return None
	;return "none" if this actor is not found in the prisoners
EndFunction
				
				
				
ReferenceAlias Function GetEmptyPrisonerAlias()
;gets an empty prisoner alias to use (for other functions, like AddPrisoner)
	Int i = PrisonerAliases.Length
	;the total number of prisoner aliases
		While i > 0
			i -= 1
			;this sets the i counter to count backwards, effectively checking all the items in the array.
			;it will stop once i=0 i.e. has reached the first item of the array
				If PrisonerAliases[i].GetReference() == None
				;when the scan finds a prisoner alias that is empty, i.e. has not been given to an actor
					Return PrisonerAliases[i]
					;forward this empty prisoner alias to whomever asked for it (probably another function) and stops the function
				EndIf
		
		EndWhile
	
	Return None
	;if no empty prisoner alias found, return "none"
EndFunction


Function AddPrisoner(Actor akActorToBecomePrisoner)
;Puts the actor in the Prisoner alias, effectively making her a prisoner

	If GetPrisonerAlias(akActorToBecomePrisoner) != none
	;if the GetPrisonerAlias responds that this actor is assigned to a prisoner alias i.e. she's already a prisoner
		Debug.MessageBox("Already a prisoner")

	ElseIf GetEmptyPrisonerAlias() == none
	;if there is no empty prisoner alias in the quest, uses the GetEmptyPrisonerAlias function to test this
		Debug.MessageBox("Prison is full, no more inmates accepted")
	
	ElseIf GetEmptyPrisonerAlias().ForceRefIfEmpty(akActorToBecomePrisoner) == true
	;assign the empty prisoner alias to the actor, then return true for success, false for failure
		Debug.MessageBox("Prisoner added. Enjoy!")
		PrisonerInitialization(akActorToBecomePrisoner)
		;initializes the prisoner
		
	Else
	;if failed for any other reason
		Debug.MessageBox("Failed to add prisoner")
		
	EndIf
EndFunction


Function ReleasePrisoner(Actor akPrisonerToRelease)
;removes the Prisoner from the Prisoner alias
	If GetPrisonerAlias(akPrisonerToRelease) == !none
	;calls GetPrisonerAlias to get the alias this Prisoner is assigned to and makes sure the role exists
		(GetPrisonerAlias(akPrisonerToRelease)).Clear()
		;clears the alias this Prisoner was assigned to
		Debug.MessageBox("Prisoner removed. Bye Bye")
		
	Else
		Debug.MessageBox("This actor is not a Prisoner")
	
	EndIf

EndFunction


Function PrisonerInitialization(Actor akPrisoner)
;initializes the actor by setting the correct ranks in all the factions
	akPrisoner.SetFactionRank(ITDInCellPrisonerFaction,0)
	Debug.Notification("Prisoner initialized")
EndFunction


;##  PRISONER FOLLOWER  ##

Function MakePrisonerFollower(Actor akPrisonerToFollow)
;makes the prisoner activate her ITDPrisonerFollowerPackage, making her follow the player and obey commands
	If akPrisonerToFollow.GetFactionRank(ITDPrisonerFollowerFaction) == 0
	;an extra check for safety
		akPrisonerToFollow.SetFactionRank(ITDPrisonerFollowerFaction, 1)
		Debug.Notification("Prisoner is following")
	
	EndIf
	
EndFunction

Function UnMakePrisonerFollower(Actor akPrisonerFollower)
;makes the prisoner deactivate her ITDPrisonerFollowerPackage, making her stop following the player
	If akPrisonerFollower.GetFactionRank(ITDPrisonerFollowerFaction) == 1
	;an extra check for safety
		akPrisonerFollower.SetFactionRank(ITDPrisonerFollowerFaction, 0)
		Debug.Notification("Prisoner has stopped following")
		
	EndIf
	
EndFunction

	
;##  LOCKING IN CELLS  ##

Function PutPrisonerInCell(Actor akPrisonerToPutInCell)
;adds the prisoner to the ITDInCellPrisonerFaction and forces her to evaluate her packages, effectively locking her inside a jail cell

	If akPrisonerToPutInCell == PlayerRef
	;if the script attempts to run on the player
		Debug.Notification("Player is the Master!")
		
		return
		
	ElseIf akPrisonerToPutInCell.GetFactionRank(ITDInCellPrisonerFaction) == 1
	;if the prisoner is already locked up
		Debug.Notification("Prisoner already in cell")
		
	ElseIf bCanBeImprisoned(akPrisonerToPutInCell) == true
	;if the actor is not a prisoner but can be imprisoned
		AddPrisoner(akPrisonerToPutInCell)
		
	EndIf
	
	If bActorIsITDPrisoner(akPrisonerToPutInCell) == true
	;an extra check to make sure the actor is indeed a prisoner of ITD
		akPrisonerToPutInCell.SetFactionRank(ITDInCellPrisonerFaction, 1)
		;updates the prisoner's faction rank to show she's locked in a cell
		akPrisonerToPutInCell.EvaluatePackage()
		Debug.Notification("Prisoner has been put in the cell")
		
	Else
		Debug.MessageBox("Could not put this actor in cell")
		
	EndIf
EndFunction


Bool Function bCanBeImprisoned(Actor ActorToBecomePrisoner)
;checks that the actor can be imprisoned: she is required to not be imprisoned already and have her wrists bound
	If bActorIsITDPrisoner(ActorToBecomePrisoner) == false && ActorToBecomePrisoner.WornHasKeyword(zbfEffectWrist) == true
		return True
	Else
		return False
	EndIf
EndFunction
	


Function RemovePrisonerFromCell(Actor akPrisonerToRemoveFromCell)
;removes the prisoner from the ITDInCellPrisonerFaction and forces her to evaluate her packages, effectively letting her out of the jail cell

	If akPrisonerToRemoveFromCell == PlayerRef
	;if the script attempts to run on the player
		Debug.Notification("Player is the Master!")
		
		return

	ElseIf akPrisonerToRemoveFromCell.GetFactionRank(ITDInCellPrisonerFaction) == 0
	;if the prisoner was not in ITDInCellPrisonerFaction i.e. was not locked up
		Debug.Notification("Prisoner was not locked up to begin with!")
		
	ElseIf akPrisonerToRemoveFromCell.GetFactionRank(ITDInCellPrisonerFaction) == 1
	;an extra check to make sure the actor is indeed locked up in her cell
	;redundancy?
		akPrisonerToRemoveFromCell.SetFactionRank(ITDInCellPrisonerFaction, 0)
		;gives the prisoner the rank 0 in the ITDInCellPrisonerFaction
		akPrisonerToRemoveFromCell.EvaluatePackage()
		;forces her to evaluate her package, thus discovering she is not locked up anymore
		Debug.Notification("Prisoner was let out of her cage")

	EndIf	
EndFunction
 

;##  STOPPING  ##

Function ITDStop()
;stops ITD, by stopping ITDQuest, ITDPosingQuest and ITDConfigMenuQuest
	ITDConfigMenuQuest.Stop()
	;stops ITDConfigMenuQuest
	Debug.MessageBox("ITD MCM menu stopped")
	
	ITDPosingQuest.Stop()
	;stops ITDPosingQuest
	Debug.MessageBox("ITD posing submodule stopped")
	
	Self.Stop()
	;stops ITDQuest
	Debug.MessageBox("ITD stopped")
	
EndFunction

Function RemoveAllITDFactions()
EndFunction

Function RemoveAllITDPackages()
EndFunction

Function UndoSetDontMove()
EndFunction

Function UndoSlavePositions()
EndFunction


;##  SAFER CODING  ##

Bool Function bActorIsITDPrisoner(Actor akActorToCheck)
;a function that makes sure the actor is a prisoner in the ITD
	If akActorToCheck.IsInFaction(ITDPrisonerFaction)
	;checking amounts to checking for the ITDPrisonerFaction as this is only given to the PrisonerAliases
		return true
	Else
		return false
	EndIf
EndFunction

Function SafelyAddToITDFaction(Actor akActorChangingFactions, Faction FactionToAdd)
;safely adds an actor to an ITD faction
	If bActorIsITDPrisoner(akActorChangingFactions)
	;only executes if the actor is a prisoner in ITD, otherwise we could leave behind unused factions when the mod is removed
		akActorChangingFactions.AddToFaction(FactionToAdd)
		;adds the actor to the faction
	Else
		Debug.MessageBox("Cancelled: Actor is not an ITD Prisoner Alias, cannot safely add to ITD factions")
	EndIf
EndFunction

Function SafelyRemoveFromITDFaction(Actor akActorChangingFactions, Faction FactionToRemove)
;safely removes an actor from an ITD faction
	If bActorIsITDPrisoner(akActorChangingFactions)
	;only executes if the actor is a prisoner in ITD
		akActorChangingFactions.RemoveFromFaction(FactionToRemove)
		;removes the actor from the faction
	Else
		Debug.MessageBox("Cancelled: Actor is not an ITD Prisoner Alias, cannot safely remove from ITD factions")
	EndIf
EndFunction
