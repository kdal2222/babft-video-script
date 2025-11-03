from PIL import Image
import os
import json

def gif_to_json_frames(gif_path, output_dir="frames", max_size=None):
    os.makedirs(output_dir, exist_ok=True)
    gif = Image.open(gif_path)

    frame_index = 0
    while True:
        # Извлекаем кадр
        frame = gif.convert("RGB")

        # (Необязательно) уменьшаем размер
        if max_size:
            frame.thumbnail(max_size)

        width, height = frame.size
        pixels = []

        # Считываем пиксели
        for y in range(height):
            for x in range(width):
                r, g, b = frame.getpixel((x, y))
                pixels.append({
                    "x": x,
                    "y": y,
                    "c": {"r": r, "g": g, "b": b}
                })

        data = {
            "height": height,
            "width": width,
            "pixels": pixels
        }

        # Пути сохранения
        json_path = os.path.join(output_dir, f"frame_{frame_index}.json")
        # image_path = os.path.join(output_dir, f"frame_{frame_index:03d}.png")

        # Сохраняем PNG и JSON
        # frame.save(image_path)
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False)

        print(f"✅ Сохранён кадр {frame_index} ({width}x{height})")

        frame_index += 1

        # Переходим к следующему кадру
        try:
            gif.seek(gif.tell() + 1)
        except EOFError:
            break

    json_path = os.path.join(output_dir, f"config.json")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump({"x": width, "y": height, "frames": frame_index - 1}, f, ensure_ascii=False)
    print(f"🎬 Всего кадров: {frame_index}")

def image_to_json(image_path, output_path=None, max_size=None):
    # Загружаем изображение
    img = Image.open(image_path).convert("RGB")

    # (Необязательно) уменьшаем размер для снижения объема JSON
    if max_size:
        img.thumbnail(max_size)

    width, height = img.size
    pixels = []

    # Считываем каждый пиксель
    for y in range(height):
        for x in range(width):
            r, g, b = img.getpixel((x, y))
            pixels.append({
                "x": x,
                "y": y,
                "c": {"r": r, "g": g, "b": b}
            })

    # Формируем JSON-структуру
    data = {
        "height": height,
        "width": width,
        "pixels": pixels
    }

    json_data = json.dumps(data, ensure_ascii=False)

    # Сохраняем или возвращаем результат
    if output_path:
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(json_data)
    else:
        return json_data


# Пример использования:
gif_to_json_frames("badaple.gif", "frames_json", max_size=(64, 2000))
# image_to_json("z.png", "frames_json/z.json")
