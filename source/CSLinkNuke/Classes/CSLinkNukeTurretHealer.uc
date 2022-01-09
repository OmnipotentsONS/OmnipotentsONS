class CSLinkNukeTurretHealer extends Actor;

var ONSManualGunPawn Turret;
var float TotalTime;
var int HealthInc;
var int HealthMax;
var int TotalHealth;
var CSLinkNukeHealEffect HealEffect;

replication
{
    reliable if(Role == ROLE_Authority)
        Turret;
}

simulated function Destroyed()
{
    if(HealEffect != None)
        HealEffect.Destroy();
    
    Super.Destroyed();
}


simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    TotalHealth=0;
    TotalTime=class'MutUseLinkNuke'.default.VehicleHealDuration;
    HealthInc=class'MutUseLinkNuke'.default.VehicleHealRate;
    HealthMax=class'MutUseLinkNuke'.default.VehicleHealMax;

    Turret = ONSManualGunPawn(Owner);
    SetTimer(TimerRate, true);
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    if(Turret != None)
    {
        HealEffect = Spawn(class'CSLinkNuke.CSLinkNukeHealEffect',Self,,Turret.Location);
        HealEffect.setBase(Turret);
    }
}

simulated function Timer()
{
    if(Turret != None && TotalHealth <= HealthMax)
    {
        Turret.Health = Min(Turret.Health + HealthInc, Turret.HealthMax);
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
     HealthInc=100
     HealthMax=800
     DrawType=DT_None
     bAlwaysRelevant=True
     LifeSpan=20.000000
     TimerRate=0.100000
}
