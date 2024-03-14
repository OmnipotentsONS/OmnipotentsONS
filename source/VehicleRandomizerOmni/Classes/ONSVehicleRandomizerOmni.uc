//=============================================================================
// ONSVehicleRandomizer.
//=============================================================================
class ONSVehicleRandomizerOmni extends Info
	placeable;
// Updates for Omni )o( by pOOty
// Support for ignorning UltimateMappingTools.ONSUltimateONSFactory, in addtion to ForcedFactory
// This makes this package dependent on UltimateMappingTools (already on Omni server)
// https://wiki.beyondunreal.com/User:Crusha/UltimateMappingTools/UltimateONSFactory
// this might ignore those already have to check

// Support for Node Groups, flying, not flying or any (using Engine.Game.Pawn.bCanFly
//


// ONSVehicleRandomizer can be placed in any level and set up by the LD to
// randomize the vehicles placed, either on a per-round or per-game basis.

// Each "Node Group" defines a set of nodes (usually a pair of nodes, one on each
// side of the map). Each node group will have the same vehicles assigned to it.
// For instance, if you have two primary nodes with three vehicle factories,
// and the first primary randomly gets a Manta, Goliath, and Hellbender, the other
// primary will also have a Manta, Goliath, and Hellbender.
// Warning, each node in the Node Group must have the same number of vehicle factories!
struct NodeGroup
{
	var() edfindable array<ONSPowerCore> Nodes;		// Place all nodes in this group here.
	var() array< class<Vehicle> > BannedVehicles;	// Vehicles not to be spawned here
	var() float MaxWorth;							// Max worth of vehicles allowed to
													// spawn here. (If 0, Worth is ignored)
	var() float MinWorth;							// Min worth of vehicles allowed to
													// spawn here
   var() bool bFlyingOnly; // true only vehicles with Vehicle.bCanFly = true
// Haven't figured out how to get vehicle data in here
	
};
	
var(NodeGroups) array<NodeGroup> NodeGroups;

// Each Vehicle Definition defines a class of vehicle (ONSHoverBike, ONSRV, etc)
// and a "worth" assigned to that vehicle. When building vehicle setups for each
// node group, the total Worth of vehicles assigned to that group will never exceed
// the node group's MaxWorth. Worth values are arbitrary and completely up to the LD
// (for instance, a Manta can be 1 or 100, depending on how you rate other vehicles
// compared to the Manta)
// LD can also set a defined respawn time depending on whether the vehicle spawns at the
// PowerCore or at a PowerNode.
// Note that you can also set "None" as a vehicleclass. If "None" is selected by the
// randomizer, the vehicle factory will be disabled for that round.
struct VehicleDefinition
{
	var() class<Vehicle> VehicleClass;		// Class of vehicle
	var() float Worth;						// Worth of vehicle
	var() float CoreRespawnTime;			// Respawn time at PowerCore (assumes 15 if blank)
	var() float NodeRespawnTime;			// Respawn time at PowerNodes (assumes 15 if blank)
	var() bool bUnique;						// Set to true if you want these to be assigned
											// to only ONE NodeGroup
	var bool bAlreadyUsed;
};

var(Vehicles) array<VehicleDefinition> Vehicles;

// VehicleRandomizer can also be used as a built-in VehicleArena.
// In Arena mode, we just define a certain class of vehicles to replace all vehicles.
// However, for some vehicles, we may want to adjust the node health as well (particularly
// for slow movers
struct ArenaVehicleDefinition
{
	var() class<Vehicle> VehicleClass;		// Class of vehicle
	var() float CoreHealthOverride;			// Overrides PowerCore health if nonzero
	var() float NodeHealthOverride;			// Overrides PowerNode health if nonzero
	var() float CoreRespawnTime;			// Respawn time for vehicles at core
	var() float NodeRespawnTime;			// Respawn time for vehicles at powernode
	var() bool bDisableForcedVehicles;		// If true, ForcedVehicle/Ultimate factories are disabled for this round
	var() bool bReplaceForcedVehicles;		// If true, ForcedVehicle/Uttimate factories spawn the arena vehicle
};

var(Arena) bool bArenaFirst; // debug var
var(Arena) float ArenaChance;	// Chance of round/match being a VehicleArena match
var(Arena) array<ArenaVehicleDefinition> ArenaVehicles;	// Types of vehicles eligible for Arena

var(Music) bool bRandomizeMusic;
var(Music) array<string> Songs;

var class<Vehicle> ArenaVehicle;

