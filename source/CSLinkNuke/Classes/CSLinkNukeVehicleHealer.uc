class CSLinkNukeVehicleHealer extends Actor;

var Vehicle Vehicle;
var float TotalTime;
var int HealthInc;
var int TotalHealth;
var int HealthMax;

var CSLinkNukeHealEffect HealEffect;

replication
{
        reliable if (Role == ROLE_Authority)
            Vehicle;
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

    Vehicle = Vehicle(Owner);
    SetTimer(TimerRate, true);
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    if(Vehicle != None)
    {
        HealEffect = Spawn(class'CSLinkNuke.CSLinkNukeHealEffect',Self,,Vehicle.Location);
        HealEffect.setBase(Vehicle);
    }
}

simulated function Timer()
{
    if(Vehicle != None && TotalHealth <= HealthMax)
    {
        Vehicle.Health = Min(Vehicle.Health + HealthInc, Vehicle.HealthMax);
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
