/**
Implements team shuffling on match start and after a quick first round and
various GameRules-only hooks to trigger mid-round balancing.

Copyright (c) 2009-2015, Wormbo

(1) This source code and any binaries compiled from it are provided "as-is",
without warranty of any kind. (In other words, if it breaks something for you,
that's entirely your problem, not mine.)
(2) You are allowed to reuse parts of this source code and binaries compiled
from it in any way that does not involve making money, breaking applicable laws
or restricting anyone's human or civil rights.
(3) You are allowed to distribute binaries compiled from modified versions of
this source code only if you make the modified sources available as well. I'd
prefer being mentioned in the credits for such binaries, but please do not make
it seem like I endorse them in any way.
*/

class EvenMatchRules extends GameRules config(EvenMatchPPH) parseconfig;


const SECONDS_PER_DAY = 86400;


var EvenMatchPPH Recent, RecentMap;
var KnownPlayerPPH KnownPlayers;
var KnownPlayerCategories KPCategories;

var ONSOnslaughtGame Game;
var MutTeamBalance EvenMatchMutator;
var int MinDesiredFirstRoundDuration;
var bool bBalancingMulligan, bSaveNeeded;
var int FirstRoundResult;
var int MatchStartTS;
var float ConfigPPHDiff;
var bool bAutobalance;

var float LastRestartTime;
var PlayerController LastRestarter, PotentiallyLeavingPlayer;
var array<string> CachedPlayerIDs;
var GamePPH CurrentGamePPH;
var int replicationHack;
var float LastCheckScoreTime;

struct CatAndPRI  {
		var PlayerReplicationInfo PRI;
		var int CatNum;
		var float PPH;
		var string PN; //player name for testing.
	};


//var int OldNumBots, OldMinPlayers;  // for removing / readding bots.
// See code, none of it works right anyway.

var bool bDebug;
var bool bVerbose;

replication
{
	reliable if (bNetInitial)
		MatchStartTS;

	unreliable if (bNetInitial || bNetDirty)
		CurrentGamePPH;
}


function SaveRecentPPH()
{
	if (bSaveNeeded) {
		if (EvenMatchMutator.bVerbose)
			log(Level.TimeSeconds$ " Saving PPH data...", 'EvenMatchDebug');
		Recent.SaveConfig();
		RecentMap.SaveConfig();
	}
	bSaveNeeded = False;
}

/**
Purge outdated PPH data and randomly swap sides if configured.
*/
function PreBeginPlay()
{
	local int i, j, Diff;
	
	EvenMatchMutator = MutTeamBalance(Owner);
	bDebug = EvenMatchMutator.bDebug;
	bVerbose = EvenMatchMutator.bVerbose;
	
	if (!Level.Game.bEnableStatLogging || !Level.Game.bLoggingGame)
		RemoteRole = ROLE_SimulatedProxy;

	// remove obsolete entries
	MatchStartTS = GetTS();
	// generic part of PPH database
	Recent = new(None, "EvenMatchPPHDatabase") class'EvenMatchPPH';
    KnownPlayers = new(None, "EvenMatchKnownPlayerDatabase") class'KnownPlayerPPH';
    /* Read KnownPlayerCategories, added pooty 10/24 */
    if (EvenMatchMutator.bUseKnownPlayerCategories) {
        KPCategories = new(None, "EvenMatchKnownPlayerCategories") class'KnownPlayerCategories';
        // Default Category is Zero (unknownplayers get 0)
        // Meaning if they aren't in KnownPlayers they get category 0
        // KnownPlayerCategories should always have Default Category 0
      
    }    
    CurrentGamePPH = spawn(class'GamePPH', self);
    replicationHack = 0;
   
   
    if (bDebug) {
    for(i=0;i<KPCategories.KPC.length;i++)
    {
        log("CatNum: "$KPCategories.KPC[i].CatNum$" "$KPCategories.KPC[i].CatDesc, 'EvenMatch');
    }
   
    /*
		for(i=0;i<KnownPlayers.PPH.length;i++)
    {
        log("KnownPlayer: "$KnownPlayers.PPH[i].ID$" "$KnownPlayers.PPH[i].Multiplier$" "$KnownPlayers.PPH[i].CatNum, 'EvenMatch');
    }
    */
    }


	while (Recent.MyReplacementStatsID.Length > 0 && Recent.MyReplacementStatsID[0] == "") {
		// just a little cleanup from older EvenMatch versions
		Recent.MyReplacementStatsID.Remove(0, 1);
	}
	if (Recent.PPH.Length == 0) {
		// always create DB file
		bSaveNeeded = True;
	}
	else {
		// look for outdated entries
		for (i = Recent.PPH.Length - 1; i >= 0; --i) {
			Diff = MatchStartTS - Recent.PPH[i].TS;
			if (Diff / SECONDS_PER_DAY > EvenMatchMutator.DeletePlayerPPHAfterDaysNotSeen) {
				// older than X days
				Recent.PPH.Remove(i, 1);
				bSaveNeeded = True;
			}
		}
	}
	// map-specific part of PPH database
	RecentMap = new(None, string(Level.Outer)) class'EvenMatchPPH';
	if (RecentMap.PPH.Length == 0) {
		// always create map-specific entry
		bSaveNeeded = True;
	}
	else {
		// doesn't make sense to have map-specific data and no generic data for a particular player,
		// so discard all entries not matching a player in the generic PPH list
		for (i = RecentMap.PPH.Length - 1; i >= 0; --i) {
			j = Recent.FindPPHSlot(RecentMap.PPH[i].ID);
			if (j >= Recent.PPH.Length || RecentMap.PPH[i].ID != Recent.PPH[j].ID) {
				// not found
				RecentMap.PPH.Remove(i, 1);
				bSaveNeeded = True;
			}
		}
	}

	Game = ONSOnslaughtGame(Level.Game);
	if (Game != None) {
		AddToPackageMap();
		MinDesiredFirstRoundDuration = class'MutTeamBalance'.default.MinDesiredFirstRoundDuration * 60;
		Game.AddGameModifier(Self);
		if (class'MutTeamBalance'.default.bRandomlyStartWithSidesSwapped && Rand(2) == 0) SwapSides();
		if (EvenMatchMutator.bDebug) log("Added MutTeamBalance to Game", 'EvenMatchDebug');
		//if (EvenMatchMutator.bDebug) log("PreBeginPlay Game.NumBots " $ Game.NumBots $ ", Game.RemainingBots " $ Game.RemainingBots $ " bots", 'EvenMatchDebug');
	}
	else {
		Destroy();
	}

	SaveRecentPPH();
	
	if (EvenMatchMutator.bDebug) log("Finished PreBeginPlay", 'EvenMatchDebug');
}

simulated function PostNetBeginPlay()
{
	local PlayerController PC;
	
	if (Level.NetMode == NM_Client)
	{
		PC = Level.GetLocalPlayerController();
		if (PC == None)
			return;
		
		// we're here because the server doesn't know the player's stats identifier
		if (PC.StatsUsername != "" && PC.StatsPassword != "") {
			// player configured a stats name and password, use that,
			// as it will be the same when the server enables stats at some point
			PC.Mutate("EvenMatch SetPlayerId " $ MatchStartTS @ class'SHA1Hash'.static.GetStringHashString(Super(GameStats).GetStatsIdentifier(PC)));
		}
		else {
			// player hasn't configured stats, use a replacement ID,
			// which will be persisted until the player decides to configure stats
			Recent = new(None, "EvenMatchPPHDatabase") class'EvenMatchPPH';
			Recent.MyReplacementStatsID.Length = 1;
			if (Recent.MyReplacementStatsID[0] == "") {
				// no persisted replacement ID available, create a reasonably unique one
				Recent.MyReplacementStatsID[0] = "NoStats-"$class'SHA1Hash'.static.GetStringHashString(PC.GetPlayerIDHash() @ Level.Year @ Level.Month @ Level.Day @ Level.Hour @ Level.Minute @ Level.Second @ Level.Millisecond @ Rand(MaxInt));
				Recent.SaveConfig();
			}
			PC.Mutate("EvenMatch SetPlayerId " $ MatchStartTS @ Recent.MyReplacementStatsID[0]);
		}
	}
}

