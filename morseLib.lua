local led = gdt.Led0
local audChip = gdt.AudioChip0
local speaker = gdt.Speaker1
speaker.State = true
local rom = gdt.ROM
local squarewav = rom.User.AudioSamples["square.wav"]

local modulo = {
tocarSom = function()
	audChip:Play(squarewav, 1)
end,
pausarSom = function()
	audChip:Stop(1)
end,
decodeMathTl = function(tabela)
	if #tabela < 1 then return nil end
	local numAnalise = math.clamp(#tabela,1,6)
	local arr = {}
	for i=1,numAnalise do
		table.insert(arr, tabela[#tabela-(i-1)])
	end
	local min = arr[1]
	local max = arr[1]
	for i = 2, #arr do
		if arr[i] < min then
			min = arr[i]
		end
		if arr[i] > max then
			max = arr[i]
		end
	end
	local media = (min+max)/2
	local returnString = ""
	for i=1,#tabela do
		if tabela[i] >= media then
			returnString = returnString.."-"
		else
			returnString = returnString.."."
		end
	end
	return returnString
end
}

return modulo