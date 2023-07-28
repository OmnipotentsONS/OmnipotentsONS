Dependencies:
#exec obj load File=LinkScorpion3Tex.utx (scorps)
#exec obj load File=LinkTank3Tex.utx  (linkTanks)
ONSToys1Mesh (Mesh from orignal link tank)


Variants:

General Notes:   
Green/Gold Link Beams, are like standard beams, and do NOT self heal when doing damage.  They generally link stack (meaning number of linkers times linkmultipler does more damage/healing)
Both Driver Weapons and Turret weapons will show number of linkers on HUD when being linked and link stacking.
Purple Link Beams, aka Dark Beams, will self heal with doing damage (drain effect).  Generally do NOT link stack (Vampire tank is an exception)

LinkTank3Heavy: 3 Seats. Basically the current Link Tank 2.0 (ONSlaughtToys1 Kamek) with a bit more health, and slightly larger.  Has different coloration than standard Link Tank 3.0
Health: 1250 start, healable to 1500
Driver Weapon:  Link Turret (plasma blast/link beam) - Link Stacking 1.5
Secondary Weapon: Plasma Turret (plasma blast/zoom) - Link Stacking 1.0
Tertiary Weapon:  Link Laser Turret( lasers/zoom) - Link Stacking 1.5 (watch out flyers!)

LinkTank3 3 seats This is the basically Link tank 2.0 Cleaned up for Link Tank 3.0
Health: 900 start, healable to 1250
(Past link tanks had health from 550 to 1000, Figured the LinkBadger is 1000 so this TANK shouldn't be that far off)
Driver Weapon:  Link Turret (plasma blast/link beam) - Link Stacking 1.5
Secondary Weapon: Plasma Turret (plasma blast/zoom) - Link Stacking 1.0
Tertiary Weapon:  Link Laser Turret( lasers/zoom) - Link Stacking 1.5 (watch out flyers!)

VampireTank 2 Seats (Dark theme, faster speed similar to DarkRailTank, 
Driver Weapoon: Primary LinkBeam (like Alt-Fire on linktank but with self healing) linkstacks with 0.8 multiplier, AltFire- DarkEnergy Shockwave Blast (like Ion tank)) (Note this does NOT harm empty vehicles, but some vehicle types take EXTRA damage)
Secondary Weapon: Dark Link Turret (dark plasma/dark link beam) Linkstacks with 1.0 multiplier plasma/ 0.8 on beam.
Starts with 766 health can go to 1366

LinkScorpion: 1 seat, Fast ground linker
Driver Weapon:  Primary is link beam, stacking 1.5 multiplier, alt-fire is boost like EONS Scorp.
Health: 375


TickScorpion: 1 seat, Fast ground linker with special power to get "bigger"
Driver Weapon: Primary DarkLinkBeam - Does damage and self heals.  No stacking.  Damage is variable based on health (), AltFire - DarkWeb (Like Webcaster), more powerful depending on health (Gun will get bigger depending on health)
Health:  300 healable to 900.
Notes:  As health increases vehicle speed/mass also increase, gun size increases (damage from beam, number of nodes in the sticky web), Tick gets darker in color based on health
I wanted to make it acutally "grow" in Size, but the UT engine cannot recalculate the Collision Size...so it can grow in size except the Collision box which stays same as when spawned.  Kind sucked (ok bad pun)
At 300 health Damage from beam = 12 (Base LinkGun is 9), up to 26 when fully engorged!  

Lamprey: Manta that Links, based on Hornet (Machine gun manta)
Driver Weapon:  Primary Dark LinkBeam, heals itself, has "tractor effect" (weaker than Pulse Traitor though) to pull victims (especially flyers) close to suck them dry. AltFire - Smaller version of DarkEnergyShockWave (like Vampire Tank)
Health: 300 healable to 325
Issues:  When you first enter and sitting on top of static mesh the view is messed up.  Flying up higher fixes it, this is because the Hornet was Raptor base with Manta mesh/skin.  Can't seem to fix it but its a minor thing.

ONSLinkFlyer 1.1 
Added HUD when being linked. Fixed LinkBeam tracking on server -- before you'd see the beam not track properly if you were the client.

Each LinkWeapon has a UT2004.ini config for VehicleHealScore, the number of healed points to equal one player score point. Default is 600 can be changed in the .ini
like
[LinkVehiclesOmni.LampreyGun]
VehicleHealScore=600

[LinkVehiclesOmni.LinkScorpion3Gun]
VehicleHealScore=600

[LinkVehiclesOmni.TickScorpion3Gun]
VehicleHealScore=600

[LinkVehiclesOmni.LinkTank3Gun]
VehicleHealScore=600

[LinkVehiclesOmni.LinkTank3HeavyGun]
VehicleHealScore=600

[LinkVehiclesOmni.VampireTank3Gun]
VehicleHealScore=600
[LinkVehiclesOmni.VampireTank3SecondaryTurret]
VehicleHealScore=600








- The Wraith/Odin do NOT stack because draining health and healing is too OP IMO, especially in a flyer -- Chupa (link flyer) is too OP IMO

The Wraith/Odin/Chupa have their own packages

- There's also a bug in the Odin that it can heal itself, which I meant to fix, but its kind of a fun feature in that tank..

And we also have the Link Badger (1000 pts) kind of fits in between, but its a bit OP IMO, but its a favorite so that's not included here, and if I changed it McLovin would hunt me down.