class CSLinkNukePlayerHealer extends Actor;

var Pawn HealedPlayer;
var float TotalTime;
var int HealthInc;
var int HealthMax;
var int TotalHealth;
var CSLinkNukeHealEffect HealEffect;

replication
{
    reliable if(Role == ROLE_Authority)
        HealedPlayer;
}

simulated function Destroyed()
{
    if(HealEffect != None)
        HealEffect.Destroy();
    
    Super.Destroyed();
}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();

    TotalHealth=0;
    TotalTime=class'MutUseLinkNuke'.default.PlayerHealDuration;
    HealthInc=class'MutUseLinkNuke'.default.PlayerHealRate;
    HealthMax=class'MutUseLinkNuke'.default.PlayerHealMax;

    HealedPlayer = Pawn(Owner);
    SetTimer(TimerRate, true);
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if(HealedPlayer != None)
    {
        HealEffect = Spawn(class'CSLinkNuke.CSLinkNukeHealEffect',Self,,HealedPlayer.Location);
        HealEffect.SetBase(HealedPlayer);
    }
}

simulated function Timer()
{
    if(HealedPlayer != None && TotalHealth <= HealthMax)
    {
        HealedPlayer.Health = Min(HealedPlayer.Health + HealthInc, HealedPlayer.SuperHealthMax);
        TotalHealth+=HealthInc;
    }

    TotalTime -= TimerRate;
    if(TotalTime <= 0)
    {
        Destroy();
    }
}

defaultproperties
{
     TotalTime=5.000000
     healthInc=10
     DrawType=DT_None
     bAlwaysRelevant=True
     LifeSpan=20.000000
     TimerRate=0.100000
}
