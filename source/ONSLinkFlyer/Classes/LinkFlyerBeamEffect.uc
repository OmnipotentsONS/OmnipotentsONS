// ============================================================================
// LinkFlyer                                                        ItsMeAgain
// Beam Effect, Mostly copied from LinkTank
// ============================================================================
class LinkFlyerBeamEffect extends LinkBeamEffect
    notplaceable;

// ============================================================================
simulated function SetBeamLocation()
    {
    if ((Instigator==None)||(ONSVehicle(Instigator)==None)||(ONSVehicle(Instigator).Weapons.Length<=0))
        {
        //super.SetBeamLocation();
        //StartEffect = Location;
         SetLocation( StartEffect );
        return;
        }
    StartEffect=ONSVehicle(Instigator).Weapons[0].WeaponFireLocation;
    SetLocation(StartEffect);
    }

// ============================================================================
//simulated function vector SetBeamRotation() ORIGINAL
//    {
//    SetRotation(Rotator(EndEffect-StartEffect));
//    return Normal(Vector(Rotation));
//    }

//simulated function Vector SetBeamRotation()
//    {
//    if ((Instigator!=None)&&PlayerController(Instigator.Controller)!=None)
//        SetRotation(Instigator.Controller.GetViewRotation());
//    else
//        SetRotation(Rotator(EndEffect-Location));
//
//    return Normal(EndEffect-Location);
//    }

simulated function Vector SetBeamRotation()
    {
    SetRotation(Rotator(EndEffect-StartEffect));
    return Normal(EndEffect-StartEffect);
    
    }

// ============================================================================
// defaultproperties
// ============================================================================

defaultproperties
{
     mSizeRange(0)=30.000000
     bAlwaysRelevant=True
}
