class BurnerFlame extends Inventory;

#exec OBJ LOAD FILE=GeneralAmbience.uax

var class<DamageType> DamageType;

var Pawn Chef;
var int Damage, DamageDealt, BaseDamage;
var float Temperature, WaitTime;
var int MessageCounter;

var xEmitter DamageEffect;
var bool bDoFX;
var Pawn MonsterOnFire;

replication
{
	reliable if(Role == ROLE_Authority)
		bDoFX, MonsterOnFire;
}

simulated function Tick(float DeltaTime)
{
	if(Role == ROLE_Authority)
	{
		if(Owner.IsA('Monster'))
		{
			bDoFX = true;
			MonsterOnFire = Pawn(Owner);
		}

		GotoState('Waiting');
	}
	else if(bDoFX)
	{
		bDoFX = false;
		GotoState('ClientState');
	}
}

state Waiting
{
	function Tick(float DeltaTime)
	{
		if(Owner.PhysicsVolume.bWaterVolume)
		{
			Temperature = 0;
			return;
		}

		WaitTime += DeltaTime;

		if(Temperature > 0) 
		{
			GotoState('Crisping');
			bDoFX = False;
		}
		else if(WaitTime > 15) 
			Destroy();
	}
}


state Crisping
{
	function Timer()
	{
	
		if(Owner == None)
			Destroy();

		if(Owner.PhysicsVolume.bWaterVolume)
		{
			Owner.PlaySound(sound'GeneralAmbience.steamfx4', SLOT_Interact);
			Destroy();
			return;
		}

		if(Owner.IsA('Monster'))
		{
			if(Level.NetMode != NM_DedicatedServer)
				MonsterEffects();
			else
				bDoFX = true;
		}

		if(Chef != None)
		{
			if(MessageCounter == 4)
				Pawn(Owner).ReceiveLocalizedMessage(class'OnFireMessage', 1);

			Owner.TakeDamage(BaseDamage, Chef, vect(0, 0, 0), vect(0, 0, 0), DamageType);

			DamageDealt=(DamageDealt + BaseDamage);

			if(MessageCounter > 4)
				MessageCounter = 0;
			else
				MessageCounter++;
		}

		if(DamageDealt >= Damage)
			Destroy();
	}

	function Tick(float DeltaTime){}

	function EndState()
	{
		Pawn(Owner).ReceiveLocalizedMessage(class'OnFireMessage', 2);
	}

Begin:
	SetTimer(0.2, true);
	Pawn(Owner).ReceiveLocalizedMessage(class'OnFireMessage', 0);
}

simulated state ClientState
{
	simulated function Timer()
	{
		if(bDoFX)
			MonsterEffects();
	}

	function Tick(float DeltaTime){}

Begin:
	SetTimer(0.3, true);
}

simulated function MonsterEffects()
{
	local float NewScale;

	if(DamageEffect == None && MonsterOnFire != None && !Level.bDropDetail)
		DamageEffect = spawn(class'HitFlameBig',,, MonsterOnFire.Location);

	if(DamageEffect != None && DamageEffect.Base == None)
	{
		DamageEffect.SetBase(MonsterOnFire);
		NewScale = (MonsterOnFire.CollisionHeight + MonsterOnFire.CollisionRadius) / 69;
		DamageEffect.SetDrawScale(NewScale);
	}
}

simulated function Destroyed()
{
	Super.Destroyed();

	if(DamageEffect != None)
		DamageEffect.Destroy();
}

defaultproperties
{
     DamageType=Class'FireVehiclesV2Omni.Burned'
     Damage=90
  	BaseDamage = 6;  // originally was 3
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
}
