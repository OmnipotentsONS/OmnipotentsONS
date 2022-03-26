// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusScoreRules extends GameRules;

var ONSPlusGameReplicationInfo OPGRI;
var ONSPlusMutator MutatorOwner;

var array<ONSPlusTriggerHook> NodeMonitors;
var array<ONSPlusTriggerHook> VehicleSpawnMonitors;

var array<GameObjective.ScorerRecord> SavedScorers;

var bool bGrabResult;
var int PreIsolated;

delegate NotifyUpdateLinkStateHook(ONSPowerCore Node);

// Nasty hacks to monitor when a node is destroyed (for the bonus score you get when isolating nodes), also added code for the enhanced radar map
function OPInitialise()
{
	local NavigationPoint n;
	local array<Name> IteratedNames, VFIteratedNames;
	local int i, j;
	local bool bContinue;
	local Mutator m;
	local ONSVehicleFactory VF;

	Super.PreBeginPlay();

	if (MutatorOwner == none)
	{
		for (m=level.game.BaseMutator; m!=none; m=m.NextMutator)
		{
			if (ONSPlusMutator(m) != none)
			{
				MutatorOwner = ONSPlusMutator(m);
				break;
			}
		}
	}

	if (MutatorOwner == none)
	{
		Log("ERROR: ONSPlusScoreRules.MutatorOwner IS NONE IN PREBEGINPLAY", 'ONSPlusError');
		return;
	}

	if (ONSOnslaughtGame(level.game) == none)
		return;

	// Setup the node monitors
	if (MutatorOwner.bNodeIsolateBonus)
	{
		for (n=Level.NavigationPointList; n!=none; n=n.NextNavigationPoint)
		{
			if (ONSPowerNode(n) != none)
			{
				NotifyUpdateLinkStateHook = ONSPowerNode(n).UpdateLinkState;

				// Hook the nodes NotifyUpdateLinks delegate
				ONSPowerNode(n).UpdateLinkState = UpdateLinkStateHook;

				// Give the node an event name if it doesn't already have one
				if (ONSPowerNode(n).DestroyedEventName == '')
					ONSPowerNode(n).DestroyedEventName = 'ONSPlusNodeDestroyed';

				for (i=0; i<IteratedNames.Length; i++)
				{
					if (IteratedNames[i] == ONSPowerCore(n).DestroyedEventName)
					{
						bContinue = True;
						break;
					}
				}

				if (bContinue)
				{
					bContinue = False;
					continue;
				}


				// If the code reaches this point then a new DestroyedEventName has been found, add the current name to the list and spawn a trigger hook
				IteratedNames[IteratedNames.Length] = ONSPowerCore(n).DestroyedEventName;

				NodeMonitors[NodeMonitors.Length] = Spawn(Class'ONSPlusTriggerHook');
				NodeMonitors[NodeMonitors.Length-1].Master = Self;
				NodeMonitors[NodeMonitors.Length-1].Tag = ONSPowerCore(n).DestroyedEventName;
			}
		}
	}

	// Setup the vehicle factory monitors
	if (MutatorOwner.bAllowEnhancedRadar)
	{
		foreach AllActors(Class'ONSVehicleFactory', VF)
		{
			if (VF.Event == '')
				VF.Event = 'ONSPlusVehicleSpawned';

			for (j=0; j<VFIteratedNames.Length; j++)
			{
				if (VFIteratedNames[j] == VF.Event)
				{
					bContinue = True;
					break;
				}
			}

			if (bContinue)
			{
				bContinue = False;
				continue;
			}

			// If the code reaches this point then a new Event (for vehiclespawns) has been found, add the current name to the list and spawn a trigger hook
			VFIteratedNames[VFIteratedNames.Length] = VF.Event;

			VehicleSpawnMonitors[VehicleSpawnMonitors.Length] = Spawn(Class'ONSPlusTriggerHook');
			VehicleSpawnMonitors[VehicleSpawnMonitors.Length-1].GRIMaster = ONSPlusGameReplicationInfo(level.game.GameReplicationInfo);
			VehicleSpawnMonitors[VehicleSpawnMonitors.Length-1].Tag = VF.Event;
		}
	}
}

// Initialise the vehicle spawn list for a certain player
function InitialiseVehicleSpawnList(ONSPlusPlayerReplicationInfo NewPlayer)
{
	local int i;

	for (i=0; i<VehicleSpawnMonitors.Length; i++)
		VehicleSpawnMonitors[i].InitialiseVehicleSpawnList(NewPlayer);
}

function PowerNodeDestroyed(ONSPowerNode Node)
{
	local NavigationPoint n;
	local int IsolatedNum;

	for (n=Level.NavigationPointList; n!=none; n=n.NextNavigationPoint)
		if (ONSPowerNode(n) != none && ONSPowerNode(n).bSevered && (ONSPowerNode(n).DefenderTeamIndex == 0 || ONSPowerNode(n).DefenderTeamIndex == 1))
			IsolatedNum++;

	PreIsolated = IsolatedNum;
	SavedScorers = Node.Scorers;

	bGrabResult = True;
}

