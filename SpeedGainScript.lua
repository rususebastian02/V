-- Script per aumentare la velocità del giocatore di +1 ogni secondo
-- Da inserire in ServerScriptService in Roblox Studio

local Players = game:GetService("Players")

-- Funzione per gestire ogni giocatore
local function onPlayerAdded(player)
	-- Aspetta che il personaggio del giocatore venga caricato
	player.CharacterAdded:Connect(function(character)
		-- Trova l'Humanoid nel personaggio
		local humanoid = character:WaitForChild("Humanoid")

		-- Loop infinito che aumenta la velocità ogni secondo
		spawn(function()
			while character and character.Parent and humanoid and humanoid.Parent do
				wait(1) -- Aspetta 1 secondo

				-- Verifica che l'Humanoid esista ancora
				if humanoid and humanoid.Parent then
					humanoid.WalkSpeed = humanoid.WalkSpeed + 1
					print("Velocità di " .. player.Name .. ": " .. humanoid.WalkSpeed)
				else
					break -- Esce dal loop se l'Humanoid non esiste più
				end
			end
		end)
	end)
end

-- Applica la funzione a tutti i giocatori attuali
for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Applica la funzione ai nuovi giocatori che si uniscono
Players.PlayerAdded:Connect(onPlayerAdded)
