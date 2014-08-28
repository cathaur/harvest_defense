scen="harvest_defense"
-- write harvest_defense.xml from base.xml
basexml=io.open("base.xml","r")
basetext=basexml:read("*a")
basexml:close()
scenlua=io.open("scenario.lua","r")
scentext=scenlua:read("*a")
scenlua:close()
head,tail=basetext:find("STARTUP")
newtext=basetext:sub(0,head-1) .. scentext .. basetext:sub(tail+1)

hdxml=io.open("harvest_defense.xml", "w+")
hdxml:write(newtext)
hdxml:close()

-- write faction xmls from faction.xml
facxml=io.open("faction.xml", "r")
content=facxml:read("*a")
facxml:close()
factions={"egypt", "indian", "magic", "norsemen", "persian", "romans", "tech"}
for i=1,#factions
do
   local fac=factions[i]
   local newcontent=content:gsub("FACTION", fac)
   local outfilename=fac .. "/" .. scen .. "/" .. scen ..
                   "/" .. fac .. "/" .. scen .. ".xml"
   local outfile=io.open(outfilename, "w+")
   if outfile then
      outfile:write(newcontent)
      outfile:close()
   else
      io.stderr:write("could not open " .. outfilename .."\n")
   end
end