var() bool bRandomizeEveryRound;	// if true, we randomize on each reset and not
									// just once.
var() bool bRandomizeLinkSetup;		// Randomizes link setup too.

const OVRVersion = "2.1";



// PBP, determine if we go Vehicle Arena or regular vehicle randomizing.
event PostBeginPlay()
{
	Super.PostBeginPlay();
	RandomizeVehicles();
}

function Reset()
{
	Super.Reset();
	if (bRandomizeEveryRound)
		RandomizeVehicles();
}

function RandomizeVehicles()
{
	local float f;
	local MusicReplicator MR;

	if (bRandomizeLinkSetup)
		ONSOnslaughtGame(Level.Game).FindLinkSetup();

	if (bRandomizeMusic)
	{
		foreach DynamicActors(class'MusicReplicator', MR)
		{
			MR.ServerChangeMusic(Songs[rand(Songs.Length)]);
			break;
		}
		if (MR == None)
			warn("** ONSVehicleRandomizer: No MusicReplicator found in level (must be present to change songs randomly)");
	}

	f = FRand();
	if (bArenaFirst)
	{
		f = 0;
		bArenaFirst = false;
	}

	if (f < ArenaChance)
		ArenaVehicleSetup();
	else
		VehicleRandomizerSetup();
}

// Arena Vehicle Setup
function ArenaVehicleSetup()
{
	local ONSVehicleFactory ovf;
	local int i;
	//local ONSPowerCore CloseCore;
	local ONSPowerNodeSpecial node;
	local ONSPowerCoreSpecial core;

	// Determine an Arena Vehicle
	i = Rand(ArenaVehicles.Length);
	ArenaVehicle = ArenaVehicles[i].VehicleClass;

	// Go through every Vehicle Factory and set the vehicle.
	foreach DynamicActors(class'ONSVehicleFactory', ovf)
	{
		// ignore turrets, and do nothing on ONSUltimateONSFactories (which can have random lists of vehicle for that factory -- pooty
		if (!(ovf.IsA('ONSTurretFactory') || ovf.IsA('UltimateONSFactory')))
		{
			// Special handling for "forced factories" (Mino spawn, hoverboards, etc)
			if (ONSForcedVehicleFactory(ovf) != None) {
				// Hoverboard factories will set this to true and spawn hoverboards no matter what
				if (ONSForcedVehicleFactory(ovf).bIgnoreVehicleRandomizer == False) {
					// Disable Forced Vehicle factories: Hammerhead/Mino spawn will have NO vehicle present
					if (ArenaVehicles[i].bDisableForcedVehicles) {
						ovf.VehicleClass = None;
						ovf.RespawnTime = ONSForcedVehicleFactory(ovf).DefaultSpawnTime;
					}
					// Replace Forced Vehicles: Hammerhead/Mino spawn will have the Arena Vehicle
					else if (ArenaVehicles[i].bReplaceForcedVehicles) {
						ovf.VehicleClass = ArenaVehicle;
			
						// Vehicle set, now set the respawn time.
						if (ONSOnslaughtGame(Level.Game).PowerCores[0].ClosestTo(ovf).bFinalCore)
						// If we belong to a final PowerCore, use Core Respawn instead of Node Respawn
							ovf.RespawnTime = ArenaVehicles[i].CoreRespawnTime;
						else
							ovf.RespawnTime = ArenaVehicles[i].NodeRespawnTime;
			
						if (ovf.RespawnTime == 0)
							ovf.RespawnTime = 15;
					}
					// If neither of the above is true, Hammerhead/Mino spawn will have a Hammerhead/Mino
					else {
						ovf.VehicleClass = ONSForcedVehicleFactory(ovf).DefaultVehicleClass;
						ovf.RespawnTime = ONSForcedVehicleFactory(ovf).DefaultSpawnTime;
					}
				}
			}
			else {
				ovf.VehicleClass = ArenaVehicle;
	
				// Vehicle set, now set the respawn time.
				if (ONSOnslaughtGame(Level.Game).PowerCores[0].ClosestTo(ovf).bFinalCore)
				// If we belong to a final PowerCore, use Core Respawn instead of Node Respawn
					ovf.RespawnTime = ArenaVehicles[i].CoreRespawnTime;
				else
					ovf.RespawnTime = ArenaVehicles[i].NodeRespawnTime;
	
				if (ovf.RespawnTime == 0)
					ovf.RespawnTime = 15;
			}
		}
	}

	// If custom node health set, set it
	foreach DynamicActors(class'ONSPowerCoreSpecial',core)
	{
		if (ArenaVehicles[i].CoreHealthOverride != 0)
			core.DamageCapacity = ArenaVehicles[i].CoreHealthOverride;
		else
			core.DamageCapacity = core.CoreHealth;
	}

	// If custom node health set, set it
	foreach DynamicActors(class'ONSPowerNodeSpecial',node)
	{
		if (ArenaVehicles[i].NodeHealthOverride != 0)
			node.DamageCapacity = ArenaVehicles[i].NodeHealthOverride;
		else
			node.DamageCapacity = node.NodeHealth;
	}
}

