class OmniRedeemerII extends Redeemer;

defaultproperties
{
	   //FireModeClass(0)=Class'OmniRedeemerFire'
     FireModeClass(0)=Class'OmniNukes.OmniRedeemerIIFire'
     FireModeClass(1)=Class'OmniNukes.OmniRedeemerIIGuidedFire'
     //FireModeClass(1)=Class'RedeemerGuidedFire'
     SelectAnim="Pickup"
     PutDownAnim="PutDown"
     SelectAnimRate=0.667000
     PutDownAnimRate=1.000000
     PutDownTime=0.450000
     BringUpTime=0.675000
     SelectSound=Sound'WeaponSounds.Misc.redeemer_change'
     SelectForce="SwitchToFlakCannon"
     AIRating=1.500000
     CurrentRating=1.500000
     bNotInDemo=True
     Description="The first time you witness this upgrade nuclear device in action, you'll wet your pants.|Launch a FAST-moving and utterly devastating missile with the primary fire; but make sure you're out of the Nuker's massive blast radius before it impacts. The secondary fire allows you to guide the nuke yourself with a rocket's-eye view.||Keep in mind, however, that you are vulnerable to attack when steering the RedeemerII's projectile. Due to the extreme bulkiness of its ammo, the RedeemerII is exhausted after a single shot."
     DemoReplacement=Class'XWeapons.RocketLauncher'
     DisplayFOV=60.000000
     Priority=29
     SmallViewOffset=(X=26.000000,Y=6.000000,Z=-34.000000)
     CustomCrosshair=3
     CustomCrossHairColor=(B=128)
     CustomCrossHairScale=2.000000
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Circle2"
     InventoryGroup=0
     GroupOffset=1
     PickupClass=Class'OmniNukes.OmniRedeemerIIPickup'
     //PickupClass=Class'RedeemerPickup'
     PlayerViewOffset=(X=14.000000,Z=-28.000000)
     PlayerViewPivot=(Pitch=1000,Yaw=-400)
     BobDamping=1.400000
     AttachmentClass=Class'OmniNukes.OmniRedeemerIIAttachment'
     //AttachmentClass=Class'RedeemerAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=4,Y1=350,X2=110,Y2=395)
     ItemName="Omni BF Redeemer"
     Mesh=SkeletalMesh'Weapons.Redeemer_1st'
     DrawScale=1.300000
     UV2Texture=Shader'XGameShaders.WeaponShaders.WeaponEnvShader'
     HighDetailOverlay=Combiner'UT2004Weapons.WeaponSpecMap2'
}
