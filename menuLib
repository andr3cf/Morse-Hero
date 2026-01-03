local opcoes = {"Start", "Config"}
local tela = gdt.Lcd0
local botao = gdt.ScreenButton0

-- variaveis
local quebrarMenu = false
local opcao = 1

-- funcoes
function pularLinha(mensagem:string)
	local input = mensagem
	local faltante = 16-#input
	for i=1,faltante do
		input = input.." "
	end
	return input
end

function clicouCurto()
	if opcao < #opcoes then
		opcao += 1
	else
		opcao = 1
	end
end

function clicouLongo()
	if opcoes[opcao] == "Start" then
		quebrarMenu = true
	end
end

local modulo = {
abrirMenu = function()
	quebrarMenu = false
	local waitingRelease = false
	local botaoTimer = 0
	while not quebrarMenu do
		local printString = ""
		if waitingRelease then
			botaoTimer += 1
		end
		if botao.ButtonState == true and waitingRelease == false then
			waitingRelease = true
		elseif botao.ButtonState == false and waitingRelease == true then
			waitingRelease = false
			if botaoTimer > 5 then
				clicouLongo()
			else
				clicouCurto()
			end
			botaoTimer = 0
		end
		-- render
		printString = printString..opcoes[opcao]
		printString = pularLinha(printString)
		local varPreLoop = math.clamp(botaoTimer, 0, 5)*16/5
		if varPreLoop == 16 then
			tela.BgColor = color.green
		else
			tela.BgColor = color.black
		end
		for i=0,varPreLoop do
			if i==0 then continue end
			printString = printString.."-"
		end
		tela.Text = printString
		sleep(0.1)
	end
	return
end
}

return modulo