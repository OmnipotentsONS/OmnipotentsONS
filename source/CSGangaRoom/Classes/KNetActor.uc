class KNetActor extends KActor
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
 
function Tick(float Delta)
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
	MaxNetUpdateInterval=0.5

    bBlockActors=true
    bBlockKarma=true
    bBlockNonZeroExtentTraces=true
    bBlockZeroExtentTraces=true
    bCollideActors=true
    bPathColliding=true
    bProjTarget=true
    bUseCylinderCollision=false
    StaticMesh=StaticMesh'AS_Decos.ExplodingBarrel'
 
    Begin Object Class=KarmaParams Name=KarmaParams0
        KMass=0.1
        bHighDetailOnly=False
        bKAllowRotate=True
        //KFriction=0.2
        //KRestitution=0.5
        //KImpactThreshold=1000.0
        KRestitution=0.0
        KImpactThreshold=1000000.0
        KFriction=1.0
        bClientOnly=False
        Name="KarmaParams0"
    End Object
	KParams=KarmaParams'KarmaParams0'
 
	RemoteRole=ROLE_SimulatedProxy
	bNetNotify=True
}