function AddGameRules(GameRules GR)
{
	if (GR != None && !GR.IsA('EvenMatchRules'))
		Super.AddGameRules(GR);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	class'MutTeamBalance'.static.FillPlayInfo(PlayInfo);
}


function SwapSides()
{
	local ONSPowerCore C;
	
	log("Using swapped sides...", 'EvenMatch');

	// This happens before ONSOnslaughtGame.PowerCores[] is set up!
	foreach AllActors(class'ONSPowerCore', C) {
		if (C.DefenderTeamIndex < 2) {
			C.DefenderTeamIndex = 1 - C.DefenderTeamIndex;
		}
	}
	// might cause problems on round restart if False
	Game.bSwapSidesAfterReset = True;
	Game.bSidesAreSwitched = True;
}


/**
Shuffle teams at match start, if configured.
*/
function MatchStarting()
{
	//if (class'MutTeamBalance'.default.bShuffleTeamsAtMatchStart) {
	// Change pooty 09/23 we don't want 'default' we want what ever is in the ini file!
	if (EvenMatchMutator.bDebug) log("MatchStarting Game.NumBots " $ Game.NumBots $ ", Game.RemainingBots " $ Game.RemainingBots $ " bots", 'EvenMatchDebug');
	if (EvenMatchMutator.bShuffleTeamsAtMatchStart) {
		log("Match Starting Shuffling teams based on previous known PPH...bIgnoreMapSpecificPPH="@EvenMatchMutator.bIgnoreMapSpecificPPH@"PPHCap="@EvenMatchMutator.MaxPPHScore, 'EvenMatch');
		
		CurrentGamePPH = ShuffleTeams();
		//BroadcastLocalizedMessage(class'UnevenMessage', -1,,,CurrentGamePPH);
        replicationHack = 1;
        SetTimer(1.5,false);
	}

    LastCheckScoreTime=Level.TimeSeconds;
    if (EvenMatchMutator.bVerbose) log("Finished MatchStarting", 'EvenMatchDebug');
}


/**
Check team balance right before a player respawns.
*/
function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string IncomingName)
{
	if (PlayerController(Player) != None && (LastRestarter != Player || LastRestartTime != Level.TimeSeconds) && EvenMatchMutator.IsBalancingActive()) {
		LastRestarter = PlayerController(Player);
		LastRestartTime = Level.TimeSeconds;

		if (EvenMatchMutator.bDebug) log(Level.TimeSeconds @ Player.GetHumanReadableName() $ " switched to " $ Player.PlayerReplicationInfo.Team.GetHumanReadableName(), 'EvenMatchDebug');
		EvenMatchMutator.CheckBalance(LastRestarter, False);
	}
	return Super.FindPlayerStart(Player, InTeam, IncomingName);
}


/**
Returns the current timestamp.
*/
function int GetTS()
{
	local int mon, year;

	mon = Level.Month - 2;
	year = Level.Year;
	if (mon <= 0) {    /* 1..12 -> 11,12,1..10 */
		mon += 12;    /* Puts Feb last since it has leap day */
		year -= 1;
	}
	return ((((year/4 - year/100 + year/400 + 367*mon/12 + Level.Day) + year*365 - 719499
				)*24 + Level.Hour /* now have hours */
			)*60 + Level.Minute  /* now have minutes */
		)*60 + Level.Second; /* finally seconds */
}


/**
Called at the end of the match if the first round was restarted due to heavy team imbalance.
*/
event Trigger(Actor Other, Pawn EventInstigator)
{
	if (Other == Level.Game && FirstRoundResult != 0)
		BroadcastLocalizedMessage(class'UnevenMessage', FirstRoundResult);
}

/*  Custom Scoring removed for refactoring. 03/2023 pooty  
function bool CustomScore(PlayerReplicationInfo Scorer)
{
    local ONSOnslaughtGame onsgame;
    local int oldscore, newscore;
    local bool bHasScored, bCoreDestroyed, bEnemyCoreDestroyed;

    if (bDebug) log("Starting Custom Score...",'EvenMatchOmni_CustomScore');
    if(Scorer != None && EvenMatchMutator.bCustomScoring && Role == ROLE_Authority)
    {
    	  if (bDebug) log("Evaluating Custom Score...",'EvenMatchOmni_CustomScore');
        onsgame = ONSOnslaughtGame(Level.Game);
     //   onsgame.Timer();
       
        // add some hysteresis, restrict calling this function faster than once per 2 seconds
        if(LastCheckScoreTime > level.TimeSeconds )
        {
            return;
        }
        LastCheckScoreTime=Level.TimeSeconds+2.0;
       


        if(Level.Game.bOverTime)
        {
            oldscore = 1;
            newscore = EvenMatchMutator.CustomOvertimePoints;
        }
        else
        {
            oldscore = 2;
            newscore = EvenMatchMutator.CustomRegulationPoints;
        }

        bHasScored = Level.GRI.Teams[Scorer.Team.TeamIndex].Score > 0;
        bEnemyCoreDestroyed = onsgame.PowerCores[onsgame.FinalCore[1-Scorer.Team.TeamIndex]].Health <= 0;
        bCoreDestroyed = onsgame.PowerCores[onsgame.FinalCore[Scorer.Team.TeamIndex]].Health <= 0;
        
        if (bDebug) log("In Custom Score...TeamIndex="$Scorer.Team.TeamIndex$","$"bHasScored="$bHasScored$" bEnemyCoreDestroyed="$bEnemyCoreDestroyed,'EvenMatchOmni_CustomScore');
        
        if(bHasScored && bEnemyCoreDestroyed && !bCoreDestroyed)
        {
            if (bDebug) log("Applying Custom Score...TeamIndex="$Scorer.Team.TeamIndex$","$"CurrentScore="$Level.GRI.Teams[Scorer.Team.TeamIndex].Score);

						
            Level.GRI.Teams[Scorer.Team.TeamIndex].Score -= oldscore;
            Level.GRI.Teams[Scorer.Team.TeamIndex].Score += newscore;
            if(Level.GRI.Teams[Scorer.Team.TeamIndex].Score < 0)
                Level.GRI.Teams[Scorer.Team.TeamIndex].Score = 0;

						if (bDebug) log("After Applying Custom Score...TeamIndex="$Scorer.Team.TeamIndex$","$"NewScore="$Level.GRI.Teams[Scorer.Team.TeamIndex].Score);

            Level.GRI.Teams[Scorer.Team.TeamIndex].NetUpdateTime = Level.TimeSeconds - 1;

            //update game objects
            onsgame.GameReplicationInfo.Teams[Scorer.Team.TeamIndex].Score = Level.GRI.Teams[Scorer.Team.TeamIndex].Score;
            onsgame.GameReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
            
            return True;
        }
      
    }
    return false;
}

************************************/ 

