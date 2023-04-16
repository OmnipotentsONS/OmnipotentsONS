/******************************************************************************
This class handles the ion blast damage and bot fear.

Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/


class StormCasterBlast extends AvoidMarker;


//=============================================================================
// Properties
//=============================================================================

var() float Damage, DamageRadius, MomentumTransfer;
var() class<DamageType> MyDamageType;
var() float ThunderStormHeight;


//=============================================================================
// Variables
//=============================================================================

var int BlastStage;
var Controller InstigatorController;
var vector StormSpawnLocation;
var bool bStormSpawned;


function Reset()
{
	Destroy();
}

/**
Ion blast incoming.
*/
auto state IncomingBlast
{
	function BeginState()
	{
		local vector HN;

		if (Trace(StormSpawnLocation, HN, Location + vect(0,0,1) * (ThunderStormHeight + 500), Location, False) == None)
			StormSpawnLocation = Location + vect(0,0,1) * (ThunderStormHeight + 500);
	}
	
	function DamageStage(int Stage)
	{
		local Actor A;
		local range BlastRange;
		local vector BlastOrigin;
		local float Distance;
		local byte TeamN;

		BlastOrigin = Location + vect(0,0,35000);
		BlastRange.Max = BlastOrigin.Z - 3500 * Stage;
		if ( Stage <= 10 )
			BlastRange.Min = BlastRange.Max - 3500;
		else
			BlastRange.Min = -99999999;
		if ( Stage == 1 )
			BlastRange.Max = 99999999;

		//log(Stage @ BlastOrigin @ BlastRange.Max @ BlastRange.Min);
		foreach AllActors(class'Actor', A)
		{
			if ( !A.bCanBeDamaged || A.Location.Z > BlastRange.Max || A.Location.Z < BlastRange.Min )
				continue;

			Distance = VSize(BlastOrigin * vect(1,1,0) - A.Location * vect(1,1,0));
			if ( Distance > DamageRadius || !FastTrace(A.Location, A.Location + vect(0,0,3000)) && !FastTrace(A.Location - vect(0,0,3000), A.Location) )
				continue;

			Distance = 1 - Sqrt(Distance / DamageRadius);

		 if (A.IsA('Pawn')) TeamN = Pawn(A).GetTeamNum();
		  else TeamN = 255; // no team
		
	  	if ( TeamNum != 255 && TeamN == TeamNum) {
				continue; // Blast doesn't hurt team
	   	}
			A.SetDelayedDamageInstigatorController(InstigatorController);
			A.TakeDamage(Damage * Distance, Instigator, A.Location, Normal(A.Location - BlastOrigin) * MomentumTransfer * Distance, MyDamageType);
		}
		
		if (!bStormSpawned && BlastRange.Max < StormSpawnLocation.Z)
			SpawnStorm();
	}

	function SpawnStorm()
	{
		local ThunderStorm Storm;
		
		if (bStormSpawned)
			return;

		Storm = Spawn(class'ThunderStorm',,, StormSpawnLocation - vect(0,0,500));
		if (Storm != None)
		{
			Storm.TeamNum = TeamNum;
			Storm.InstigatorController = InstigatorController;
		}
		bStormSpawned = True;
	}

Begin:
	if (Instigator != None)
		InstigatorController = Instigator.Controller;
	Spawn(class'StormCasterBlastEmitter',,, Location);
	if ( Instigator != None && Instigator.PlayerReplicationInfo != None && Instigator.PlayerReplicationInfo.Team != None )
		TeamNum = Instigator.PlayerReplicationInfo.Team.TeamIndex;
	StartleBots();

	while (BlastStage++ <= 10) {
		Sleep(0.1);
		DamageStage(BlastStage);
	}
	
	// fallback, shouldn't be necessary
	SpawnStorm();
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     Damage=50.000000
     DamageRadius=2500.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'StormCasterV3.DamTypeStormCasterBlast'
     ThunderStormHeight=6000.000000
     LifeSpan=30.000000
     CollisionRadius=3000.000000
     CollisionHeight=100.000000
}
