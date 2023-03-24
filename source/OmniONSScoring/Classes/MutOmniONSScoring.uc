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
	local int x;
  local NavigationPoint N;
	log(Class$" build "$Build, 'OmniONSScoring');

  ONSGame = ONSOnslaughtGame(Level.Game);
}	
	
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	 local ONSPowerCore PC;
	  
	  PC = ONSPowerCore(Other);
	  if (PC!=None)
        {
        	  PC.OnCoreDestroyed = MainCoreDestroyedOmniScoring;
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

    //round has ended
    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        PC = PlayerController(C);
        if (PC != None)
        {
            PC.ClientSetBehindView(true);
            PC.ClientSetViewTarget(ONSGame.PowerCores[ONSGame.FinalCore[T]]);
            PC.SetViewTarget(ONSGame.PowerCores[ONSGame.FinalCore[T]]);
            if (!ONSGame.bGameEnded)
                PC.ClientRoundEnded();
        }
        if (!ONSGame.bGameEnded)
            C.RoundHasEnded();
    }

    ONSGame.ResetCountDown = ONSGame.ResetTimeDelay;
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
  CustomRegulationPoints                = 1
  CustomOvertimePoints                  = 1
  
	
	bDebug = True
}