function bool CheckScore(PlayerReplicationInfo Scorer)
{
	local int i;
	
	// this is in case CheckScore gets called while doing mulligan reshuffle
    if (bBalancingMulligan) return False; 
  
  //if (EvenMatchMutator.bDebug) log("Starting CheckScores...bBalancingMulligan="$bBalancingMulligan$" bMulliganEnabled="$EvenMatchMutator.bMulliganEnabled, 'EvenMatchDebug');
  // From UT Source
  /* CheckScore() see if this score means the game ends
  return true to override gameinfo checkscore, or if game was ended (with a call to Level.Game.EndGame() )
  */
  /*  
  retval = False;
  if (EvenMatchMutator.bCustomScoring && Scorer != None) {
  	 retval = CustomScore(Scorer); //Adjust scoring, 
  	 // just continue other checkscore
  	 // but always return false from CheckScore, let base OnslaughtGame determine winner
  	 // if we return true it might not check other rules.
  }	 
  */
	//if (bBalancingMulligan || Super.CheckScore(Scorer)) {
		
		
		/* Removed for 3.61 Might have been crashing.   on Super.CheckScore(Scorer)
		Plus its redundant below if no mulligan (MinDesiredFirstRoundDuration, it updates PPH Scores (if bBalancingMulligan = False from line above)
		if (!bBalancingMulligan) {
			// just update recent PPH values
			for (i = 0; i < Level.GRI.PRIArray.Length; ++i) {
				if (Level.GRI.PRIArray[i] != None && !Level.GRI.PRIArray[i].bOnlySpectator)
					GetPointsPerHour(Level.GRI.PRIArray[i]);
			}
		}
		return true;
	}
	*/
	// Check for Mulligan ---------------------------------------
	if (EvenMatchMutator.bMulliganEnabled && Level.GRI.ElapsedTime < MinDesiredFirstRoundDuration && ((Level.GRI.Teams[0].Score + Level.GRI.Teams[1].Score) > 0)) {
		MinDesiredFirstRoundDuration = 0; // one restart is enough
		EvenMatchMutator.bMulliganEnabled = False;// one restart is enough
		bBalancingMulligan = True; 
		if (Level.GRI.Teams[0].Score > 0)
			FirstRoundResult = 1;
		else
			FirstRoundResult = 2;
		Tag = 'EndGame';

		log("Quick first round, shuffling teams...", 'EvenMatch');
		CurrentGamePPH = ShuffleTeams();
		//BroadcastLocalizedMessage(class'UnevenMessage', 0,,, Level.GRI.Teams[FirstRoundResult-1]);
		replicationHack = 2;
        SetTimer(1.5,false);

		// force round restart
		if (Level.Game.GameStats != None) {
			if (EvenMatchMutator.bDebug) log("Resetting team score stats...", 'EvenMatchDebug');
			if (Level.GRI.Teams[0].Score > 0)
				Level.Game.GameStats.TeamScoreEvent(0, -Level.GRI.Teams[0].Score, "reset");
			if (Level.GRI.Teams[1].Score > 0)
				Level.Game.GameStats.TeamScoreEvent(1, -Level.GRI.Teams[1].Score, "reset");
		}
		if (EvenMatchMutator.bDebug) log("Resetting team scores...", 'EvenMatchDebug');
		Level.GRI.Teams[0].Score = 0;
		Level.GRI.Teams[1].Score = 0;

		bBalancingMulligan = False;
		return True;
		// End Mulligan........
	}
	else {
		// just update recent PPH values
		//if (EvenMatchMutator.bDebug) log("Updating PPH Values in CheckScore, Level.GRI.PRIArray.Length="$Level.GRI.PRIArray.Length, 'EvenMatchDebug');
		for (i = 0; i < Level.GRI.PRIArray.Length; ++i) {
			if (Level.GRI.PRIArray[i] != None && !Level.GRI.PRIArray[i].bOnlySpectator)
				GetPointsPerHour(Level.GRI.PRIArray[i]);
		}
  	//if (EvenMatchMutator.bDebug) log("Updated PPH Values in CheckScore, Level.GRI.PRIArray.Length="$Level.GRI.PRIArray.Length, 'EvenMatchDebug');

	}

// Do we need this original EvenMatch didn't have it
//   if ( NextGameRules != None )
//        return NextGameRules.CheckScore(Scorer);

    //return retval;
    return false;

}

/** Check if a player is becoming spectator. There is no notify for specatators they just get killed and go to spec. */
function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if (DamageType == class'Suicided' && PlayerController(Killed.Controller) != None || DamageType == class'DamageType' && Killed.PlayerReplicationInfo != None && Killed.PlayerReplicationInfo.bOnlySpectator) {
		PotentiallyLeavingPlayer = PlayerController(Killed.Controller);
		SetTimer(0.01, false); // might be a player leaving, check right after all this whether it really is killed or someone going to spec.
	}
	return Super.PreventDeath(Killed, Killer, damageType, HitLocation);
}

// HACK: Mutator.NotifyLogout() doesn't seem to be called in all cases, so perform alternate check here
// Its not a hack.. NotifyLogout() is for disconnects, not going to spec who ever wrote this originally didn't know that pooty 03/2023
function Timer()
{
	
	if (PotentiallyLeavingPlayer != None) 
		if  (PotentiallyLeavingPlayer.PlayerReplicationInfo != None && PotentiallyLeavingPlayer.PlayerReplicationInfo.bOnlySpectator) 
		{
				if (PotentiallyLeavingPlayer != None) {
					if (EvenMatchMutator.bDebug) log("DEBUG: " $ PotentiallyLeavingPlayer.GetHumanReadableName() $ " became spectator", 'EvenMatchDebug_Timer');
					// check balance on someone going to spec.
					EvenMatchMutator.CheckBalance(PotentiallyLeavingPlayer, True);
				}
				// if they've actually left NotifyLogout() gets called.
		}	  

    if(replicationHack != 0)
    {
        if(replicationHack == 1)
        {	
            BroadcastLocalizedMessage(class'UnevenMessage', -1,,,CurrentGamePPH);
        }
        else if(replicationHack == 2)
        {
            BroadcastLocalizedMessage(class'UnevenMessage', 0,,, Level.GRI.Teams[FirstRoundResult-1]);
        }
        else if(replicationHack == 3)
        {
            BroadcastLocalizedMessage(class'UnevenMessage', 5);
        }

        replicationHack = 0;
    }
}


function ScoreKill(Controller Killer, Controller Killed)
{
	Super.ScoreKill(Killer, Killed);

	// update PPH for killer and killed
	if (Killer != None && Killer.PlayerReplicationInfo != None)
		GetPointsPerHour(Killer.PlayerReplicationInfo);
	if (Killed != None && Killed.PlayerReplicationInfo != None)
		GetPointsPerHour(Killed.PlayerReplicationInfo);
	// don't save right away, too much work to be done on every kill
}

simulated function GamePPH GetGamePPH()
{
    local int i;
    local byte Team;
    local PlayerReplicationInfo PRI;
    local float PPH;
    local float KPM;
    local float iPPH;

    CurrentGamePPH.RedPPH = 0;
    CurrentGamePPH.BluePPH = 0;

    //log("GamePPH:Start");
    for (i = 0; i < Level.GRI.PRIArray.Length; i++) 
    {
		if (Level.GRI.PRIArray[i].Team != None && Level.GRI.PRIArray[i].Team.TeamIndex < 2 && !Level.GRI.PRIArray[i].bOnlySpectator)
        {
            PRI = Level.GRI.PRIArray[i];
            Team = PRI.Team.TeamIndex;

            iPPH = FMin(GetPointsPerHour(PRI),EvenMatchMutator.MaxPPHScore); // binary search O(log m), subject to MaxPPHScore
            // Multipliers applied after
            KPM = GetKnownPlayerMultplier(PRI);
            PPH = iPPH * KPM;
            if(Team == 0)
                CurrentGamePPH.RedPPH += PPH;
            else if(Team == 1)
                CurrentGamePPH.BluePPH += PPH;
						if (EvenMatchMutator.bDebug)
            	  log("GamePPH: PlayerName: "$PRI.PlayerName$" Initial PPH: "$iPPH$" Multiplier "$KPM$" applied ="$PPH , 'EvenMatchOmni');
        }
    }
    log("GamePPH:End   Red:"$CurrentGamePPH.RedPPH$" Blue:"$CurrentGamePPH.BluePPH, 'EvenMatchOmni');

    CurrentGamePPH.NetUpdateTime = Level.TimeSeconds - 1;
    return CurrentGamePPH;
}

