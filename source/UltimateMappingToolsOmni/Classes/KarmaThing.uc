//-----------------------------------------------------------------------------
// KarmaThing
// Coded by unknown author, we got the script from a mapper who said that the
// creator allowed to freely distribute this script, so I put it in this tool set.
//
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 11.10.2011 21:37:45 in Package: UltimateMappingTools$
//
// This is a fixed version of the KActor that works in online games.
//-----------------------------------------------------------------------------
class KarmaThing extends KActor
    placeable;

var() float MaxNetUpdateInterval;
var float NextNetUpdateTime;

var KRigidBodyState KState, KRepState;
var bool bNewKState;
var int StateCount, LastStateCount;

replication
{
    unreliable if(Role == ROLE_Authority)
        KRepState, StateCount;
}

event Tick(float Delta)
{
    PackState();
}

//Pack current state to be replicated
function PackState()
{
    local bool bChanged;

    if(!KIsAwake())
        return;

    KGetRigidBodyState(KState);

    bChanged = Level.TimeSeconds > NextNetUpdateTime;
    bChanged = bChanged || VSize(KRBVecToVector(KState.Position) - KRBVecToVector(KRepState.Position)) > 5;
    bChanged = bChanged || VSize(KRBVecToVector(KState.LinVel) - KRBVecToVector(KRepState.LinVel)) > 1;
    bChanged = bChanged || VSize(KRBVecToVector(KState.AngVel) - KRBVecToVector(KRepState.AngVel)) > 1;

    if(bChanged)
    {
        NextNetUpdateTime = Level.TimeSeconds + MaxNetUpdateInterval;
        KRepState = KState;
        StateCount++;
    }
    else
        return;
}

//New state recieved.
simulated event PostNetReceive()
{
    if(StateCount == LastStateCount)
        return;
}

//Apply new state.
simulated event bool KUpdateState(out KRigidBodyState newState)
{
    //This should never get called on the server - but just in case!
    if(Role == ROLE_Authority || StateCount == LastStateCount)
        return false;

    //Apply received data as new position of actor.
    newState = KRepState;
    StateCount = LastStateCount;

    return true;
}

defaultproperties
{
     MaxNetUpdateInterval=0.500000
     StaticMesh=StaticMesh'cp_Mechstaticpack1.Decos.cp_sg_Mechtechbarrel4'
}
