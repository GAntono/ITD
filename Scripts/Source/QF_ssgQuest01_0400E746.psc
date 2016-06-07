;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 3
Scriptname QF_ssgQuest01_0400E746 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Lucy
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Lucy Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY PlayerRef
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_PlayerRef Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY MapMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MapMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Hulda
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Hulda Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Slaver
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Slaver Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
	;BEGIN AUTOCAST TYPE ssgQ01
	Quest __temp = self as Quest
	ssgQ01 kmyQuest = __temp as ssgQ01
	;END AUTOCAST
	;BEGIN CODE
	SetObjectiveDisplayed(20)
	
	Alias_Slaver.GetActorReference().Enable()
	Actor LucyRef = Alias_Lucy.GetActorReference()
	LucyRef.Enable()
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

Form Property zbfWristRope01 Auto 

Form Property zbfGagCloth Auto
