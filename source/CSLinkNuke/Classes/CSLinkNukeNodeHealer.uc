class CSLinkNukeNodeHealer extends Actor;

var ONSPowerNode PowerNode;
var float TotalTime;
var int healthInc;
var bool bFlipNodes;
var CSLinkNukeHealEffect HealEffect;
var int LastCoreStage;
var int LastCoreHealth;


replication
{
    reliable if(Role == ROLE_Authority)
        PowerNode;
}

simulated function Destroyed()
{
    if(HealEffect != None)
        HealEffect.Destroy();
    
    Super.Destroyed();
}

//untouchable if the shield is up and it's not ours
simulated function bool Untouchable()
{
    return (PowerNode != None && !PowerNode.Shield.bHidden && PowerNode.DefenderTeamIndex != Instigator.GetTeamNum());
}

simulated function Bump(Actor Other)
{
    //override default PowerCore.Bump() behavior here
    //we want to allow other == vehicle in case player jumps in vehicle
    //while projectile is in the air

    //if ( (Pawn(Other) == None) || !Pawn(Other).IsPlayerPawn() || Vehicle(Other) != None )
    if (Pawn(Other) == None)
        return;

    if (PowerNode.PoweredBy(Pawn(Other).GetTeamNum()))
    {
        PowerNode.NetUpdateTime = Level.TimeSeconds - 1;
        PowerNode.DefenderTeamIndex = Pawn(Other).GetTeamNum();
        PowerNode.Constructor = Pawn(Other).Controller;
        PowerNode.GotoState('Reconstruction');

        // Update Links
        PowerNode.NotifyUpdateLinks();
    }
    else
        Pawn(Other).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 6);
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    TotalTime=class'MutUseLinkNuke'.default.NodeHealDuration;
    healthInc=class'MutUseLinkNuke'.default.NodeHealRate;
    bFlipNodes=class'MutUseLinkNuke'.default.bFlipNodes;

    PowerNode = ONSPowerNode(Owner);
    LastCoreStage = -1;
    if(PowerNode != None && !Untouchable() && Role == ROLE_Authority)
    {
        //First check if it's already active and not ours
        if(PowerNode.CoreStage == 0 || PowerNode.CoreStage == 2 || PowerNode.CoreStage == 5)
        {
            if(PowerNode.DefenderTeamIndex != Instigator.GetTeamNum())
            {
                if(bFlipNodes)
                {
                    //when tick happens later we rebuild the node with these values
                    LastCoreStage = PowerNode.CoreStage;
                    LastCoreHealth = PowerNode.Health;
                    //kill it
                    PowerNode.TakeDamage(5000, Instigator, vect(0,0,0), vect(0,0,0), class'DamageType');
                }
                else
                {
                    //if we are not doing flip feature
                    //just kill the node and don't start healing
                    PowerNode.TakeDamage(5000, Instigator, vect(0,0,0), vect(0,0,0), class'DamageType');
                    return;
                }
            }
        }
        else
        {
            Bump(Instigator);
        }

        //we bumped it, did it work?
        if(PowerNode.CoreStage == 0 || PowerNode.CoreStage == 2 || PowerNode.CoreStage == 5)
        {
            //start healing
            SetTimer(TimerRate, True);
        }
    }
}

function bool IsActiveStage()
{
    return PowerNode != None && (PowerNode.CoreStage == 0 || PowerNode.CoreStage == 2 || PowerNode.CoreStage == 5);
}

simulated function Tick(float DT)
{
    super.Tick(DT);
    //if we flipped it and destroyed it, keep bumping it until it's active
    if(bFlipNodes && LastCoreStage > -1 && PowerNode != None)
    {
        PowerNode.Bump(Instigator);
        if(IsActiveStage())
        {
            LastCoreStage = PowerNode.CoreStage;
            PowerNode.Health = Max(PowerNode.Health, LastCoreHealth);
            //since we destroyed it, it was untouchable() so need to spawn this
            if(HealEffect == None)
            {
                HealEffect = Spawn(class'CSLinkNuke.CSLinkNukeHealEffect',Self,,PowerNode.Location);
                HealEffect.setBase(PowerNode);
            }
            SetTimer(TimerRate, True);
        }
    }

}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    if(PowerNode != None && !Untouchable())
    {
        if(PowerNode.CoreStage == 0 || PowerNode.CoreStage == 2 || PowerNode.CoreStage == 5)
        {
            //spawn effects
            HealEffect = Spawn(class'CSLinkNuke.CSLinkNukeHealEffect',Self,,PowerNode.Location);
            HealEffect.setBase(PowerNode);
        }
    }
}

simulated function Timer()
{
    if(PowerNode != None)
    {
        PowerNode.Health = Min(PowerNode.Health + healthInc, PowerNode.DamageCapacity);
    }

    TotalTime -= TimerRate;
    if((TotalTime <= 0))
    {
        Destroy();
    }

}

defaultproperties
{
     TotalTime=5.000000
     healthInc=150
     DrawType=DT_None
     bAlwaysRelevant=True
     LifeSpan=20.000000
     TimerRate=0.100000
}
