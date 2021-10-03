#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zm_buried_sq;
#include maps\mp\zombies\_zm;

main()
{
	replaceFunc( maps/mp/zm_buried_sq::sq_metagame, ::reimplementedmetaquest );
}

reimplementedmetaquest()
{
	level endon( "sq_metagame_player_connected" );
	flag_wait( "sq_intro_vo_done" );
	if ( flag( "sq_started" ) )
	{
		level waittill( "buried_sidequest_achieved" );
	}
	level thread sq_metagame_turn_off_watcher();
	is_blue_on = 0;
	is_orange_on = 0;
	m_endgame_machine = getstruct( "sq_endgame_machine", "targetname" );

	a_stat = [];
	a_stat[ 0 ] = "sq_transit_last_completed";
	a_stat[ 1 ] = "sq_highrise_last_completed";
	a_stat[ 2 ] = "sq_buried_last_completed";
	a_stat_nav = [];
	a_stat_nav[ 0 ] = "navcard_applied_zm_transit";
	a_stat_nav[ 1 ] = "navcard_applied_zm_highrise";
	a_stat_nav[ 2 ] = "navcard_applied_zm_buried";
	a_stat_nav_held = [];
	a_stat_nav_held[ 0 ] = "navcard_applied_zm_transit";
	a_stat_nav_held[ 1 ] = "navcard_applied_zm_highrise";
	a_stat_nav_held[ 2 ] = "navcard_applied_zm_buried";
	bulb_on = [];
	bulb_on[ 0 ] = 0;
	bulb_on[ 1 ] = 0;
	bulb_on[ 2 ] = 0;
	level.n_metagame_machine_lights_on = 0;
	flag_wait( "start_zombie_round_logic" );
	maps/mp/zm_buried_sq::sq_metagame_clear_lights();
	players = get_players();
	player_count = players.size;
	points_bonus = (4 - player_count) * 3;

	mapCompletedValue = 0;
	navCardAppliedValue = 0;
	reachedPoints = 0;

    bulbRequirementsReached = [];
    bulbRequirementsReached[ 0 ] = 0;
    bulbRequirementsReached[ 1 ] = 0;
    bulbRequirementsReached[ 2 ] = 0;

    failedRequirements = false;


	for ( i = 0; i < players.size; i++ )
	{
		for ( j = 0; j < a_stat.size; j++ )
		{
			mapCompletedValue = players[i] maps/mp/zombies/_zm_stats::get_global_stat( a_stat[j]);	//map completion status (0, 1 or 2)
			navCardAppliedValue = players[i] maps/mp/zombies/_zm_stats::get_global_stat( a_stat_nav[j]);	//navcard applied status (0 or 1)

			if (mapCompletedValue == 0 || navCardAppliedValue == 0)
			{
                failedRequirements = true;
			}

			reachedPoints++;

			if (mapCompletedValue == 1)
			{
				is_blue_on = 1;
				level setclientfield( "buried_sq_egm_" + i + "_" + j, 1 );
			}
			else 
			{
				if (mapCompletedValue == 2)
				{
					is_orange_on = 1;
					level setclientfield( "buried_sq_egm_" + i + "_" + j, 2 );
				}
			}

			if (navCardAppliedValue == 1)
			{
                bulbRequirementsReached[j]++;
			}
		}
	}

    //only activate bulb if every player did their navcards
    for ( i = 0; i < players.size; i++ )
    {
        for ( j = 0; j < a_stat.size; j++ )
        {
            if (bulbRequirementsReached[j] == player_count)
            {
                level setclientfield( "buried_sq_egm_bulb_" + j, 1 );
			    bulb_on[ j ] = 1;
            }
        }
    }

    if (failedRequirements)
    {
        return;
    }

	m_endgame_machine.activate_trig = spawn( "trigger_radius", m_endgame_machine.origin, 0, 128, 72 );
	m_endgame_machine.activate_trig waittill( "trigger" );
	m_endgame_machine.activate_trig delete();
	m_endgame_machine.activate_trig = undefined;
	level setclientfield( "buried_sq_egm_animate", 1 );
	m_endgame_machine.endgame_trig = spawn( "trigger_radius_use", m_endgame_machine.origin, 0, 16, 16 );
	m_endgame_machine.endgame_trig setcursorhint( "HINT_NOICON" );
	m_endgame_machine.endgame_trig sethintstring( &"ZM_BURIED_SQ_EGM_BUT" );
	m_endgame_machine.endgame_trig triggerignoreteam();
	m_endgame_machine.endgame_trig usetriggerrequirelookat();
	m_endgame_machine.endgame_trig waittill( "trigger" );
	m_endgame_machine.endgame_trig delete();
	m_endgame_machine.endgame_trig = undefined;
	level thread sq_metagame_clear_tower_pieces();
	playsoundatposition( "zmb_endgame_mach_button", m_endgame_machine.origin );
	players = get_players();
	_a1405 = players;
	_k1405 = getFirstArrayKey( _a1405 );
	while ( isDefined( _k1405 ) )
	{
		player = _a1405[ _k1405 ];
		i = 0;
		while ( i < a_stat.size )
		{
			player maps/mp/zombies/_zm_stats::set_global_stat( a_stat[ i ], 0 );
			player maps/mp/zombies/_zm_stats::set_global_stat( a_stat_nav_held[ i ], 0 );
			player maps/mp/zombies/_zm_stats::set_global_stat( a_stat_nav[ i ], 0 );
			i++;
		}
		_k1405 = getNextArrayKey( _a1405, _k1405 );
	}
	maps/mp/zm_buried_sq::sq_metagame_clear_lights();
	if ( is_orange_on )
	{
		level notify( "end_game_reward_starts_maxis" );
	}
	else
	{
		level notify( "end_game_reward_starts_richtofen" );
	}
}