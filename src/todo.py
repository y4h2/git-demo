"""极简待办事项 CLI。"""
import json
import sys
from pathlib import Path

DB = Path("todos.json")


def load():
    if DB.exists():
        return json.loads(DB.read_text(encoding="utf-8"))
    return []


def save(todos):
    DB.write_text(json.dumps(todos, ensure_ascii=False, indent=2), encoding="utf-8")


def add(title):
    todos = load()
    todos.append({"id": len(todos) + 1, "title": title, "done": False})
    save(todos)
    print(f"已添加：{title}")


def list_todos():
    for t in load():
        mark = "x" if t["done"] else " "
        print(f"[{mark}] {t['id']}. {t['title']}")


def done(todo_id):
    todos = load()
    for t in todos:
        if t["id"] == todo_id:
            t["done"] = True
    save(todos)


def main(argv):
    if len(argv) < 2:
        print("用法: todo.py [add <标题> | list | done <id>]")
        return
    cmd = argv[1]
    if cmd == "add":
        add(" ".join(argv[2:]))
    elif cmd == "list":
        list_todos()
    elif cmd == "done":
        done(int(argv[2]))
    else:
        print(f"未知命令: {cmd}")


if __name__ == "__main__":
    main(sys.argv)
