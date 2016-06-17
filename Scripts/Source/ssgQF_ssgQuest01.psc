;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 9
Scriptname ssgQF_ssgQuest01 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY MapMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MapMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Hulda
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Hulda Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Lucy
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Lucy Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Slaver
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Slaver Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN AUTOCAST TYPE ssgQ01
Quest __temp = self as Quest
ssgQ01 kmyQuest = __temp as ssgQ01
;END AUTOCAST
;BEGIN CODE
SetObjectiveCompleted(20)

Actor playerRef = Alias_Player.GetActorReference()
Actor slaverRef = Alias_Slaver.GetActorReference()
Actor lucyRef = Alias_Lucy.GetActorReference()

slaverRef.MakePlayerFriend()
slaverRef.StopCombat()
slaverRef.SetNoBleedoutRecovery(False)

SexLabFramework SexLab = SexLabUtil.GetAPI()
zbfSexLab zbfSL = zbfSexLab.GetAPI()
Actor[] actors = zbfUtil.ActorList(lucyRef, playerRef)
zbfSexLabBaseEntry[] list = zbfSL.GetEntriesByTags(actors, asRequired = "Forced, Aggressive", aiMinActorCount = 2)
Int threadID = zbfSL.StartSexEx(actors, list, zbfUtil.ArgString("Forced, NoUndress, NoStart"))
sslThreadController thread = SexLab.GetController(threadID)
thread.StartThread()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN AUTOCAST TYPE ssgQ01
Quest __temp = self as Quest
ssgQ01 kmyQuest = __temp as ssgQ01
;END AUTOCAST
;BEGIN CODE
SetObjectiveDisplayed(20)
Alias_MapMarker.GetReference().AddToMap()

Actor slaverRef = Alias_Slaver.GetActorReference()
Actor lucyRef = Alias_Lucy.GetActorReference()
slaverRef.SetNoBleedoutRecovery(True)
slaverRef.AllowBleedoutDialogue(abCanTalk = True)
slaverRef.Enable()
lucyRef.Enable()
ssgMain ssg = ssgMain.GetAPI()
ssgSlave slaveLucy = ssg.SlotActor(LucyRef)
slaveLucy.SetBinding(zbfWristRope01)
slaveLucy.SetBinding(zbfGagCloth)
ssg.SetPoseExtended(slaveLucy, aiPoseIndex = 3)	;lying down
ssg.SetStruggleExtended(slaveLucy, abStruggle = True)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Armor Property zbfWristRope01 Auto 

Armor Property zbfGagCloth Auto
