
--https://youtu.be/6oPGjA5-4AM

if CLIENT then

local HEV = {}

HEV.delay = CurTime()

HEV.CanSpeak = CurTime()

HEV.LastSound = ""

HEV.ToSpeak = {}

HEV.Sounds = {}


HEV.LowHealthSounds = {}

HEV.Sounds[DMG_FALL] = {}
HEV.Sounds[DMG_FALL][1] = "sound/fvox/minor_fracture.wav" 
HEV.Sounds[DMG_FALL][2] = "sound/fvox/major_fracture.wav"

HEV.Sounds[DMG_BULLET] = {}
HEV.Sounds[DMG_BULLET][1] = "sound/fvox/blood_loss.wav"

HEV.Sounds[DMG_SLASH] = {}
HEV.Sounds[DMG_SLASH][1] = "sound/fvox/minor_lacerations.wav"
HEV.Sounds[DMG_SLASH][2] = "sound/fvox/major_lacerations.wav"

HEV.Sounds[DMG_SONIC] = {}
HEV.Sounds[DMG_SONIC][1] = "sound/fvox/internal_bleeding.wav"

HEV.Sounds[DMG_RADIATION] = {}
HEV.Sounds[DMG_RADIATION][1] = "sound/fvox/radiation_detected.wav"

HEV.Sounds[DMG_RADIATION] = {}
HEV.Sounds[DMG_RADIATION][1] = "sound/fvox/radiation_detected.wav"

HEV.Sounds[DMG_POISON] = {}
HEV.Sounds[DMG_POISON][1] = "sound/fvox/blood_toxins.wav"

HEV.Sounds[DMG_POISON] = {}
HEV.Sounds[DMG_POISON][1] = "sound/fvox/blood_toxins.wav"

HEV.Sounds[DMG_SHOCK] = {}
HEV.Sounds[DMG_SHOCK][1] = "sound/fvox/shock_damage.wav" -- TOPO find this sound 

HEV.Sounds[DMG_BURN] = {}
HEV.Sounds[DMG_BURN][1] = "sound/fvox/heat_damage.wav"

HEV.Sounds[DMG_ACID] = {}
HEV.Sounds[DMG_ACID][1] = "sound/fvox/chemical_detected.wav"

HEV.Sounds[DMG_NERVEGAS] = {}
HEV.Sounds[DMG_NERVEGAS][1] = "sound/fvox/biohazard_detected.wav"

HEV.Sounds[DMG_NERVEGAS] = {}
HEV.Sounds[DMG_NERVEGAS][1] = "sound/fvox/biohazard_detected.wav"

HEV.LowHealthSounds[50] = "sound/fvox/seek_medic.wav"

HEV.LowHealthSounds[30] = "sound/fvox/seek_medic.wav"

HEV.LowHealthSounds[6] = "sound/fvox/near_death.wav"



function HEV.Speak( path )

	HEV.delay = CurTime() + 0.5

	sound.PlayFile( path, "", function( station )
		if ( IsValid( station ) ) then station:Play() end
	
		HEV.delay = CurTime() + station:GetLength() + 0.5
	end )
end

function HEV.GetPhrase( dmg )

end

hook.Add("Think","HEV_Voice_System",function()

	if HEV.delay > CurTime() or not system.HasFocus() then return end

	for k,v in pairs( HEV.ToSpeak ) do
		HEV.Speak( v ) --"sound/fvox/voice_on.wav"
		HEV.ToSpeak[k] = nil
		break
	end
	
end)

hook.Add("HUDItemPickedUp","HEV_Voice_System",function( item )
	print( item )
end)


function HEV.SayTime()
	local t = os.date( "*t" , os.time() )
	local pm = false

	if t.hour > 12 then
		pm = true
		t.hour = t.hour - 12
	end

	PrintTable( t )

	HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/time_is_now.wav"
	HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/".. t.hour ..".wav"

	if pm then
		HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/pm.wav"
	else
		HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/am.wav"
	end

	local min = tonumber( tostring(t.min)[1] )*10

	HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/".. min ..".wav"

	local min = tonumber( tostring(t.min)[2] )

	HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/".. min ..".wav"

	HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/minutes.wav"

end

--HEV.SayTime()


function HEV.Saynumber( num )

	if num > 100 then return end

	local min = tonumber( tostring(num)[1] )*10

	HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/".. min ..".wav"

	local min = tonumber( tostring(num)[2] )

	if min == 0 then return end

	HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/".. min ..".wav"

end


net.Receive("hev_voice",function()

	if HEV.CanSpeak > CurTime() then return end

	local dmgtype = net.ReadUInt( 32 )
	local dmgnum = net.ReadUInt( 32 )

	local hsound = nil

	if math.random( 1 , 5) == 5 and LocalPlayer():Health() < 50 then
		for k,v in pairs( HEV.LowHealthSounds ) do
			if LocalPlayer():Health() < k then
				hsound = v 
			end
		end
	
		if hsound then
			HEV.ToSpeak[#HEV.ToSpeak + 1 ] = hsound
			HEV.CanSpeak = CurTime() + math.random( 3 , 10 )
			return
		end
	end

	
	if not HEV.Sounds[dmgtype] then
		--print( dmgtype )
		return
	end

	HEV.CanSpeak = CurTime() + math.random( 10 , 20 )

	if HEV.Sounds[dmgtype][2] then
		if dmgnum > LocalPlayer():Health()/3 then
			HEV.ToSpeak[#HEV.ToSpeak + 1 ] = HEV.Sounds[dmgtype][2]
			return
		else
			HEV.ToSpeak[#HEV.ToSpeak + 1 ] = HEV.Sounds[dmgtype][1]
			return
		end
	end

	HEV.ToSpeak[#HEV.ToSpeak + 1 ] = HEV.Sounds[dmgtype][1]

end)

end

if SERVER then

local DMGs = {}

util.AddNetworkString("hev_voice")

hook.Add("EntityTakeDamage","HEV_Voice_System",function( ply, dmg )

	if not ply:IsPlayer() then return end

	if DMGs[ply] then
		if DMGs[ply] > CurTime() then
			return
		end
	end

	net.Start("hev_voice")
	net.WriteUInt( dmg:GetDamageType() , 32 )
	net.WriteUInt( dmg:GetDamage() , 32 )
	net.Send( ply )

end)

end