simulated function GamePPH ShuffleTeams(optional bool killPlayers)
{
	if (EvenMatchMutator.bUseKnownPlayerCategories) return ShuffleTeamsByCategory(killPlayers);
	else return ShuffleTeamsNoCategories(killPlayers);
}

simulated function LogCatPRI(array<CatAndPRI> CatPRI) 
{ // reall for testing.
	
	local int Index, CatN;
	local float PPH, iPPH, KPM, TotalPPH;
	local PlayerReplicationInfo PRI;
	
	if (!bVerbose) return;
	log ("Logging CatPRI having "$CatPRI.Length$" Players ------------------------------ ",'EvenMatchOmni');
 if (CatPRI.Length > 0) {
		Index = CatPRI.Length - 1;
		do {
			PRI = CatPRI[Index].PRI;
			if (!PRI.bOnlySpectator && PlayerController(PRI.Owner) != None && PlayerController(PRI.Owner).bIsPlayer) {
			//if (True) {
				// Next block to uncomment, we set test data
				
			  iPPH = FMin(GetPointsPerHour(PRI),EvenMatchMutator.MaxPPHScore); // binary search O(log m), subject to MaxPPHScore
				KPM = GetKnownPlayerMultplier(PRI);
				CatN = GetKnownPlayerCategory(PRI);
        PPH = iPPH * KPM;
				TotalPPH += PPH;
				// Test Block
				/*
				iPPH = CatPRI[index].PPH;
				KPM = 1.0;
				PPH = iPPH;
				CatN = CatPRI[index].CatNum;
				*/
				
				log("Player:"$CatPRI[Index].PRI.PlayerName$" : "$ iPPH $ " Initial PPH, Mutlipler "$KPM$" applied ="$PPH$", CatNum="$CatN$","$ GetCategoryDesc(CatN) $", currently on "$PRI.Team.GetHumanReadableName(), 'EvenMatchOmni');
				}
		} until (--Index < 0);
		log ("End Logging CatPRI ------------------------------------------ ",'EvenMatchOmni');
	}
}


simulated function array<int> GetUniquePlayerCatNums(array<CatAndPRI> CatPRI){
	 // this is from a SORTED list..ONLY.
	 local int OldCatNum;
	 local array<int> CatNums;
	 local int CatI, i;
	 
	 OldCatNum = -MaxInt;
	 CatI = 0;
	 for(i=0;i<CatPRI.length;i++)
   {
            if (CatPRI[i].CatNum != OldCatNum) {
            	 CatNums.Insert(CatI,1);
            	 CatNums[CatI] = CatPRI[i].CatNum;
            	 OldCatNum = CatPRI[i].CatNum;
            	 if (EvenMatchMutator.bDebug) log("UniqueCatNums, adding at index"$CatI$" CatNum="$OldCatNum,'EvenMatchDebug');
            	 CatI++;
            }
            // Add it 
   }
   return CatNums;
}



