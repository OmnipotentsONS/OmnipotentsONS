UTCompOmni - Omnipotents version of UTComp 

Server installation

Copy these folders to the UT2004 folder:

Sounds\
StaticMeshes\
Textures\
System\


The original UTComp help file is in the Help\ folder

Snarf's recommended settings for Omnipotents 2.0 server are in the UT2004.ini file.  
Copy all contents of this file to the bottom of the server's UT2004.ini file.

Clients/players can hit F5 during gameplay to set their own settings (turn off hit sounds, change brightskins, etc).


A list of ignored hit sounds is also in the UT2004.ini file.

To add more sounds to ignore, add a new line with the damage type of the sound to ignore, e.g.

IgnoredHitSounds=FireKill
IgnoredHitSounds=DamTypeChargingBeam    


This would ignore the fire burning of firetank and beam weapon of the hell bender.  

Release Info

1.10
- Merge all features we want from ONSPlusOmni into UTCompOmni
- ONSPlus features include 
  - Node isolation bonus for severing nodes (default is 20% of node points)
  - Draw vehicles on radar map
  - shared link bonus so multiple linkers get points
  - vehicle healing bonus, heal vehicle health and receive points (default is 1 point for 500 health)
- Draw different vehicles in different colors on the minimap, use smaller icon for manta and scoprion types
- Add config option for changing PowerNode and PowerCore points (defaults are 5 for node and 10 for core (ONS defaults))
- Included UT2004.ini file updated with new values

1.9 
- Fix issue where team change kept wrong team color.  bEnemyBasedSkins ands bEnemyBasedModels are hard coded now.  Changing gui values has no effect. 
- Fix issue where ONSPlusOmni HUD conflicted with UTComp HUD
- Default to bright skins


1.8c 
- Initial Release