// Vehicle Randomizer
function VehicleRandomizerSetup()
{
	local array<VehicleDefinition> UseVehicles;
	local array<ONSVehicleFactory> UseFactories;
	local ONSVehicleFactory ovf;
	local int NumVehicles;
	local int i, j, k, l, m, Iter;
	local bool bBanned;
	local float CurrentWorth;
	local ONSPowerCoreSpecial core;
	local ONSPowerNodeSpecial node;
	local ONSForcedVehicleFactory fvfact;
  local bool bGotFlyer;

//	log(self@"Vehicle Randomization Start",'KDebug');

	// Reset all PowerNodes and PowerCores to regular health in case they were altered by a vehicle arena
	foreach DynamicActors(class'ONSPowerCoreSpecial',core)
	{
		core.DamageCapacity = core.CoreHealth;
	}
	foreach DynamicActors(class'ONSPowerNodeSpecial',node)
	{
		node.DamageCapacity = node.NodeHealth;
	}

	// Reset vehicle usage
	for (i = 0; i < Vehicles.Length; i++)
		Vehicles[i].bAlreadyUsed = false;

	// Go through each node group and determine vehicles to assign.
	for (i = 0; i < NodeGroups.Length; i++)
	{
//		log("NODE GROUP"@i,'KDebug');
		NumVehicles = 0;
		// Each nodegroup consists of at least one powernode
		for (j = 0; j < NodeGroups[i].Nodes.Length; j++)
		{
//			log("Node:"@NodeGroups[i].Nodes[j],'KDebug');
			// Find all vehicle factories belonging to this node.
			UseFactories.Length = 0;
			foreach DynamicActors(class'ONSVehicleFactory', ovf)
			{
				// Add factory if close to this node.
				if (NodeGroups[i].Nodes[j].ClosestTo(ovf) == NodeGroups[i].Nodes[j])
				{
//					log("Factory added:"@ovf,'KDebug');
					UseFactories.Insert(0, 1);
					UseFactories[0] = ovf;
				}
			}

			// First node in the group. Figure out what vehicles we're going to use for
			// the entire group.
			if (j == 0)
			{
//				log("First node of group -- Create vehicle list.",'KDebug');
				if (NodeGroups[i].MaxWorth == 0)
					NodeGroups[i].MaxWorth = MaxInt;
				CurrentWorth = -1;
				Iter = 0;
				while ((CurrentWorth < NodeGroups[i].MinWorth || CurrentWorth > NodeGroups[i].MaxWorth) && (Iter < 100))
				{
					CurrentWorth = 0;
					Iter++;
					UseVehicles.Length = 0;
					for (k = 0; k < UseFactories.Length; k++)
					{
						// LDs might want some vehicles to stay constant -- maybe a
						// high-powered core-only vehicle like a Min)o(taur.
						// Skip processing if so.
						// or if its UltimateONSFactory - which can be random list on its own
						if (!(UseFactories[k].isA('ONSForcedVehicleFactory') || UseFactories[k].IsA('ONSTurretFactory') || UseFactories[k].IsA('UltimateONSFactory') )) 
								// ignore turrets, and do nothing on ONSUltimateONSFactories (which can have random lists of vehicle for that factory -- pooty
								// why they use hard coded class name vs. IsA is strange, coverted to IsA so that not dependent on other packages
								// ie. OnslaughtToys1.ONSTurretFactory
		 					
						{
								// Select a random vehicle and insert it
								UseVehicles.Insert(0,1);
							  m = rand(Vehicles.Length);
								// m was never intialized originally relying on default int as 0?? which mean first match would alwasy get selected - pooty
								// If it's a unique vehicle already used somewhere else, 
								// keep trying
								bBanned = true;
								//log(self@"check if banned"@Vehicles[m].VehicleClass,'KDebug');
								//lVehicle = Vehicles[m].VehicleClass;
								
								
							  // Check Banned Vehicles - stock code
							  while ((Vehicles[m].bUnique && Vehicles[m].bAlreadyUsed) || bBanned)
									{
										m = rand(Vehicles.Length);
										bBanned = false;
										for (l = 0; l < NodeGroups[i].BannedVehicles.Length; l++)
										{
											//log("check"@NodeGroups[i].BannedVehicles[l],'KDebug');
											if (Vehicles[m].VehicleClass == NodeGroups[i].BannedVehicles[l])
											{
												//log("banned",'KDebug');
												bBanned = true;
											}
																					
										}
									}
							
						//  log(self@"Vehicle="@Vehicles[m].VehicleClass@" VehicleCanFly"@Vehicles[m].VehicleClass.default.bCanFly);
						//	log(self@"NodeGroups[i].Nodes="@NodeGroups[i].Nodes[0]@" bFlyingOnly="@NodeGroups[i].bFlyingOnly);
							// the above freaking works!
							
							// Check non Flying if flying only
							bGotFlyer = false;
							while (NodeGroups[i].bFlyingOnly && !bGotFlyer )
						
							    {
								    m = rand(Vehicles.Length);
								  //  log(self@"In FlyerCheck Vehicle="@Vehicles[m].VehicleClass@" VehicleCanFly"@Vehicles[m].VehicleClass.default.bCanFly);
								    if (Vehicles[m].VehicleClass.default.bCanFly ) {
								    		// add checks to unique 03/2024 pooty
								    		if (!(Vehicles[m].bUnique && Vehicles[m].bAlreadyUsed))
								           bGotFlyer=True;
								    //    log(self@"GotFlyer="@Vehicles[m].VehicleClass);
								    }    
									}
							
							UseVehicles[0] = Vehicles[m];
							Vehicles[m].bAlreadyUsed = true;
							CurrentWorth += UseVehicles[0].Worth;
							//log(self@"Vehicle"@k@": "@UseVehicles[0].VehicleClass,'KDebug');
						}
/*
						// If restoring from an Arena game, reset Forced Factories to their regular class
						else if (ONSForcedVehicleFactory(UseFactories[k]) != None) {
							log("Resstoring"@UseFactories[k]@"to default class"@ONSForcedVehicleFactory(UseFactories[k]).DefaultVehicleClass,'KDebug');
							ONSForcedVehicleFactory(UseFactories[k]).VehicleClass = ONSForcedVehicleFactory(UseFactories[k]).DefaultVehicleClass;
							ONSForcedVehicleFactory(UseFactories[k]).RespawnTime = ONSForcedVehicleFactory(UseFactories[k]).DefaultSpawnTime;
						}
*/
					}
					//log(self@"Final vehicle setup is worth"@CurrentWorth@"-- Target worth between"@NodeGroups[i].MinWorth@"and"@NodeGroups[i].MaxWorth,'XADebug');
				}
			}

			// Vehicles determined, now actually do the changeover.
			l = 0;
			for (k = 0; k < UseFactories.Length; k++)
			{
				if (!(UseFactories[k].isA('ONSForcedVehicleFactory') || UseFactories[k].IsA('ONSTurretFactory') || UseFactories[k].IsA('UltimateONSFactory') )) 

				{
					UseFactories[k].VehicleClass = UseVehicles[l].VehicleClass;
					if (UseFactories[k].VehicleClass == None)
						UseFactories[k].bNeverActivate = true;
					else
					{
						UseFactories[k].bNeverActivate = false;
						if (NodeGroups[i].Nodes[j].bFinalCore)
						// If we belong to a final PowerCore, use Core Respawn instead of Node Respawn
							UseFactories[k].RespawnTime = UseVehicles[l].CoreRespawnTime;
						else
							UseFactories[k].RespawnTime = UseVehicles[l].NodeRespawnTime;
					}
					l++;
				}
			}
		}
	}

	// Make absolutely sure all "Forced Vehicles" return to normal
	foreach DynamicActors(class'ONSForcedVehicleFactory',fvfact)
	{
//		log("Resstoring"@fvfact@"to default class"@fvfact.DefaultVehicleClass,'KDebug');
		fvfact.VehicleClass = fvfact.DefaultVehicleClass;
		fvfact.RespawnTime = fvfact.DefaultSpawnTime;
	}
}

defaultproperties
{
	// to do set default mesh
	Texture = Texture'Engine.S_KVehFact'
	DrawScale = 3.0

}
