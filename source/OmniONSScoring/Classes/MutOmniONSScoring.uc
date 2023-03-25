/* This mutator uses a replacement function for MainCoreDestroyed in the base Onslaught game which harded coded scoring values */

class MutOmniONSScoring extends Mutator config;


var() const editconst string Build;


var config bool bCustomScoring;
var config int CustomRegulationPoints;
var config int CustomOvertimePoints;
var config bool bDebug;



var ONSOnslaughtGame ONSGame;


function PostBeginPlay()
{
	log(Class$" build "$Build, 'OmniONSScoring');
  ONSGame = ONSOnslaughtGame(Level.Game);
}	
	
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	 local ONSPowerCore PC;
	  
	  PC = ONSPowerCore(Other);
	  if (PC!=None && bCustomScoring)
        {
        	  PC.OnCoreDestroyed = MainCoreDestroyedOmniScoring;
        	  // Replace Stock MainCoreDestroyed Function with our own.
            if (bDebug) log("Setting OnCoreDestoryed = Omni",'OmniONSScoring');
	}
	return true;
}

function MainCoreDestroyedOmniScoring(byte T)
{
    local Controller C;
    local PlayerController PC;
    local int Score;

    if (ONSGame.bOverTime)
        Score = CustomOvertimePoints;
    else
        Score = CustomRegulationPoints;
        
   

	 if (bDebug) log("Assigning Custom Points",'OmniONSScoring');

    if (T == 1)
    {
        BroadcastLocalizedMessage( class'ONSOnslaughtMessage', 0);
        ONSGame.TeamScoreEvent(0, Score, "enemy_core_destroyed");
        ONSGame.Teams[0].Score += Score;
        ONSGame.Teams[0].NetUpdateTime = Level.TimeSeconds - 1;
       ONSGame.CheckScore(ONSGame.PowerCores[ONSGame.FinalCore[1]].LastDamagedBy);
    }
    else
    {
        BroadcastLocalizedMessage( class'ONSOnslaughtMessage', 1);
        ONSGame.TeamScoreEvent(1, Score, "enemy_core_destroyed");
        ONSGame.Teams[1].Score += Score;
        ONSGame.Teams[1].NetUpdateTime = Level.TimeSeconds - 1;
        ONSGame.CheckScore(ONSGame.PowerCores[ONSGame.FinalCore[0]].LastDamagedBy);
    }
		if (bDebug) log("Begin Client Reset",'OmniONSScoring');
    //round has ended
    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        PC = PlayerController(C);
        if (PC != None)
        {
            PC.ClientSetBehindView(true);
            PC.ClientSetViewTarget(ONSGame.PowerCores[ONSGame.FinalCore[T]]);
            PC.SetViewTarget(ONSGame.PowerCores[ONSGame.FinalCore[T]]);
            if (!ONSGame.bGameEnded) {
                 PC.ClientRoundEnded();
                 if (bDebug) log("PC.ClientRoundEnded called for "$PC.PlayerReplicationInfo.PlayerName,'OmniONSScoring');
            } 
            else { // match/game ended
            	  PC.ClientGameEnded();
            	   if (bDebug) log("PC.ClientGameEnded called for "$PC.PlayerReplicationInfo.PlayerName,'OmniONSScoring');
            }    
        }
       // this does fix UTComp End game drama, but its a bandaid
       /*
        if (!ONSGame.bGameEnded) {
        	   if (bDebug) log("C.RoundHasEnded called",'OmniONSScoring');
            C.RoundHasEnded();
        }    
        */
        
    }

    if (bDebug) log("End Client Reset",'OmniONSScoring');
    
    ONSGame.ResetCountDown = ONSGame.ResetTimeDelay;
    
    //reset timelimit - appears to be UT2004 bug in ONS that non winning Regulation rounds fuck up the clock.
    // I can duplicate it without this Mutator.
    
    // the attempted fix doesn't work... might just leave it as is.
    //if (T==1) {
       // this gets called for both cores, only need time reset once.
       /*
		    if (bDebug) log("RemainingTIme="$ONSGame.RemainingTime,'OmniONSScoring');
		    ONSGame.RemainingTime = 60 * ONSGame.TimeLimit;
		    ONSGame.GameReplicationInfo.RemainingMinute = ONSGame.RemainingTime;
		    if (bDebug) log("RemainingTIme Setting="$ONSGame.RemainingTime,'OmniONSScoring');
		    ONSGame.CountDown = ONSGame.Default.Countdown;
		    if (bDebug) log("CountDown Setting="$ONSGame.CountDown,'OmniONSScoring');
		    ONSGame.GameReplicationInfo.ElapsedTime = 0;
		    //ONSGame.GameReplicationInfo.bStopCountdown = True;
		    ONSGame.Timer();  // Need this to reset timer 
		    */
   // }

    if (bDebug) log("CustomMainCoreDestroyedOver..",'OmniONSScoring');
}
function bool MutatorIsAllowed()
{
	return Level.Game.IsA('ONSOnslaughtGame') && Super.MutatorIsAllowed();
}


function GetServerDetails(out GameInfo.ServerResponseLine ServerState)
{
	Class'ONSOnslaughtGame'.static.AddServerDetail(ServerState, "OmniONSScoringVersion", Build);
}


static function FillPlayInfo (PlayInfo PlayInfo)
{
	PlayInfo.AddClass(Default.Class);
	  PlayInfo.AddSetting("Omni ONS Scoring Settings", "bCustomScoring", "Enable Custom Scoring", 1, 1, "Check");
    PlayInfo.AddSetting("Omni ONS Scoring Settings", "CustomRegulationPoints", "Points for Regulation Win",255, 1, "Text","1;1:10",,True,True);
    PlayInfo.AddSetting("Omni ONS Scoring Settings", "CustomOverTimePoints", "Points for Overtime Win",255, 1, "Text","1;1:10",,True,True);
    
    PlayInfo.PopClass();
    super.FillPlayInfo(PlayInfo);
}




//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	Build = "1.0"
	FriendlyName = "Omnip)o(tents Custom Scoring (Onslaught-only)"
	Description  = "Special team scoring rules for public Onslaught matches."
	bAddToServerPackages = True

	bCustomScoring                        = True
  CustomRegulationPoints                = 2
  CustomOvertimePoints                  = 1
 	
	bDebug = True
}