simulated function GamePPH ShuffleTeamsByCategory(optional bool killPlayers)
{
	 
	
	local array<CatAndPRI> CatPRI;
	//local array<CatAndPRI> CatPRITest;
	
	local PlayerReplicationInfo PRI, PRI2;
	
	local array<PlayerReplicationInfo>  RedPRIs, BluePRIs;
	local array<int> CatNums;
	local int Index, i;
	local float PPH, PPH2, RedPPH, BluePPH, TotalPPH, iPPH, KPM, CatN;
  local Pawn P;

  local string PlayerName;
  //local int OldNumBots, OldMinPlayers;  // for removing / readding bots.
  // bot code is fubar'd works fine without it.
  
 
 
	log("Shuffling Teams by Categories", 'EvenMatchOmni');
	// RemoveBots(); //I think theres a variable scope thing at play this doesn't work right.
	// Not needed, doesn't work anyway, whether inline or in the function.  Function actually does set NumBots but its always 0
	/*if (EvenMatchMutator.bDebug) log("Start Re-Adding " $ OldNumBots $ " bots.. ", 'EvenMatchDebug');
	if (EvenMatchMutator.bVerbose && OldNumBots > 0) log("Will re-add " $ OldNumBots $ " bots later", 'EvenMatchDebug');
  if (OldNumBots >0) {	
  	Game.RemainingBots = OldNumBots;
  	Game.MinPlayers    = OldMinPlayers;
	}
	*/
	
	// Generate Test Data
	// CatPRI here is test data in place of real PRI
	// We avoid using the PRI member during test because it spams log with None warnings.
	/*
	CatPRITest.Insert(0,13);
	CatPRITest[0].CatNum = 10;
	CatPRITest[0].PPH = 725;
	CatPRITest[0].PRI = None;
	CatPRITest[0].PN = "Snarf";
	CatPRITest[1].CatNum = 5;
	CatPRITest[1].PPH = 525;
	CatPRITest[1].PRI = None;
	CatPRITest[1].PN = "Ebno";
	CatPRITest[2].CatNum = 5;
	CatPRITest[2].PPH = 600;
	CatPRITest[2].PRI = None;
	CatPRITest[2].PN = "GTKU";
	CatPRITest[3].CatNum = 0;
	CatPRITest[3].PPH = 400;
	CatPRITest[3].PRI = None;
	CatPRITest[3].PN = "Azael";
	CatPRITest[4].CatNum = -10;
	CatPRITest[4].PPH = 200;
	CatPRITest[4].PRI = None;
	CatPRITest[4].PN = "Phariz";
	CatPRITest[5].CatNum = 5;
	CatPRITest[5].PPH = 700;
	CatPRITest[5].PRI = None;
	CatPRITest[5].PN = "Enyo";
	CatPRITest[6].CatNum = 0;
	CatPRITest[6].PPH = 500;
	CatPRITest[6].PRI = None;
	CatPRITest[6].PN = "Busch";
	CatPRITest[7].CatNum = -10;
	CatPRITest[7].PPH = 275;
	CatPRITest[7].PRI = None;
	CatPRITest[7].PN = "ColdCut";
	CatPRITest[8].CatNum = 0;
	CatPRITest[8].PPH = 400;
	CatPRITest[8].PRI = None;
	CatPRITest[8].PN = "Jacob";
  CatPRITest[9].CatNum = 10;
	CatPRITest[9].PPH = 875;
	CatPRITest[9].PRI = None;
	CatPRITest[9].PN = "Anon";
	CatPRITest[10].CatNum = 0;
	CatPRITest[10].PPH = 475;
	CatPRITest[10].PRI = None;
	CatPRITest[10].PN = "Dognuts";
	CatPRITest[11].CatNum = 10;
	CatPRITest[11].PPH = 675;
	CatPRITest[11].PRI = None;
	CatPRITest[11].PN = "Sanka";
	CatPRITest[12].CatNum = 0;
	CatPRITest[12].PPH = 35;
	CatPRITest[12].PRI = None;
	CatPRITest[12].PN = "Ankeedo";
	*/
	// Use CatPRI instead of actual players here when testing
	// find PRIs of active players and sort ascending by CatNum
	//if (CatPRITest.Length > 0) {
	//	Index = CatPRITest.Length - 1;
	
		if (Level.GRI.PRIArray.Length > 0) {
	     Index = Level.GRI.PRIArray.Length - 1;
		   do {
					PRI = Level.GRI.PRIArray[Index];
			    if (!PRI.bOnlySpectator && PlayerController(PRI.Owner) != None && PlayerController(PRI.Owner).bIsPlayer) {
			  //if (True) { // Testing 
        //iPPH = CatPRITest[index].PPH; //FMin(GetPointsPerHour(PRI),EvenMatchMutator.MaxPPHScore); // binary search O(log m), subject to MaxPPHScore
					//KPM = 1.0; //GetKnownPlayerMultplier(PRI);								
					iPPH = FMin(GetPointsPerHour(PRI),EvenMatchMutator.MaxPPHScore); // binary search O(log m), subject to MaxPPHScore
					KPM = GetKnownPlayerMultplier(PRI);
					PPH = iPPH * KPM;
					TotalPPH += PPH;
					//CatN = CatPRITest[index].CatNum;// Test Remove GetKnownPlayerCategory(PRI);
					//PlayerName = CatPRITest[index].PN; // Test RemoveCatPRI.PRI.PlayerName
					CatN = GetKnownPlayerCategory(PRI);
					PlayerName = PRI.PlayerName;
					
					if (EvenMatchMutator.bVerbose) log("Player:"$PlayerName$" : "$ iPPH $ " Initial PPH, Mutlipler "$KPM$" applied ="$PPH$", CatNum="$CatN$","$ GetCategoryDesc(CatN) $", currently on "$PRI.Team.GetHumanReadableName(), 'EvenMatchOmni');
					
					// Got players.
				 // Update this to use CatPRI, an Array of structs instead of one array.
					// Sort first by CatNum ASC, then PPH DESC within each CatNum
					i = 0;
					for(i=0;i<CatPRI.length;i++)
				  {
						if (CatPRI[i].CatNum > CatN ) break;
					} 
					// Found Category.
					// Decide to advance based on PPH.  Current spot
					while (i>0 && CatPRI[i-1].CatNum == CatN && CatPRI[i-1].PPH > PPH ) {
						     //Log("Advancing because CatPRI[i-1].PPH "$CatPRI[i-1].PPH$" PPH "$PPH);
								 i--;
					}
					// Insert can be considered O(1) here due to huge contant overhead and small actual n
					//Log("Logging CatPRI Before Insert at I="$i);
					//If (CatPRI.Length > 0) LogCatPRI(CatPRI);
					//Log("--------------------------------------------");
					CatPRI.Insert(i, 1);
					CatPRI[i].PRI = PRI;  // avoid none warnings during testing
					CatPRI[i].PPH = PPH;
			    CatPRI[i].CatNum = CatN;
			    //CatPRI[i].PN = PlayerName; // delete after testing.
			}
		
		} until (--Index < 0); // Do

	} // entire if
	
	// should be sorted by CatNum Asc.
	if (EvenMatchMutator.bVerbose)  {
		log("Final Sorted Player List:",'EvenMatchOmni');
		LogCatPRI(CatPRI);	
	}
	
	// Get arrary (sorted) of unique CatNums, from actual players SORTED by CatNUM CatPRI)
  CatNums = GetUniquePlayerCatNums(CatPRI);
  // Not sure above is really needed.
			
	if (EvenMatchMutator.bVerbose) 		log(CatPRI.Length $ " players, combined PPH " $ TotalPPH $ ", balance target PPH per team " $ 0.5 * TotalPPH, 'EvenMatchOmni');
	
	// let the game re-add missing bots
	//ReAddBots();
	
  //  Sort Order works... 
	// first balance team sizes
	if (EvenMatchMutator.bVerbose) log("Balancing team sizes and PPH...", 'EvenMatchOmni');
	
	if (CatPRI.Length > 0) {
		Index = CatPRI.Length;

		while (Index > 1) {
			
			/* Testing code
			//PRI = CatRPI[--Index].PRI;
			PPH = CatPRI[--Index].PPH;
			//PRI2 = CatPRI[Index].PRI;
			PPH2 = CatPRI[--Index].PPH;
			*/
			
			// Grab the top two players
			PRI = CatPRI[--Index].PRI;
			PPH = CatPRI[Index].PPH;
			PRI2 = CatPRI[--Index].PRI;
			PPH2 = CatPRI[Index].PPH;
			
			if (EvenMatchMutator.bDebug)
			//log("Assigning " $ PRI.PlayerName $ " (" $ PPH $ " PPH) and " $ PRI2.PlayerName $ " (" $ PPH2 $ " PPH)", 'EvenMatchDebug');
			log("Assigning " $ CatPRI[index+1].PN $ " (" $ PPH $ " PPH) and " $ CatPRI[index].PN $ " (" $ PPH2 $ " PPH)", 'EvenMatchOmni');
			 
			if (RedPPH > BluePPH) {
				RedPRIs[RedPRIs.Length] = PRI2;
				RedPPH += PPH2;
				BluePRIs[BluePRIs.Length] = PRI;
				BluePPH += PPH;
				
				if (EvenMatchMutator.bDebug)
				 	//log(PRI.PlayerName $ " will be on blue (now " $ BluePPH $ " PPH), " $ PRI2.PlayerName $ " will be on red (now " $ RedPPH $ " PPH)", 'EvenMatchDebug');
				 	log(CatPRI[index+1].PRI.PlayerName $ " will be on blue (now " $ BluePPH $ " PPH), " $ CatPRI[index].PRI.PlayerName $ " will be on red (now " $ RedPPH $ " PPH)", 'EvenMatchOmni');
			}
			else {
				RedPRIs[RedPRIs.Length] = PRI;
				RedPPH += PPH;
				BluePRIs[BluePRIs.Length] = PRI2;
				BluePPH += PPH2;
				
				if (EvenMatchMutator.bDebug)
					//log(PRI.PlayerName $ " will be on red (now " $ RedPPH $ " PPH), " $ PRI2.PlayerName $ " will be on blue (now " $ BluePPH $ " PPH)", 'EvenMatchDebug');
					log(CatPRI[index+1].PRI.PlayerName $ " will be on red (now " $ BluePPH $ " PPH), " $ CatPRI[index].PRI.PlayerName $ " will be on blue (now " $ RedPPH $ " PPH)", 'EvenMatchDebug');
			}
		}

        // snarf do this at the end
		if ((Index & 1) != 0) {
			PRI = CatPRI[0].PRI;
			PPH = CatPRI[0].PPH;
			
			if (BluePPH > RedPPH)
            {
				//log("Odd player count, Blue has higher PPH, assigning " $ PRI.PlayerName $ " to red (" $ PPH $ " PPH)", 'EvenMatchDebug');
				log("Odd player count, Blue has higher PPH, assigning " $ CatPRI[0].PRI.PlayerName $ " to red (" $ PPH $ " PPH)", 'EvenMatchOmni');
  			RedPRIs[RedPRIs.Length] = PRI;
				RedPPH += PPH;
			}
			else {
				//log("Odd player count, Red has higher PPH, assigning " $ PRI.PlayerName $ " to blue (" $ PPH $ " PPH)", 'EvenMatchDebug');
				log("Odd player count, Blue has higher PPH, assigning " $ CatPRI[0].PRI.PlayerName $ " to blue (" $ PPH $ " PPH)", 'EvenMatchOmni');
				BluePRIs[BluePRIs.Length] = PRI;
				BluePPH += PPH;
			}
		}
	} // entire if: 
	
	//if (EvenMatchMutator.bVerbose) {
		log("Red team size " $ RedPRIs.Length $ ", combined PPH " $ RedPPH, 'EvenMatchOmni');
		log("Blue team size " $ BluePRIs.Length $ ", combined PPH " $ BluePPH, 'EvenMatchOmni');
	//}
	
	
	// actually apply team changes
	// This shouldn't need any further changes for Categories...
	if (EvenMatchMutator.bVerbose) log("Applying team changes...", 'EvenMatchDebug');

	for (Index = 0; Index < RedPRIs.Length; ++Index) {
		if (RedPRIs[Index].Team.TeamIndex != 0) {
		 log("Moving " $ RedPRIs[Index].PlayerName $ " to red", 'EvenMatchDebug');
            if(killPlayers)
            {
                P = PlayerController(RedPRIs[Index].Owner).Pawn;
                if(P != None)
                {
                    P.Health = 0;
                    P.Died( PlayerController(RedPRIs[Index].Owner), class'DamTypeTeamChange', P.Location );
                }
            }
			ChangeTeam(PlayerController(RedPRIs[Index].Owner), 0);
		}
	}
	for (Index = 0; Index < BluePRIs.Length; ++Index) {
		if (BluePRIs[Index].Team.TeamIndex != 1) {
			 log("Moving " $ BluePRIs[Index].PlayerName $ " to blue", 'EvenMatchDebug');
            if(killPlayers)
            {
                P = PlayerController(BluePRIs[Index].Owner).Pawn;
                if(P != None)
                {
                    P.Health = 0;
                    P.Died( PlayerController(BluePRIs[Index].Owner), class'DamTypeTeamChange', P.Location );
                }
            }
			ChangeTeam(PlayerController(BluePRIs[Index].Owner), 1);
		}
	}
	log("Teams shuffled.", 'EvenMatchDebug');

    CurrentGamePPH.RedPPH = RedPPH;
    CurrentGamePPH.BluePPH = BluePPH;
    CurrentGamePPH.NetUpdateTime = Level.TimeSeconds - 1;
    return CurrentGamePPH;
}


