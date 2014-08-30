--initialization for choice of faction
function initialize_choice()
   print("initialize_choice")
   for i=1,7 do
      disableAi(i)
      disableConsume(i)
   end

--   setDisplayText("selection_text")
   createUnit("horseman", 0, startLocation(0))
   createUnit("slave", 1, startLocation(0))
   createUnit("worker", 2, startLocation(0))
   createUnit("initiate", 3, startLocation(0))
   createUnit("thrull", 4, startLocation(0))
   createUnit("worker", 5, startLocation(0))
   createUnit("slave", 6, startLocation(0))
   createUnit("worker", 7, startLocation(0))
   setCameraPosition(startLocation(0))
   togglePauseGame(1)
end

factions = {
   "egypt","indian","magic","norsemen","persian","romans","tech"
}

faction_index = {
   ["egypt"]=1, ["indian"]=2, ["magic"]=3, ["norsemen"]=4,
   ["persian"]=5, ["romans"]=6, ["tech"]=7
}

function attacked_unit_choice()
   local faction_no=unitFaction(lastAttackedUnit())
   local faction_name = factions[faction_no]
   local scenario_name = "harvest_defense"
   next_scenario=scenario_name .. "/" .. faction_name .. "/" .. scenario_name
   local frames=getWorldFrameCount()
   --world frame count is preserved on loadScenario
   --Use it as a covert channel to pass faction info between scenarios.
   next_scenario_load_frame=frames + (faction_no-1 - frames)%7
   startTimerEvent()
end

function timer_trigger_choice()
   if getWorldFrameCount()==next_scenario_load_frame
   then
      loadScenario(next_scenario,0)
   end
end

function no_action() end

--initialization for actual scenario
function initialize_scenario()
   print("initialize_scenario")
   --put player starting units depending on faction
   --determine what faction this is
   base_frame = getWorldFrameCount()
   local faction_name = factions[base_frame%7+1]
   local init={}
   function putAtBase(unit)
      createUnit(unit, 0, startLocation(0))
   end
   function init.egypt()
      putAtBase("pyramid")
      for _=1,9 do
         putAtBase("slave")
      end
      for _=1,4 do
         putAtBase("chicken")
      end
   end
   function init.indian()
      putAtBase("mainteepee")
      for _=1,12 do
         putAtBase("worker")
      end
   end
   function init.magic()
      putAtBase("mage_tower")
      for _=1,12 do
         putAtBase("initiate")
      end
   end
   function init.norsemen()
      putAtBase("castle")
      for _=1,9 do
         putAtBase("thrull")
      end
      putAtBase("cow")
      putAtBase("cow")
   end
   function init.persian()
      putAtBase("palace")
      for _=1,9 do
         putAtBase("worker")
      end
      putAtBase("sheep")
      putAtBase("sheep")
   end
   function init.romans()
      putAtBase("forum")
      for _=1,9 do
         putAtBase("slave")
      end
      putAtBase("cow")
   end
   function init.tech()
      putAtBase("castle")
      for _=1,9 do
         putAtBase("worker")
      end
      putAtBase("cow")
      putAtBase("cow")
   end
   init[faction_name]()
   giveResource("gold",0,800)
   giveResource("stone",0,800)
   giveResource("wood",0,800)
   if not (faction_name=="indian" or faction_name=="magic")
   then
      giveResource("food",0,1)
   end
   for i=2,7 do
      disableAi(i)
      disableConsume(i)
   end
   event_functions={}
   local wave_timer=startEfficientTimerEvent(4*60)
   event_functions[wave_timer]=wave_event

   togglePauseGame(1)
end

function wave_event(timer)
   local wave_timer=startEfficientTimerEvent(4*60)
   event_functions[timer]=nil
   event_functions[wave_timer]=wave_event
   local frame=getWorldFrameCount()
   frame=frame-base_frame
   local seconds=frame/40
   send_wave(math.floor(seconds))
end

function makeEnemy(faction, unit)
   createUnitNoSpacing(unit, faction_index[faction], startLocation(7))
   local unit=lastCreatedUnit()
   givePositionCommand(unit, "attack", startLocation(0))
end

function send_wave(difficulty)
   -- for now, difficulty is just the time since start
   -- send 1 indian firearcher and 1 anubis for each 40 seconds
   for i=1,math.floor(difficulty/40)
   do
      makeEnemy("egypt", "anubis_warrior")
      makeEnemy("indian", "fire_archer")
   end
end

function scenario_event()
   local trigger=triggeredTimerEventId()
   return event_functions[trigger](trigger)
end

-- function unitDied()
--    if unitCount(0)==0
--    then
--       endGame()
--    end
-- end

--determine which scenario this is
--getWorldFrameCount() is nonzero for the second stage
if getWorldFrameCount()==0
then
   initialize_choice()
   unitAttacked=attacked_unit_choice
   timerTriggerEvent=timer_trigger_choice
else
   initialize_scenario()
   unitAttacked=no_action
   timerTriggerEvent=scenario_event
end
