
--https://youtu.be/6oPGjA5-4AM

local pairs = pairs

local HEV = {}

HEV.delay = CurTime()

HEV.CanSpeak = {}

HEV.CanSpeak.base = 0

HEV.LastSound = ""

HEV.ToSpeak = {}

HEV.Sounds = {}

HEV.Random = math.random

HEV.User = LocalPlayer

HEV.Systemtime = CurTime

HEV.PlayF = sound.PlayFile

HEV.LowHealthSounds = {}

HEV.Sounds[DMG_FALL] = {}
HEV.Sounds[DMG_FALL][1] = "sound/fvox/minor_fracture.wav" 
HEV.Sounds[DMG_FALL][2] = "sound/fvox/major_fracture.wav"

HEV.Sounds[DMG_BULLET] = {}
HEV.Sounds[DMG_BULLET][1] = "sound/fvox/blood_loss.wav"

HEV.Sounds[DMG_SLASH] = {}
HEV.Sounds[DMG_SLASH][1] = "sound/fvox/minor_lacerations.wav"
HEV.Sounds[DMG_SLASH][2] = "sound/fvox/major_lacerations.wav"

HEV.Sounds[DMG_CLUB] = HEV.Sounds[DMG_SLASH]
HEV.Sounds[DMG_CRUSH] = HEV.Sounds[DMG_SLASH]

HEV.Sounds[DMG_SONIC] = {}
HEV.Sounds[DMG_SONIC][1] = "sound/fvox/internal_bleeding.wav"

HEV.Sounds[DMG_RADIATION] = {}
HEV.Sounds[DMG_RADIATION][1] = "sound/fvox/radiation_detected.wav"

HEV.Sounds[DMG_RADIATION] = {}
HEV.Sounds[DMG_RADIATION][1] = "sound/fvox/radiation_detected.wav"

HEV.Sounds[DMG_POISON] = {}
HEV.Sounds[DMG_POISON][1] = "sound/fvox/blood_toxins.wav"

HEV.Sounds[DMG_PARALYZE] = HEV.Sounds[DMG_POISON] 

HEV.Sounds[DMG_POISON] = {}
HEV.Sounds[DMG_POISON][1] = "sound/fvox/blood_toxins.wav"

HEV.Sounds[DMG_SHOCK] = {}
HEV.Sounds[DMG_SHOCK][1] = "sound/fvox/shock_damage.wav"

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

	HEV.delay = HEV.Systemtime() + 0.5

	HEV.PlayF( path, "", function( station )
		if ( IsValid( station ) ) then station:Play() end
	
		HEV.delay = HEV.Systemtime() + station:GetLength() + 0.1
	end )
end

local health = FindMetaTable("Entity").Health

function HEV.Health( ply )
	return health( ply )
end

hook.Add("Think","HEV_Voice_System",function()

	if HEV.delay > HEV.Systemtime() or not system.HasFocus() then return end

	for k,v in pairs( HEV.ToSpeak ) do
		HEV.Speak( v ) --"sound/fvox/voice_on.wav"
		HEV.ToSpeak[k] = nil
		break
	end
	
end)

function HEV.Saynumber( num )

	if num > 100 then return end

	if num < 20 then
		HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/".. num ..".wav"
		return
	end

	local min = tonumber( tostring(num)[1] )*10

	HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/".. min ..".wav"

	local min = tonumber( tostring(num)[2] )

	if min == 0 then return end

	HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/".. min ..".wav"

end

function HEV.SayTime()

	local t = os.date( "*t" , os.time() )
	local pm = false

	if t.hour > 12 then
		pm = true
		t.hour = t.hour - 12
	end

	HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/time_is_now.wav"

	HEV.Saynumber( t.hour )

	if pm then
		HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/pm.wav"
	else
		HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/am.wav"
	end

	HEV.Saynumber( t.min )

	HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/minutes.wav"

end

HEV.SayTime()


net.Receive("hev_voice",function()

	if HEV.Health( HEV.User() ) < 0 then return end

	local dmgtype = net.ReadUInt( 32 )
	local dmgnum = net.ReadUInt( 32 )

	if HEV.Health( HEV.User() ) - dmgnum < 0 then
		return
	end

	if HEV.CanSpeak.base > HEV.Systemtime() then
		return
	end

	if HEV.CanSpeak[dmgtype] then
		if HEV.CanSpeak[dmgtype] > HEV.Systemtime() then return end
	end

	local hsound = nil

	if HEV.Random( 1 , 3) == 3 and HEV.Health( HEV.User() ) < 50 then
		for k,v in pairs( HEV.LowHealthSounds ) do
			if HEV.Health( HEV.User() ) < k then
				hsound = v 
			end
		end
	
		if hsound then
			HEV.ToSpeak[#HEV.ToSpeak + 1 ] = hsound
			HEV.CanSpeak[dmgtype] = HEV.Systemtime() + HEV.Random( 3 , 10 )
			HEV.CanSpeak.base = HEV.Systemtime() + 5
			return
		end
	end

	
	if not HEV.Sounds[dmgtype] then
		return
	end

	HEV.CanSpeak[dmgtype] = HEV.Systemtime() + HEV.Random( 10 , 20 )
	HEV.CanSpeak.base = HEV.Systemtime() + 5

	if HEV.Sounds[dmgtype][2] then
		if dmgnum > HEV.Health( HEV.User() )/3 then
			HEV.ToSpeak[#HEV.ToSpeak + 1 ] = HEV.Sounds[dmgtype][2]

			if HEV.Random( 1 , 20 ) == 20 then
				HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/automedic_on.wav"
				HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/sounds/hiss.wav"
				HEV.ToSpeak[#HEV.ToSpeak + 1 ] = "sound/fvox/morphine_shot.wav"
			end
			return
		else
			HEV.ToSpeak[#HEV.ToSpeak + 1 ] = HEV.Sounds[dmgtype][1]
			return
		end
	end

	HEV.ToSpeak[#HEV.ToSpeak + 1 ] = HEV.Sounds[dmgtype][1]

end)