//****************************************************************************************
// below is the original no categories EvenMatchShuffle.
simulated function GamePPH ShuffleTeamsNoCategories(optional bool killPlayers)
{
	local PlayerReplicationInfo PRI, PRI2;
	local array<PlayerReplicationInfo> PRIs, RedPRIs, BluePRIs;
	local array<float> PPHs;
	local int Index; //, OldNumBots, OldMinPlayers;
	local int Low, High, Middle;
	local float PPH, PPH2, RedPPH, BluePPH, TotalPPH, iPPH, KPM;
  local Pawn P;

	//retval = new class'GamePPH';
	// complexity below documented in terms of n players and m stored PPH values
	
	//RemoveBots();  // not needed see above
	
	// find PRIs of active players and sort ascending by PPH
	if (Level.GRI.PRIArray.Length > 0) {
		Index = Level.GRI.PRIArray.Length - 1;
		do {
			PRI = Level.GRI.PRIArray[Index];
			if (!PRI.bOnlySpectator && PlayerController(PRI.Owner) != None && PlayerController(PRI.Owner).bIsPlayer) {
			
			  iPPH = FMin(GetPointsPerHour(PRI),EvenMatchMutator.MaxPPHScore); // binary search O(log m), subject to MaxPPHScore
				KPM = GetKnownPlayerMultplier(PRI);
        PPH = iPPH * KPM;
				TotalPPH += PPH;
				if (EvenMatchMutator.bVerbose)
					log(PRI.PlayerName @ iPPH $ " Initial PPH, Mutlipler "$KPM$" applied ="$PPH$", currently on " $ PRI.Team.GetHumanReadableName(), 'EvenMatchDebug');
				
				// binary search O(log n)
				Low = 0;
				High = PRIs.Length;
				if (Low < High) do {
					Middle = (High + Low) / 2;
					if (PPHs[Middle] < PPH) // ascending by PPH
						Low = Middle + 1;
					else
						High = Middle;
				} until (Low >= High);
				
				// Insert can be considered O(1) here due to huge contant overhead and small actual n
				PRIs.Insert(Low, 1);
				PRIs[Low] = PRI;
				PPHs.Insert(Low, 1);
				PPHs[Low] = PPH;
			}
		} until (--Index < 0);
	} // entire if: O(n * (log n + log m))
	
	if (EvenMatchMutator.bVerbose)
		log(PRIs.Length $ " players, combined PPH " $ TotalPPH $ ", balance target PPH per team " $ 0.5 * TotalPPH, 'EvenMatchOmni');
	
	// let the game re-add missing bots
//	ReAddBots();  // not needed.
	
	// first balance team sizes
	if (EvenMatchMutator.bVerbose) log("Balancing team sizes and PPH...", 'EvenMatchOmni');
	if (PPHs.Length > 0) {
		Index = PPHs.Length;

		while (Index > 1) {
			PRI = PRIs[--Index];
			PPH = PPHs[Index];
			PRI2 = PRIs[--Index];
			PPH2 = PPHs[Index];
			// ascending sort, so PPH >= PPH2
			
			if (EvenMatchMutator.bDebug)
				log("Assigning " $ PRI.PlayerName $ " (" $ PPH $ " PPH) and " $ PRI2.PlayerName $ " (" $ PPH2 $ " PPH)", 'EvenMatchOmni');
			 
			if (RedPPH > BluePPH) {
				RedPRIs[RedPRIs.Length] = PRI2;
				RedPPH += PPH2;
				BluePRIs[BluePRIs.Length] = PRI;
				BluePPH += PPH;
				log(PRI.PlayerName $ " will be on blue (now " $ BluePPH $ " PPH), " $ PRI2.PlayerName $ " will be on red (now " $ RedPPH $ " PPH)", 'EvenMatchOmni');
			}
			else {
				RedPRIs[RedPRIs.Length] = PRI;
				RedPPH += PPH;
				BluePRIs[BluePRIs.Length] = PRI2;
				BluePPH += PPH2;
				log(PRI.PlayerName $ " will be on red (now " $ RedPPH $ " PPH), " $ PRI2.PlayerName $ " will be on blue (now " $ BluePPH $ " PPH)", 'EvenMatchOmni');
			}
		}

        // snarf do this at the end
		if ((Index & 1) != 0) {
			PRI = PRIs[0];
			PPH = PPHs[0];
			if (BluePPH > RedPPH)  {
					log("Odd player count, Blue has higher PPH, assigning " $ PRI.PlayerName $ " to red (" $ PPH $ " PPH)", 'EvenMatchOmni');
					RedPRIs[RedPRIs.Length] = PRI;
					RedPPH += PPH;
			}
			else {
					log("Odd player count, Red has higher PPH, assigning " $ PRI.PlayerName $ " to blue (" $ PPH $ " PPH)", 'EvenMatchDebug');
  				BluePRIs[BluePRIs.Length] = PRI;
					BluePPH += PPH;
			}
		}
	} // entire if: O(n)  Who cares about O(n) here... N will never be more than O(32) so all this optimization was pointless. -pooty
	
	log("Red team size " $ RedPRIs.Length $ ", combined PPH " $ RedPPH, 'EvenMatchDebug');
 	log("Blue team size " $ BluePRIs.Length $ ", combined PPH " $ BluePPH, 'EvenMatchDebug');
	
	// apply team changes
	if (EvenMatchMutator.bVerbose) log("Applying team changes...", 'EvenMatchOmni');

	for (Index = 0; Index < RedPRIs.Length; ++Index) {
		if (RedPRIs[Index].Team.TeamIndex != 0) {
		 log("Moving " $ RedPRIs[Index].PlayerName $ " to red", 'EvenMatchOmni');
            if(killPlayers)
            {
                P = PlayerController(RedPRIs[Index].Owner).Pawn;
                if(P != None)
                {
                    P.Health = 0;
                    P.Died( PlayerController(RedPRIs[Index].Owner), class'DamTypeTeamChange', P.Location );
                }
            }
			ChangeTeam(PlayerController(RedPRIs[Index].Owner), 0);
		}
	}
	for (Index = 0; Index < BluePRIs.Length; ++Index) {
		if (BluePRIs[Index].Team.TeamIndex != 1) {
			 log("Moving " $ BluePRIs[Index].PlayerName $ " to blue", 'EvenMatchOmni');
            if(killPlayers)
            {
                P = PlayerController(BluePRIs[Index].Owner).Pawn;
                if(P != None)
                {
                    P.Health = 0;
                    P.Died( PlayerController(BluePRIs[Index].Owner), class'DamTypeTeamChange', P.Location );
                }
            }
			ChangeTeam(PlayerController(BluePRIs[Index].Owner), 1);
		}
	}
	log("Teams shuffled.", 'EvenMatchOmni');

    CurrentGamePPH.RedPPH = RedPPH;
    CurrentGamePPH.BluePPH = BluePPH;
    CurrentGamePPH.NetUpdateTime = Level.TimeSeconds - 1;
    return CurrentGamePPH;
}



