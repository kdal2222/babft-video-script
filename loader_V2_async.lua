-- скрипт от rd450x
-- прога на конвертацию видео/фото в код для скрипта: https://github.com/kdal2222/babft-video-script/blob/main/convert.py
-- минимальное количество пластика: x * y
-- картника или видео строятся от блока дерева (видео идет вврх и влево от блока)
-- перед запуском скрипта не должны стоять блоки пластика и должен стоять 1 блок дерева

local Players = game:GetService("Players")
local Http = game:GetService("HttpService")

local player = Players.LocalPlayer

local ResizeCounter = 0

local countt = 0

print('running')

-- НАСТРОЙКИ

local fps = 1
local url = "https://raw.githubusercontent.com/kdal2222/babft-video-script/refs/heads/main/digits/" --- ссылка на видео / фото
local first_frame = nil -- первый кадр (с 0, nil если делать gif сначала)
local last_frame = nil -- количество кадров в видео (ставь 0 если фото, nil если делать gif полностью)
local auto_start_draw = false
local pr = 2 -- плотность пикселей на блок
-- КОНЕЦ НАСТРОЕК

local data = Http:JSONDecode(game:HttpGet(url..'config.json'))
local x = data['x'] 
local y = data['y']
last_frame = last_frame or data['frames']
first_frame = first_frame or 0

local block_type

local function getBlockCount(blockName)
	local success, result = pcall(function()
		return player.Data[blockName]
	end)

	if success and result then
		return result.Value
	else
		warn("Блока '" .. blockName .. "' не существует.")
		return 0
	end
end

local pixels = {}
local video = {}
local video_pixels = {}

-- local start = os.time() -- запускает таймер (необязателен)

local function clear_table(tablee) -- фиксит список pixels (мб не нужно)
	local new_table = {}
	for i, v in ipairs(tablee) do
		if i <= x * pr * y * pr then
			table.insert(new_table, v)
		end
	end

	return new_table
end

local function create_pixels() -- дает блокам положение X и Y
	local blocks = workspace.Blocks[player.Name]
	local main = block

	local temp = {}
	local temp1 = {}

	for i, v in ipairs(blocks:GetChildren()) do
		if v.Name == block_type then
			if tostring(player.Team) == "white" then
				table.insert(temp, {X = x - math.round(math.abs(main.PPart.Position.X - v.PPart.Position.X) * pr), Y = y - math.round(math.abs(main.PPart.Position.Y - v.PPart.Position.Y) * pr), part=v})
			else
				print(x - math.abs(main.PPart.Position.Z - v.PPart.Position.Z))
				table.insert(temp, {X = x - math.round(math.abs(main.PPart.Position.Z - v.PPart.Position.Z) * pr), Y = y - math.round(math.abs(main.PPart.Position.Y - v.PPart.Position.Y) * pr), part=v})
			end
		end
	end

	for i = #temp, 1, -1 do
		table.insert(temp1, temp[i])
	end

	return temp1
end

local function draw()
	for i = first_frame, last_frame do -- переносит переделанное видео в массив video
		local vid = Http:JSONDecode(game:HttpGet(url..'frame_'.. i ..'.json'))
		table.insert(video_pixels, {})
		for _, v in ipairs(pixels) do
			local index = (v['Y'] * x) + (v['X'] + 1)
			-- print(index, v['Y'], v['X'])
			if v['Y'] < y and v['X'] < x then
				table.insert(video_pixels[i - first_frame + 1], {v['part'], Color3.fromRGB(vid['pixels'][index]["c"]["r"], vid['pixels'][index]["c"]["g"], vid['pixels'][index]["c"]["b"])})
			end
		end

		-- print(i)
	end

	--for i = 1, data['frames'] do
	--	table.insert(video_pixels, {})
	--	for _, v in ipairs(pixels) do
	--		local index = (v['Y'] * x * pr) + (v['X'] + 1)
	--		print(index, v['Y'], v['X'], i, v)
	--		table.insert(video_pixels[i], {v['part'], Color3.fromRGB(vid['pixels'][index]["c"]["r"], vid['pixels'][index]["c"]["g"], vid['pixels'][index]["c"]["b"])})
	--	end
	--end

	for i, v in ipairs(video_pixels) do
		if not auto_start_draw then
			player.Character:WaitForChild("PaintingTool", 9999999999999) -- ожидает кисточку в руках
		end

		task.spawn(function()
			local fps_fix = DateTime.now().UnixTimestampMillis

			local args = {
				v
			}
			if auto_start_draw then
				if player.Character:FindFirstChild("PaintingTool") then
					player.Character:WaitForChild("PaintingTool").RF:InvokeServer(unpack(args))
				elseif player.Backpack:FindFirstChild("PaintingTool") then
					player.Backpack.PaintingTool:WaitForChild("RF"):InvokeServer(unpack(args))
				else
					print("AutoDraw broken! Equip Scaling Tool")
					player.Character:WaitForChild("PaintingTool", 99999999).RF:InvokeServer(unpack(args))
				end
			else
				player.Character:WaitForChild("PaintingTool", 9999999999999).RF:InvokeServer(unpack(args))
			end

			print((DateTime.now().UnixTimestampMillis - fps_fix) / 1000)
		end)
		-- для отладки, показывает задержку кадра (если время положитьельное будет фпс который указан, 
		-- минусовое значение показыват сколько времяни в секундах стоит кадр)

		wait(1 / fps) -- fps
	end
end

for i, v in ipairs(workspace.Blocks[player.Name]:GetChildren()) do
	block_type = v.Name
	block = v
	break
end

local AutoResize
AutoResize = workspace.Blocks[player.Name].ChildAdded:Connect(function(child) -- изменяет размер блоков
	local args = {
		child,
		vector.create(1 / pr, 1 / pr, 0.5),
		child:WaitForChild("PPart").CFrame
	}

	if player.Character:FindFirstChild("ScalingTool") then
		player.Character:WaitForChild("ScalingTool").RF:InvokeServer(unpack(args))
	elseif player.Backpack:FindFirstChild("ScalingTool") then
		player.Backpack.ScalingTool:WaitForChild("RF"):InvokeServer(unpack(args))
	else
		print("AutoResize broken! Equip Scaling Tool")
		player.Character:WaitForChild("ScalingTool", 99999999).RF:InvokeServer(unpack(args))
	end

	ResizeCounter += 1

	-- print(ResizeCounter, x * pr * y * pr) для отладки

	if ResizeCounter >= x * y - 1 then
		ResizeCounter = 0
		AutoResize:Disconnect()

		-- print('generation =', os.time() - start, 'seconds')

		wait(2.5)

		pixels = clear_table(create_pixels(clear_table(pixels)))
		pixels[x * y + 1] = nil
		print(pixels[144]['Y'], pixels[144]['X'])

		draw()
	end
end)

for i = 1, x do
	for j = 1, y do
		task.spawn(function() -- генерация блоков
			local args = {
				block_type,
				getBlockCount(block_type),
				block:WaitForChild("PPart"),
				CFrame.new(i / pr, j / pr, -1.100006103515625, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				true,
				CFrame.new(0, 0, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
				false
			}
			player.Backpack.BuildingTool.RF:InvokeServer(unpack(args))
			countt += 1

			print(countt)
		end)
	end
end
