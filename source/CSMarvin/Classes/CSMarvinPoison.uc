class CSMarvinPoison extends Actor
    notplaceable;

var Pawn Victim;
var float VictimDamage;
var float MaxDamage;
var float DamageInterval;
var CSMarvinPoisonEffect effect;

simulated function PostNetBeginPlay()
{
    super.PostNetBeginPlay();
    Victim = Pawn(Owner);
    if(Role < ROLE_Authority)
    {
        effect = spawn(class'CSMarvinPoisonEffect',Victim,,Victim.Location, Victim.Rotation);
        effect.SetBase(Victim);
    }

    VictimDamage = 0; 
    MaxDamage = Victim.default.Health * 0.75;
    DamageInterval = MaxDamage / 10;
    Victim.ReceiveLocalizedMessage(class'CSMarvinPoisonedMessage');
    SetTimer(0.5, true);
}

simulated function Poison(Pawn PoisonInstigator)
{
    Victim = Pawn(Owner);
    if(Victim != None)
    {
        Instigator = PoisonInstigator;
        VictimDamage = 0; 
        MaxDamage = Victim.default.Health * 0.75;
        DamageInterval = MaxDamage / 10;
        Victim.ReceiveLocalizedMessage(class'CSMarvinPoisonedMessage');
        SetTimer(0.5, true);
    }
}

function Timer()
{
    local vector m;
    if(VictimDamage > MaxDamage)
    {
        SetTimer(0.0,false);
        Destroy();
        return;
    }

    if(Victim != None && Instigator != none)
    {
        m.x = frand() * 70000;
        m.y = frand() * 70000;
        m.z = frand() * 5000;
        Victim.TakeDamage(DamageInterval, Instigator, Victim.Location, m, class'CSMarvinDmgTypePoisoned');
        Victim.PlayOwnedSound(Sound'GeneralImpacts.Wet.Breakbone_01', SLOT_Pain);
        VictimDamage += DamageInterval;
    }
}

simulated function Destroyed()
{
    if(effect != none)
        effect.Destroy();
}

defaultproperties
{
    bHidden=true;
    bReplicateInstigator=true;
}