/*  These work on setting Game.MinPlayers and Game.RemainingBots, but the are all ZERO when this mutator runs
// theory is the num bots don't get set until AFTER The shuffle code is called.
function RemoveBots() {
	 if (EvenMatchMutator.bDebug) log("Start RemoveBots Game.NumBots " $ Game.NumBots $ ", Game.RemainingBots " $ Game.RemainingBots $ " bots for shuffling", 'EvenMatchDebug');
   OldNumBots = Game.NumBots + Game.RemainingBots;
	 OldMinPlayers = Game.MinPlayers;
	 Game.RemainingBots = 0;
	 Game.MinPlayers    = 0;
	 if (Game.NumBots > 0) {
	     Game.KillBots(Game.NumBots);
	     if (EvenMatchMutator.bVerbose) log("Removing " $ Game.NumBots $ " bots for shuffling, will re-add "$OldNumBots$" bots later.", 'EvenMatchDebug');
	 }
	return;
}

function ReAddBots() {
	if (EvenMatchMutator.bDebug) log("Start Re-Adding " $ OldNumBots $ " bots.. ", 'EvenMatchDebug');
	if (EvenMatchMutator.bVerbose && OldNumBots > 0) log("Will re-add " $ OldNumBots $ " bots later", 'EvenMatchDebug');
  if (OldNumBots >0) {	
  	Game.RemainingBots = OldNumBots;
  	Game.MinPlayers    = OldMinPlayers;
  }
}
*/

function ReceivedReplacementStatsId(PlayerController PC, string ReplacementID)
{
	if (!Level.Game.bEnableStatLogging || !Level.Game.bLoggingGame) {
		if (PC.PlayerReplicationInfo != None && (CachedPlayerIDs.Length <= PC.PlayerReplicationInfo.PlayerID || CachedPlayerIDs[PC.PlayerReplicationInfo.PlayerID] == "")) {
			CachedPlayerIDs[PC.PlayerReplicationInfo.PlayerID] = ReplacementID;
		}
	}
}

function string GetStatsID(PlayerController PC)
{
    local string PlayerID;
    PlayerID = Super(GameStats).GetStatsIdentifier(PC);
    return Mid(PlayerID,0,32);
}

function float GetKnownPlayerMultplier(PlayerReplicationInfo PRI)
{
    local int i;
    local PlayerController PC;
    local string PlayerID;

    PC = PlayerController(PRI.Owner);

    if(PC != None)
    {
        PlayerID = PC.GetPlayerIDHash();
        for(i=0;i<KnownPlayers.PPH.length;i++)
        {
            if(KnownPlayers.PPH[i].ID ~= PlayerID)
                return KnownPlayers.PPH[i].Multiplier;
        }
    }

    return 1.0;
}

function int GetKnownPlayerCategory(PlayerReplicationInfo PRI)
{
    local int i;
    local PlayerController PC;
    local string PlayerID;

    PC = PlayerController(PRI.Owner);

    if(PC != None)
    {
        PlayerID = PC.GetPlayerIDHash();
        for(i=0;i<KnownPlayers.PPH.length;i++)
        {
            if(KnownPlayers.PPH[i].ID ~= PlayerID)
                return KnownPlayers.PPH[i].CatNum;
        }
    }

    return 0;  // 0 is default category
}

function string GetCategoryDesc(int CNum)
{
    local int i;
    for(i=0;i < KPCategories.KPC.length;i++)
        {
          if(KPCategories.KPC[i].CatNum == CNum) return KPCategories.KPC[i].CatDesc;
        }
    
    return "Default";  // 0 is default category
}


