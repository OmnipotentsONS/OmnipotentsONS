class MutNodeAttackFix extends Mutator;

var config float TimerInterval;
var config bool bEnabled;

function PostBeginPlay()
{
    super.PostBeginPlay();
    if(ONSOnslaughtGame(Level.Game) != None && bEnabled)
    {
        SetTimer(TimerInterval, true);
    }
}

function Timer()
{
    local ONSOnslaughtGame ONSGame;
    local int i;
    local bool bOldUnderAttack;

    ONSGame = ONSOnslaughtGame(Level.Game);

    if(ONSGame != None && ONSGame.IsInState('MatchInProgress'))
    {
        for(i=0;i<ONSGame.PowerCores.Length;i++)
        {
            if ( Level.TimeSeconds > ONSGame.PowerCores[i].LastAttackExpirationTime )
            {
                bOldUnderAttack = ONSGame.PowerCores[i].bUnderAttack;
                ONSGame.PowerCores[i].bUnderAttack = (Level.TimeSeconds - ONSGame.PowerCores[i].LastAttackTime < ONSGame.PowerCores[i].LastAttackExpirationTime);
                if (bOldUnderAttack != ONSGame.PowerCores[i].bUnderAttack)
                    ONSGame.PowerCores[i].UnderAttackChange();
            }
        }
    }
}

static function FillPlayInfo (PlayInfo PlayInfo)
{
    local byte weight;

	PlayInfo.AddClass(Default.Class);
    PlayInfo.AddSetting("Node Attack Fix", "bEnabled", "Enable Attack Fix", 0, weight++, "Check");
    PlayInfo.AddSetting("Node Attack Fix", "TimerInterval", "Timer interval for checking", 0, weight++, "Text", "0;0.0:2.0");
    PlayInfo.PopClass();

    super.FillPlayInfo(PlayInfo);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bEnabled": return "Check this to enable Node Attack Fix";
		case "TimerInterval": return "Node Attack Fix interval";
    }

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
    bAddToServerPackages=true
    FriendlyName="Node Attack Fix"
    Description="Fix delay when powernode is under attack"
    TimerInterval=0.1
    bEnabled=true
}