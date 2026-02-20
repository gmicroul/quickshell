#!/usr/bin/env python3
import json
import os

# 配置路径
OBSIDIAN_MD = "/home/archirithm/Documents/Obsidian Vault/kebiao.md"
CACHE_DIR = os.path.expanduser("~/.cache/quickshell")
CACHE_FILE = os.path.join(CACHE_DIR, "schedule.json")


def parse_markdown():
    if not os.path.exists(OBSIDIAN_MD):
        print(f"找不到 Obsidian 课表文件: {OBSIDIAN_MD}")
        return None

    with open(OBSIDIAN_MD, "r", encoding="utf-8") as f:
        lines = f.readlines()

    grid = []
    for line in lines:
        line = line.strip()
        if not line.startswith("|"):
            continue
        if line.startswith("|"):
            line = line[1:]
        if line.endswith("|"):
            line = line[:-1]
        cols = [col.strip().replace("**", "") for col in line.split("|")]
        grid.append(cols)

    if len(grid) < 3:
        return None

    body = grid[2:]
    rows = len(body)
    cols = len(body[0]) if rows > 0 else 0

    time_headers = []
    parsed_items = []

    # ==========================================
    # 核心：全局课程 ID 发号器
    # ==========================================
    course_color_map = {}
    next_color_id = 0

    skip = [[False] * cols for _ in range(rows)]

    # 提取左侧时间段
    for r in range(rows):
        if len(body[r]) > 0:
            time_headers.append(body[r][0])

    # 遍历核心网格
    for c in range(1, cols):
        for r in range(rows):
            if skip[r][c]:
                continue

            text = body[r][c] if c < len(body[r]) else ""
            row_span = 1

            if text != "":
                # 纵向合并逻辑
                while (
                    r + row_span < rows
                    and c < len(body[r + row_span])
                    and body[r + row_span][c] == text
                ):
                    skip[r + row_span][c] = True
                    row_span += 1

                # 给新课程发号
                if text not in course_color_map:
                    course_color_map[text] = next_color_id
                    next_color_id += 1

            parsed_items.append(
                {
                    "row": r,
                    "col": c - 1,
                    "rowSpan": row_span,
                    "text": text,
                    "isEmpty": (text == ""),
                    "colorId": course_color_map.get(text, 0),  # 写入分配好的纯净 ID
                }
            )

    return {"timeHeaders": time_headers, "scheduleItems": parsed_items}


def main():
    os.makedirs(CACHE_DIR, exist_ok=True)
    data = parse_markdown()

    if data:
        # 去掉 indent=2，生成紧凑的单行 JSON，绝对不会触发 QML 的 Parse Error
        with open(CACHE_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False)
        print(f"✅ 课表解析成功！JSON 已保存至: {CACHE_FILE}")
    else:
        print("❌ 解析失败，请检查 Markdown 格式。")


if __name__ == "__main__":
    main()