function float GetPointsPerHour(PlayerReplicationInfo PRI)
{
	local PlayerController PC;
	local string ID;
	local int Index, IndexMap;
	local float PPH, CurrentPPH, PastPPH, PastPPHMap;
    local float retval;

	PC = PlayerController(PRI.Owner);
	if (PC != None) {
		// ID is SHA1 hash of stats identifier
		if (PC.PlayerReplicationInfo == None || CachedPlayerIDs.Length <= PC.PlayerReplicationInfo.PlayerID || CachedPlayerIDs[PC.PlayerReplicationInfo.PlayerID] == "") {
			ID = class'SHA1Hash'.static.GetStringHashString(Super(GameStats).GetStatsIdentifier(PC));
			if (PC.PlayerReplicationInfo != None)
				CachedPlayerIDs[PC.PlayerReplicationInfo.PlayerID] = ID;
		}
		else {
			ID = CachedPlayerIDs[PC.PlayerReplicationInfo.PlayerID];
		}
		//if (EvenMatchMutator.bDebug) log("Name="@PC.PlayerReplicationInfo.PlayerName@"ID="@ID,'EvenMatchDebug');
	}
	// calculate current PPH
	CurrentPPH = 3600 * FMax(PRI.Score, 0.1) / Max(Level.GRI.ElapsedTime - PRI.StartTime, 10);
	// apply PPH cap pooty 09/2023
	CurrentPPH = FMin(CurrentPPH,EvenMatchMutator.MaxPPHScore);
	
	PastPPH = -1;
	PastPPHMap = -1;
	
	Index = Recent.FindPPHSlot(ID);
	IndexMap = RecentMap.FindPPHSlot(ID);
	
	//log("Index="@Index,'EvenMatchDebug');
	if (Level.GRI.bMatchHasBegun && PRI.Score > EvenMatchMutator.PlayerMinScoreBeforeStoringPPH && Level.GRI.ElapsedTime - PRI.StartTime > EvenMatchMutator.PlayerGameSecondsBeforeStoringPPH) 
	{
		PPH = CurrentPPH;
		
		// already scored, override score from earlier
		if (Index >= Recent.PPH.Length || Recent.PPH[Index].ID != ID) {
			Recent.PPH.Insert(Index, 1);
			Recent.PPH[Index].ID = ID;
			Recent.PPH[Index].PastPPH = -1;
			Recent.PPH[Index].CurrentPPH = PPH;
			Recent.PPH[Index].TS = MatchStartTS;
			bSaveNeeded = True;
		}
		else {
			if (Recent.PPH[Index].TS != MatchStartTS) {
				if (Recent.PPH[Index].PastPPH == -1)
					Recent.PPH[Index].PastPPH = Recent.PPH[Index].CurrentPPH;
				else // adjust generic PPH slower than map-specific
					Recent.PPH[Index].PastPPH = 0.32 * (2.125 * Recent.PPH[Index].PastPPH + Recent.PPH[Index].CurrentPPH);
				Recent.PPH[Index].TS = MatchStartTS;
				bSaveNeeded = True;
			}
			Recent.PPH[Index].CurrentPPH = PPH;
			if (Recent.PPH[Index].PastPPH != -1)
				PastPPH = FMin(Recent.PPH[Index].PastPPH,EvenMatchMutator.MaxPPHScore);
				//pooty 09-2023 make sure past PPHs get capped at MaxPPHScore
		}
		
		// also update map-specific PPH
		if (IndexMap >= RecentMap.PPH.Length || RecentMap.PPH[IndexMap].ID != ID) {
			RecentMap.PPH.Insert(IndexMap, 1);
			RecentMap.PPH[IndexMap].ID = ID;
			RecentMap.PPH[IndexMap].PastPPH = -1;
			RecentMap.PPH[IndexMap].CurrentPPH = PPH;
			RecentMap.PPH[IndexMap].TS = MatchStartTS;
			bSaveNeeded = True;
		}
		else {
			if (RecentMap.PPH[IndexMap].TS != MatchStartTS) {
				if (RecentMap.PPH[IndexMap].PastPPH == -1)
					RecentMap.PPH[IndexMap].PastPPH = FMin(RecentMap.PPH[IndexMap].CurrentPPH,EvenMatchMutator.MaxPPHScore) ;
				else
					//RecentMap.PPH[IndexMap].PastPPH = 0.5 * (RecentMap.PPH[IndexMap].PastPPH + RecentMap.PPH[IndexMap].CurrentPPH);
					// updated by pOOty to use same formula above, slower change on MapPPH just like regular PPH
					RecentMap.PPH[IndexMap].PastPPH = 0.32 * (2.125 * RecentMap.PPH[IndexMap].PastPPH + RecentMap.PPH[IndexMap].CurrentPPH);
				RecentMap.PPH[IndexMap].TS = MatchStartTS;
				bSaveNeeded = True;
			}
			RecentMap.PPH[IndexMap].CurrentPPH = PPH;
			if (RecentMap.PPH[IndexMap].PastPPH != -1) 
				PastPPHMap = FMin(RecentMap.PPH[IndexMap].PastPPH,EvenMatchMutator.MaxPPHScore);
		}
	}
	else {
		//log("Match hasn't started yet", 'EvenMatchDebug');
		PPH = -1;
		//log("Index="@Index@"Recent.PPH.Length="@Recent.PPH.Length@" ");
		if (Index < Recent.PPH.Length && Recent.PPH[Index].ID == ID) {
			// No score yet, use PPH from earlier
			PastPPH = FMin(Recent.PPH[Index].PastPPH,EvenMatchMutator.MaxPPHScore);
			//log("Getting pastpph");
		}
		if (IndexMap < RecentMap.PPH.Length && RecentMap.PPH[IndexMap].ID == ID) {
			// No score yet, use PPH from earlier
			PastPPHMap = FMin(RecentMap.PPH[IndexMap].PastPPH,EvenMatchMutator.MaxPPHScore);
		}
	}

   // snarf allow ignoring map specific PPH
   if(EvenMatchMutator.bIgnoreMapSpecificPPH)
   {
        PastPPHMap = -1;
   }
	
	//log("Before Switch, Switch="@(int(PPH == -1) + 2 * int(PastPPH == -1) + 4 * int(PastPPHMap == -1)), 'EvenMatchDebug');
	//log("CurrentPPH="@CurrentPPH, 'EvenMatchDebug');
	//log("PPH="@PPH@" (PPH == -1)="@(PPH == -1)@"int(PPH == -1)="@int(PPH == -1), 'EvenMatchDebug');
	//log("PastPPH="@PastPPH@" (PastPPH == -1)="@(PastPPH == -1)@"int(PastPPH == -1)="@int(PastPPH == -1), 'EvenMatchDebug');
	//log("PastPPHMap="@PastPPHMap@" (PastPPHMap == -1)="@(PastPPHMap == -1)@"int(PastPPHMap == -1)="@int(PastPPHMap == -1), 'EvenMatchDebug');
	// combine current and past PPH values in a meaningful way
	switch (int(PPH == -1) + 2 * int(PastPPH == -1) + 4 * int(PastPPHMap == -1)) {
		case 0: // all three PPH values available
			retval = 0.4 * (PPH + PastPPHMap + 0.5 * PastPPH);
            break;
			
		case 1: // no current (meaningful) score yet, but both past PPH available
			retval = 0.8 * (PastPPHMap + 0.25 * PastPPH);
            break;
			
		case 2: // no past generic PPH (should not be possible)
			retval = 0.5 * (PPH + PastPPHMap);
            break;
			
		case 3: // only past map-specific PPH (should not be possible either)
			retval = PastPPHMap;
            break;
			
		case 4: // no past map-specific PPH
			retval = 0.5 * (PPH + PastPPH);
            break;
			
		case 5: // only past generic PPH
			retval = PastPPH;
			//log("In Case5");
            break;
			
		case 6: // only current PPH (new player)
			retval = PPH;
            break;
			
		default: // none of the above (should not be possible)
			retval = CurrentPPH;
	}
  
  //added pooty to cap PPH scores.
  retval = FMin(retval,EvenMatchMutator.MaxPPHScore);
  
  return retval;
}


function ChangeTeam(PlayerController Player, int NewTeam)
{
    local int i;
    local ONSOnslaughtGame onsgame;
	Player.PlayerReplicationInfo.Team.RemoveFromTeam(Player);
	if (Level.GRI.Teams[NewTeam].AddToTeam(Player)) {
        if(Player.Pawn != none)
            Player.Pawn.NotifyTeamChanged();
        onsgame = ONSOnslaughtGame(Level.Game);
		Player.ReceiveLocalizedMessage(class'TeamSwitchNotification', NewTeam);
		onsgame.GameEvent("TeamChange", string(NewTeam), Player.PlayerReplicationInfo);

        if (Player == Level.GetLocalPlayerController())
		{
			//Update client side effects on powercores to reflect which ones the player can go after changing teams
			for (i = 0; i < onsgame.PowerCores.length; i++)
				onsgame.PowerCores[i].CheckShield();
		}
	}
	
	EvenMatchMutator.PendingVoiceChatRoomChecks[EvenMatchMutator.PendingVoiceChatRoomChecks.Length] = Player;
}


// modified balancer team progress function
// instead of looking at game score look at team strength
function float GetTeamProgress()
{
    local PlayerReplicationInfo PRI;
    local int i;
    local float RedPPH, BluePPH;
    local float PPH;
    local float PPHDiff;

    for(i = 0;i < Level.GRI.PRIArray.Length; i++ )
    {
        PRI = Level.GRI.PRIArray[i];
        PPH = GetPointsPerHour(PRI);
        PPH *= GetKnownPlayerMultplier(PRI);
        if(PRI.TeamID == 0)
        {
            RedPPH += PPH;
        }
        else if(PRI.TeamID == 1)
        {
            BluePPH += PPH;
        }
    }

    PPHDiff = Abs(RedPPH - BluePPH);
    if(PPHDiff < ConfigPPHDiff)
        return 0.5;

    if(RedPPH > BluePPH)
        return 0.0;
    else if(RedPPH < BluePPH)
        return 1.0;
    
    return 0.5;
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	bNetTemporary = True
  ConfigPPHDiff=200
  bBalancingMulligan = False
}
