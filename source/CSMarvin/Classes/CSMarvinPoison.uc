class CSMarvinPoison extends Actor
    notplaceable;

var Pawn Victim;
var float VictimDamage;
var float MaxDamage;
var float DamageInterval;
var CSMarvinPoisonEffect effect;

replication
{
    reliable if(ROLE == ROLE_Authority)
        Victim, VictimDamage;
}

simulated function Poison(Pawn Poisoned, Pawn PoisonInstigator)
{
    Victim = Poisoned;
    Instigator = PoisonInstigator;
    VictimDamage = 0; 
    MaxDamage = Victim.default.Health * 0.75;
    DamageInterval = MaxDamage / 10;
    effect = spawn(class'CSMarvinPoisonEffect', Victim,,Victim.Location, Victim.Rotation);
    Victim.ReceiveLocalizedMessage(class'CSMarvinPoisonedMessage');

    SetTimer(0.5, true);
}

simulated function Timer()
{
    local vector m;
    if(VictimDamage >= MaxDamage)
    {
        SetTimer(0.0,false);
        Destroy();
        return;
    }

    if(Role == ROLE_Authority)
    {
        m.x = frand() * 70000;
        m.y = frand() * 70000;
        m.z = frand() * 5000;
        Victim.TakeDamage(DamageInterval, Instigator, Victim.Location, m, class'CSMarvinDmgTypePoisoned');
        Victim.PlayOwnedSound(Sound'GeneralImpacts.Wet.Breakbone_01', SLOT_Pain);
        VictimDamage += DamageInterval;
    }
}

function Destroyed()
{
    if(effect != none)
        effect.Destroy();
}

defaultproperties
{
    bHidden=true;
    RemoteRole=ROLE_SimulatedProxy;
}