function UpdateLinkStateHook(ONSPowerCore Node)
{
	local NavigationPoint n;
	local int IsolatedNum, i;
	local float ScoreBonus;

	NotifyUpdateLinkStateHook(Node);

	if (bGrabResult)
	{
		if (OPGRI == none && level.game.GameReplicationInfo != none && ONSPlusGameReplicationInfo(level.game.GameReplicationInfo) != none)
			OPGRI = ONSPlusGameReplicationInfo(level.game.GameReplicationInfo);

		if (OPGRI == none)
			return;

		for (n=Level.NavigationPointList; n!=none; n=n.NextNavigationPoint)
			if (ONSPowerNode(n) != none && ONSPowerNode(n).bSevered && (ONSPowerNode(n).DefenderTeamIndex == 0 || ONSPowerNode(n).DefenderTeamIndex == 1))
				IsolatedNum++;


		// We know how many powernodes have been isolated from destroying this node, update the scores of the contributors
		if (IsolatedNum - PreIsolated > 0)
		{
			for (i=0; i<SavedScorers.Length; i++)
			{
				if (SavedScorers[i].C != none)
				{
					ScoreBonus = float(Node.Score) * SavedScorers[i].Pct * (float(OPGRI.IsolateBonusPctPerNode * (IsolatedNum - PreIsolated)) * 0.01);
					SavedScorers[i].C.PlayerReplicationInfo.Score += ScoreBonus;
				}
			}
		}
		//else if (IsolatedNum - PreIsolated < 0)
			//Log("Warning:"@(IsolatedNum - PreIsolated)@"nodes are indicated as being isolated", 'ONSPlusError');
		// NOTE: The above code can happen when a single isolated node gets destroyed due to running out of health, no need to give a warning


		bGrabResult = False;
		PreIsolated = 0;
	}
}

function int NetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local float CurDamage;

	CurDamage = Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

	if (DamageType != Class'DamTypeLinkShaft' && DamageType != Class'DamTypeLinkPlasma' && injured != None
		&& Vehicle(injured) != None && !Vehicle(injured).IsVehicleEmpty() && instigatedBy != None
		&& instigatedBy != injured && CurDamage > 0 && instigatedBy.Controller != none
		&& instigatedBy.Controller.PlayerReplicationInfo != none
		&& ONSPlusPlayerReplicationInfo(instigatedBy.Controller.PlayerReplicationInfo) != none)
	{
		if (OPGRI == none && PlayerController(instigatedBy.Controller) != none && PlayerController(instigatedBy.Controller).GameReplicationInfo != none
			&& ONSPlusGameReplicationInfo(PlayerController(instigatedBy.Controller).GameReplicationInfo) != none)
			OPGRI = ONSPlusGameReplicationInfo(PlayerController(instigatedBy.Controller).GameReplicationInfo);

		if (OPGRI != none)
		{
			if (Vehicle(injured).Team != instigatedBy.Controller.PlayerReplicationInfo.TeamID)
				ONSPlusPlayerReplicationInfo(instigatedBy.Controller.PlayerReplicationInfo).AddVehicleDamageBonus(CurDamage / OPGRI.DamageScoreQuota);
			else
				ONSPlusPlayerReplicationInfo(instigatedBy.Controller.PlayerReplicationInfo).AddVehicleDamageBonus(-1.0 * CurDamage / OPGRI.DamageScoreQuota);
		}
	}

	return CurDamage;
}

function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
{
	local array<NavigationPoint> PointList;

	if (MutatorOwner == none || !MutatorOwner.bAllowEnhancedRadar || Player == none || AIController(Player) != none)
		return Super.FindPlayerStart(Player, InTeam, incomingName);

	// HACK HACK HACK HACK HACK HACK HACK MUAHAHAHAHAH! (I'm overriding the FindPlayerStart function)
	if (ONSOnslaughtGame(level.game) != none && Player.PlayerReplicationInfo != none && ONSPlusPlayerReplicationInfo(Player.PlayerReplicationInfo) != none
		&& !ONSPlusPlayerReplicationInfo(Player.PlayerReplicationInfo).bLookingForStart)
	{
		PointList = ONSPlusPlayerReplicationInfo(Player.PlayerReplicationInfo).ONSPlusFindPlayerStart(True);

		if (PointList.Length > 0 && PointList[0] != none)
			return PointList[0];
	}

	return Super.FindPlayerStart(Player, InTeam, incomingName);
}

function GetServerDetails(out GameInfo.ServerResponseLine ServerState)
{
	Class'ONSOnslaughtGame'.static.AddServerDetail(ServerState, "ONSPlusVersion", Class'ONSPlusMutator'.static.GetONSPlusVersion());
}