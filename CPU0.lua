-- requires
local morseLib = require("morseLib.lua")
local menuLib = require("menuLib.lua")

-- memoria
local alfabeto = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
local alfabetoMorse = {".-", "-...", "-.-.", "-..", ".", "..-.", "--.", "....", "..", ".---", "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.", "...", "-", "..-", "...-", ".--", "-..-", "-.--", "--.."}

-- keyboard
local kbChip = gdt.KeyboardChip0
local inputSource = kbChip:GetButton(KeyboardChip.Space)

-- partes
local tela = gdt.Lcd0
local botao = gdt.ScreenButton0
botao.InputSource = inputSource
local audioChip = gdt.AudioChip0
local led = gdt.Led0
led.Color = color.white
local seed = math.random(1000,2000)
math.randomseed(seed+7)

-- var
local gameCounter = 0
local counter = 0
local timeLine = {}
local mathTl = {}
local leitura = ""
local letrasGeradas = {}
local numPosUltLetra = 0
local pontuacao = 0

-- loop break
local breakMainLoop = false

-- funcoes
function pularLinha(mensagem:string)
	local input = mensagem
	local faltante = 16-#input
	for i=1,faltante do
		input = input.." "
	end
	return input
end

function moverLetra()
	for i=1, #letrasGeradas do
		letrasGeradas[i][2] -= 1
		if letrasGeradas[i][2] <= 0 then
			breakMainLoop = true
		end
	end
end

function gerarLetra()
	local aleatorio = math.random(1,26)
	local altAleatoria = math.random(1,2)
	letrasGeradas[#letrasGeradas+1] = {alfabeto[aleatorio],16,altAleatoria}
end

function quebrarLetra()
	local letraAlvo = nil
	if letrasGeradas[1] == nil then return end
	local menorLetra = letrasGeradas[1]
	local numMenorLetra = 1
	for i=2, #letrasGeradas do
		if letrasGeradas[2] == nil then break end
		if letrasGeradas[i][2] < menorLetra[2] then
			menorLetra = letrasGeradas[i]
			numMenorLetra = i
		end
	end
	local numLetra = table.find(alfabeto, menorLetra[1])
	menorLetra = alfabetoMorse[numLetra]
	local morseInput = morseLib.decodeMathTl(mathTl)
	if morseInput == nil then return end
	if numPosUltLetra == 0 then return end 
	morseInput = string.sub(morseInput, #morseInput-math.clamp(numPosUltLetra-1,0,9999),#morseInput)
	if morseInput == "" then return end
	morseInput = string.sub(morseInput, math.clamp(#morseInput-#menorLetra+1,1,#morseInput), #morseInput)
	print(morseInput)
	if morseInput == menorLetra then
		numPosUltLetra = 0
		pontuacao += 1
		letrasGeradas[numMenorLetra] = nil
		for i=1,#letrasGeradas do
			if letrasGeradas[i] == nil then
				if letrasGeradas[i+1] ~= nil then
					letrasGeradas[i] = letrasGeradas[i+1]
					letrasGeradas[i+1] = nil
				else
					return
				end
			end
		end
	end
end

function renderizarLetras()
	local letrasCima = {}
	local letrasBaixo = {}
	for i=1, 16 do
		for x=1,#letrasGeradas do
			if letrasGeradas[x] ~= nil then
				if letrasGeradas[x][3] == 1 and letrasGeradas[x][2] == i then
					letrasCima[#letrasCima+1] = letrasGeradas[x][1]
				elseif letrasGeradas[x][3] == 2 and letrasGeradas[x][2] == i then
					letrasBaixo[#letrasBaixo+1] = letrasGeradas[x][1]
				end
			end
		end
		-- dps de colocar a letras na tabela
		if letrasCima[i] == nil then
			letrasCima[i] = " "
		end
		if letrasBaixo[i] == nil then
			letrasBaixo[i] = " "
		end
	end
	local stringCima = ""
	for i=1,16 do
		stringCima = stringCima..letrasCima[i]
	end
	local stringBaixo = ""
	for i=1,16 do
		stringBaixo = stringBaixo..letrasBaixo[i]
	end
	local printString = pularLinha(stringCima)
	tela.Text = printString..stringBaixo
end

function lerBotao()
	if botao.ButtonState == true then
		timeLine[#timeLine+1] = true
		if not audioChip:IsPlaying(1) then
			morseLib.tocarSom()
			led.State = true
		end
	else
		if timeLine[#timeLine] == true then
			numPosUltLetra += 1
		end
		timeLine[#timeLine+1] = false
		morseLib.pausarSom()
		led.State = false
	end
	local lastTl = false
	local timeCounter = 0
	mathTl = {}
	for i=1,#timeLine do
		if timeLine[i] == true then
			timeCounter += 1
		else
			if lastTl == true then
				mathTl[#mathTl+1] = timeCounter
				timeCounter = 0
			end
		end
		lastTl = timeLine[i]
	end
end

function update() -- ordem: gerar - input - quebrar - renderizar - (detectarErro -> mover) - counter++
	morseLib.pausarSom()
	menuLib.abrirMenu()
	tela.Text = ""
	letrasGeradas = {}
	mathTl = {} -- pode?
	pontuacao = 0
	while not breakMainLoop do
		if gameCounter % (100-pontuacao*2) == 0 then
			gerarLetra()
		end
		quebrarLetra()
		lerBotao()
		renderizarLetras()
		if gameCounter % (40-pontuacao) == 0 then
			moverLetra()
		end
		sleep(0.01)
		gameCounter = gameCounter+1
	end
	breakMainLoop = false
end