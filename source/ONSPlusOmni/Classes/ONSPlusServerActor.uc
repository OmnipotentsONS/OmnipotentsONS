// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusServerActor extends Info;

// The purpose of this serveractor is to add ONSPlus to the mutator list if it isn't already there (TODO: Can't you just add the mutator itself as a serveractor and have it auto-add itself??)
function PreBeginPlay()
{
	Level.Game.AddMutator(string(class'ONSPlusMutator'));

	Destroy();
}

defaultproperties
{
	bHidden=True
}