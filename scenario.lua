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

function attacked_unit_choice()
   local faction_no=unitFaction(lastAttackedUnit())
   local faction_name = factions[faction_no]
   local scenario_name = "harvest_defense"
   next_scenario=scenario_name .. "/" .. faction_name .. "/" .. scenario_name
   local frames=getWorldFrameCount()
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
   end
   function init.indian()
      putAtBase("mainteepee")
      for _=1,9 do
         putAtBase("worker")
      end
   end
   function init.magic()
      putAtBase("mage_tower")
      for _=1,9 do
         putAtBase("initiate")
      end
   end
   function init.norsemen()
      putAtBase("castle")
      for _=1,9 do
         putAtBase("thrull")
      end
   end
   function init.persian()
      putAtBase("palace")
      for _=1,9 do
         putAtBase("worker")
      end
   end
   function init.romans()
      putAtBase("forum")
      for _=1,9 do
         putAtBase("slave")
      end
   end
   function init.tech()
      putAtBase("castle")
      for _=1,9 do
         putAtBase("worker")
      end
   end
   init[faction_name]()
   
   -- pausing is necessary for the game to catch up to the "world frame"
   togglePauseGame(1)
end

--determine which scenario this is
--getWorldFrameCount() is nonzero for the second stage
--use startLocation(0) to determine which xml and map was loaded
if getWorldFrameCount()==0
then
   initialize_choice()
   unitAttacked=attacked_unit_choice
   timerTriggerEvent=timer_trigger_choice
else
   initialize_scenario()
   unitAttacked=no_action
   timerTriggerEvent=no_action
end
