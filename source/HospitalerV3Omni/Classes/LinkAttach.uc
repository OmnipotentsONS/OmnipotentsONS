//=============================================================================
//  Link Tank
//=============================================================================
// )o(Nodrak - 13/11/05
//     Custom Tank Pack
//=============================================================================
class LinkAttach extends LinkAttachment;

var ELinkColor	OldLinkColor;
var int			OldLinks;

simulated function UpdateLinkColor()
{
	super.UpdateLinkColor();
	if ( Instigator != None )
		LinkTWeapon(LinkTankHospV3Omni(Instigator).Weapons[0]).UpdateLinkColor( LinkColor );
}


simulated function PostNetReceive()
{
	super.PostNetReceive();
	if ( LinkColor != OldLinkColor && Instigator != None)
	{
		LinkTWeapon(LinkTankHospV3Omni(Instigator).Weapons[0]).UpdateLinkColor( LinkColor );
		OldLinkColor = LinkColor;
	}
	else if ( Links != OldLinks )
	{
		if ( Links > 0 )
			SetLinkColor( LC_Gold );
		else
			SetLinkColor( LC_Green );
		OldLinks = Links;
	}
}

simulated event ThirdPersonEffects()
{
    super(xWeaponAttachment).ThirdPersonEffects();
}

defaultproperties
{
     bReplicateLinkColor=True
     Mesh=None
     bNetNotify=True
}
