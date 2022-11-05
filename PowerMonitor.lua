
local component = require( "component" )
local gpu = component.gpu
local event = require( "event" )
 
local oldW, oldH = gpu.getResolution()
gpu.setResolution( 160, 50 )
 
function clearScreen()
  local oldColor = gpu.getBackground( false )
  local w,h = gpu.getResolution()
  gpu.setBackground( 0x000000, false )
  gpu.fill( 1, 1, w, h, " " )
  gpu.setBackground( oldColor, false )
end
 
 
function progressBar( label, y, value, maxVal, color, show, unit )
  local oldColor = gpu.getBackground( false )
  gpu.setBackground(0x000000, false)
  gpu.fill( 3, y, 155, 2, " " )
  w = math.floor( value * (155 / maxVal) )
  p = math.floor( (w / 155) * 100 )
  gpu.set( 3, y, label .. ": " .. tostring( p ) .. "%" )
  gpu.setBackground( 0x222222, false )
  gpu.fill( 3, y+1, 155, 1, " " )
  gpu.setBackground( color, false )
  gpu.fill( 3, y+1, w, 1, " " )
  gpu.setBackground( oldColor, false )
  if show then
    local valStr = formatBig( value ) .. unit.." / " .. formatBig(maxVal) .. unit
    local n = string.len( valStr )
    gpu.set( 158 - n, y, valStr )
  end
end
 
function progressBar2( label, y, value, maxVal, producing, color, show, unit )
	local oldColor = gpu.getBackground( false )
	gpu.setBackground(0x000000, false)
	gpu.fill( 3, y, 155, 2, " " )
	w = math.floor( value * (155 / maxVal) )
	p = math.floor( (w / 155) * 100 )
	gpu.set( 3, y, label )
	gpu.setBackground( 0x222222, false )
	gpu.fill( 3, y+1, 155, 1, " " )
	gpu.setBackground( color, false )
	gpu.fill( 3, y+1, w, 1, " " )
	gpu.setBackground( oldColor, false )
	if show then
	  local valStr = "Producing: ".. formatBig(producing).. unit.."/t"

	  local n = string.len( valStr )
	  gpu.set( 158 - n, y, valStr )
	end
  end


 
function formatBig( value )
  local output = ""
  local valRem = 0
  local valPart = 0
  while value > 0 do
    valRem = math.floor( value / 1000 )
    valPart = value - (valRem * 1000)
    if output == "" then
      valPart = math.ceil(valPart)
      output = string.format( "%03d", valPart )
    elseif valRem == 0 then
      output = valPart .. "," .. output
    else
      output = string.format( "%03d", valPart ) .. "," .. output
    end
    value = valRem
  end
  return output
end
  
function getCells()
	local countDcOrb = 0
	local countTEcell = 0
	local countRfTCell = 0
	local countIDCell = 0
	local countMKreactor = 0
	

	local DcOrb = component.list("draconic_rf_storage")
	local RfTCell = component.list("rftools_powercell")
	local IDCell = component.list("induction_matrix")

	local MKreactor = component.list("reactor_logic_adapter")

	local cellsID = {}	
	for address, name in pairs(DcOrb) do
		countDcOrb =  countDcOrb + 1
		if countDcOrb > 1 then
			cellsID[address] = "Draconic Power Orb".." "..countDcOrb
		else
			cellsID[address] ="Draconic Power Orb"
		end	
	end
	for address, name in pairs(MKreactor) do
		countMKreactor =  countMKreactor + 1
		if countMKreactor > 1 then
			cellsID[address] = "Mekanism Fusion Reactor".." "..countMKreactor
		else
			cellsID[address] ="Mekanism Fusion Reactor"
		end	
	end
    for address, name in pairs(IDCell) do
		countIDCell =  countIDCell + 1
		if countIDCell > 1 then
			cellsID[address] = "Mekanism Induction Matrix".." "..countIDCell
		else
			cellsID[address] ="Mekanism Induction Matrix"
		end	
	end
	
	for address, name in pairs(RfTCell) do
		countRfTCell = countRfTCell + 1

		if countRfTCell > 1 then
			cellsID[address] = "RfTools Power Cell".." "..countRfTCell
		else
			cellsID[address] = "RfTools Power Cell"
		end
	end 
  return cellsID
end

function getTotal()
	local totalPower = 0
	local totalMaxPower = 0	
	local cellid = getCells()
	for address, name in pairs(cellid) do

        if name == "Mekanism Induction Matrix" then
            local cell = component.proxy( address )
		totalPower = totalPower + cell.getEnergy() * 0.4
        totalMaxPower = totalMaxPower + cell.getMaxEnergy() * 0.4
        elseif name == "Mekanism Fusion Reactor" then
            local cell = component.proxy( address )
		totalPower = totalPower + cell.getEnergy() * 0.4
        totalMaxPower = totalMaxPower + cell.getMaxEnergy() * 0.4
        else 
        local cell = component.proxy( address )
		totalPower = totalPower + cell.getEnergyStored()
		totalMaxPower = totalMaxPower + cell.getMaxEnergyStored()
        end
	end
	return totalPower, totalMaxPower

end
 
clearScreen()
gpu.set( 67, 1, "Power Monitor" )
local cellsID = getCells()

while true do
  local _,_,x,y = event.pull( 1, "touch" )
  local count = 0 
  if x and y then goto quit end
  for address, name in pairs(cellsID) do
	local cell = component.proxy( address )
	count = count + 1
	local t = count * 3

    if name == "Mekanism Induction Matrix" then
	progressBar( name, t , cell.getEnergy() * 0.4, cell.getMaxEnergy() * 0.4, 0x00bb00, true, "RF" )
    elseif name == "Mekanism Fusion Reactor" then
		progressBar2( name, 40 - count , cell.getEnergy() * 0.4, cell.getMaxEnergy() * 0.4,cell.getProducing() * 0.4,  0x00bb00, true, "RF" )
		else
        progressBar( name, t , cell.getEnergyStored(), cell.getMaxEnergyStored() , 0x00bb00, true, "RF" )
    end
	end
	
	local totalPower, totalMaxPower = getTotal()
	progressBar( "TotalPower", 48 - count , totalPower, totalMaxPower, 0x00bb00, true, "RF" )
 
  os.sleep(0.25)
end
 
 
::quit::
gpu.setResolution( oldW, oldH )
clearScreen()