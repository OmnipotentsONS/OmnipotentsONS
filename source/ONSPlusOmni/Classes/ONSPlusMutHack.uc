// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)

// A class to enable me to run the TitanTeamFix mutator without getting it whitelisted, the reason for this is I don't want to
//	bother Epic about whitelisting a beta mutator. (they already whitelisted UAdminMod anyway, and TTF does the same thing)
Class ONSPlusMutHack extends Info;

function PostBeginPlay()
{
	local mutator m;

	if (Owner != none && Mutator(Owner) != none && String(Owner.Class) ~= "TitanTeamFix.TTeamFixMut")
		for (m=Level.Game.BaseMutator; m!=none; m=m.NextMutator)
			if (ONSPlusMutator(m) != none)
				ONSPlusMutator(m).ExtraMut = Mutator(Owner);

	Destroy();
}