//=============================================================================
// HealVolume
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 13.10.2011 20:49:52 in Package: UltimateMappingTools$
//
// Volume that allows to heal player or vehicles inside it.
//=============================================================================
class HealVolume extends Volume;

var() int HealAmount;
var() bool bSuperHeal; // like vials and big keg
var() bool bTriggerHeal; // if true, the health will only be added to pawns that are inside at the moment the Volume is triggered.
                         // if false, it will heal over time.
var() bool bActive; // if true, the volume will heal from the beginning

var() class<Pawn> HealClass; // heal actors of the following class, including subclasses. For example choose "Vehicle" for vehicles, "xPawn" for players or "Pawn" for both.


var   bool bOldActive;


event PostBeginPlay()
{
    super.PostBeginPlay();

    bOldActive = bActive;


    if ( bTriggerHeal )
        GotoState('TriggerHeal');
    else
    {
        GotoState('HealOverTime'); // Just to make sure, in case the LD messes up.

        if ( bActive && HealAmount > 0 )
            SetTimer(1, True);
    }
}

function Reset()
{
    bActive = bOldActive;
}


auto state HealOverTime
{
    event Timer()
    {
        local Pawn P;

        foreach TouchingActors (class'Pawn', P)
        {
            if ( ClassIsChildOf(P.Class,HealClass) )
            {
                if ( bSuperHeal )
                    P.GiveHealth(HealAmount, P.SuperHealthMax);
                else
                    P.GiveHealth(HealAmount, P.HealthMax);
            }
        }
    }

    event Trigger(Actor Other, Pawn EventInstigator)
    {
        if ( !bActive && HealAmount > 0 )
        {
            SetTimer(1, True);
        }

        bActive = True;
    }

    event UnTrigger(Actor Other, Pawn EventInstigator)
    {
        if (bActive && HealAmount > 0)
        {
            SetTimer(0, False);
        }

        bActive = False;
    }
}


state TriggerHeal
{
    event Trigger(Actor Other, Pawn EventInstigator)
    {
        local Pawn P;

        if ( HealAmount > 0)
        {
            foreach TouchingActors (class'Pawn', P)
            {
                if ( ClassIsChildOf(P.Class,HealClass) )
                {
                    if ( bSuperHeal )
                        P.GiveHealth(HealAmount, P.SuperHealthMax);
                    else
                        P.GiveHealth(HealAmount, P.HealthMax);
                }
            }
        }
    }
}

defaultproperties
{
}
