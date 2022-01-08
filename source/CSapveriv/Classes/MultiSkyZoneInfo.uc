//=============================================================================
// MultiSkyZoneInfo    for more then one skybox in a level
//
// There is one thing we need to understand about multiple skies first.
// There can only be one ZoneInfo actor per zone,
// and that includes SkyZoneInfos and MultiSkyZoneInfos.
// If there is more than one they will interfere with each other
// and not work properly.
// In addition, you cannot look at two different skies at the same time.
// Any zone that has a MultiSkyZoneInfo has to be separated from zones
// with a different sky by a "buffer" zone,
// with no line of sight between them.
//
// Another option would be to have the areas completely isolated
// and linked by teleporters,
// but keep in mind that you can see other parts of the level through fake backdrops,
// and if you can see through to a zone with a different sky then
// it will not work correctly.
//
// To use MultiSkyZoneInfos, select it and add one to each of the zones
// with fake backdrops.
//
// Open up our MultiSkyZoneInfo actor's properties and hit Find next
// to the MultiSkyZoneInfo >> WhatSkyZone field.
// Your cursor changes, now you are in the find mode.
// Go to the SkyZoneInfo actor you want it to use and click it,
// and it should appear in the property box.
//
// Or go to the skybox you want to use properties, under Object find the name
// example (skyzoneinfo1) and type that name into the MultiSkyZoneInfo >> WhatSkyZone field.
//
// do this for each MultiSkyZoneInfo in your level. Double check that
// none of the zones can see each other, and that the buffer zone is
// separating them.
//
// Be sure to check every angle in your rooms, sometimes it will look
// like it is working, but if you turn a certain way the engine will
// see two skies and try to show both at the same time, giving you a
// flickering image or a hall of mirrors.
//=============================================================================
class MultiSkyZoneInfo extends SkyZoneInfo placeable;


//-----------------------------------------------------------------------------
// Zone properties.

var() skyzoneinfo WhatSkyZone;  // optional sky zone containing this zone's sky.

simulated function LinkToSkybox()
{
 SkyZone=WhatSkyZone;
}

defaultproperties
{
}
