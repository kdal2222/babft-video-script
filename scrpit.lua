# скрипт от rd450x
# прога на конвертацию видео/фото в код для скрипта: https://github.com/kdal2222/babft-video-script/blob/main/convert.py
# минимальное количество пластика: x * y
# картника или видео строятся от блока дерева (видео идет вврх и влево от блока)
# перед запуском скрипта не должны стоять блоки пластика и должен стоять 1 блок дерева

local Players = game:GetService("Players")
local Http = game:GetService("HttpService")

local player = Players.LocalPlayer

local ResizeCounter = 0

print('running')

# НАСТРОЙКИ

local x = 64 # Ширина видео/фото
local y = 21 # Высота видео/фото
local pr = 1 # плотность пикселей на блок (сломано, значение не менять)
local fps = 10
local url = "https://raw.githubusercontent.com/kdal2222/babft-video-script/refs/heads/main/BADAPPLE64X21/" # ссылка на видео / фото
local frames = 3285 # количество кадров в видео (ставь 0 если фото)
local plastic_count = 22500 # количество блоков пластика в инвенторе

# КОНЕЦ НАСТРОЕК

local pixels = {}
local video = {}

for i = 0, frames do # переносит переделанное видео в массив video
	table.insert(video, Http:JSONDecode(url..frame_'.. i ..'.json')))
	print(i)
end

local start = os.time() # запускает таймер (необязателен)

local function clear_table(tablee) # фиксит список pixels (мб не нужно)
	local new_table = {}
	for i, v in ipairs(tablee) do
		if i <= x * pr * y * pr then
			table.insert(new_table, v)
		end
	end

	return new_table
end

local function create_pixels() # дает блокам положение X и Y
	local blocks = workspace.Blocks[player.Name]
	local main = blocks.WoodBlock

	local temp = {}
	local temp1 = {}

	for i, v in ipairs(blocks:GetChildren()) do
		if v.Name == "PlasticBlock" then
			table.insert(temp, {X = x - math.abs(main.PPart.Position.Z - v.PPart.Position.Z), Y = y - math.abs(main.PPart.Position.Y - v.PPart.Position.Y), part=v})
		end
	end

	for i = #temp, 1, -1 do
		table.insert(temp1, temp[i])
	end

	return temp1
end

local AutoResize
AutoResize = workspace.Blocks[player.Name].ChildAdded:Connect(function(child) # изменяет размер блоков
	local args = {
		child,
		vector.create(1 / pr, 1 / pr, 0.5),
		child:WaitForChild("PPart").CFrame
	}
	player.Character:WaitForChild("ScalingTool").RF:InvokeServer(unpack(args))
	ResizeCounter += 1
	
	# print(ResizeCounter, x * pr * y * pr) для отладки

	if ResizeCounter >= x * pr * y * pr - 1 then
		ResizeCounter = 0
		AutoResize:Disconnect()

		print('generation =', os.time() - start, 'seconds')

		wait(2)

		pixels = create_pixels(clear_table(pixels))

		for i, _ in ipairs(video) do
			local counter = 0
			local fps_fix = DateTime.now().UnixTimestampMillis
			
			local frame_done = false
			
			for _, v in ipairs(pixels) do
				player.Character:WaitForChild("PaintingTool", 9999999999999) # ожидает кисточку в руках
				local index = (v['Y'] * x * pr) + (v['X'] + 1) # вычисляет индекс в списке video по X и Y
				task.spawn(function()
					local args = {
						{
							{
								v['part'],
								Color3.fromRGB(video[i]['pixels'][index]["c"]["r"], video[i]['pixels'][index]["c"]["g"], video[i]['pixels'][index]["c"]["b"])
							}
						}
					}
					player.Character:WaitForChild("PaintingTool", 9999999999999).RF:InvokeServer(unpack(args))
					counter += 1
					
					if counter >= x * pr * y * pr then
						frame_done = true
					end
				end)
			end
			
			repeat
				wait()
			until frame_done
			
			# print(1 / fps - ((DateTime.now().UnixTimestampMillis - fps_fix) / 1000)) для отладки, показывает задержку кадра (если время положитьельное будет фпс который указан, 
			# минусовое значение показыват сколько времяни в секундах стоит кадр)

			wait(1 / fps - ((DateTime.now().UnixTimestampMillis - fps_fix) / 1000)) # fps
		end
	end
end)

local countt = 0

for i = 1, x, 1 / pr do
	for j = 1, y, 1 / pr do
		task.spawn(function() # генерация блоков
			local args = {
				"PlasticBlock",
				plastic_count,
				workspace:WaitForChild("Blocks"):WaitForChild(player.Name):WaitForChild("WoodBlock"):WaitForChild("PPart"),
				CFrame.new(i, j, -1.100006103515625, 1, 0, 0, 0, 1, 0, 0, 0, 1),
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
