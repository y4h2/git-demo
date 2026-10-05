#!/usr/bin/env bash
# 在空仓库里构造一段演示用的提交历史和分支。
# 结果：
#   main                  —— 3 个提交（初始化 → 加测试 → 改 README）
#   feature/delete        —— 新增 delete 命令（可演示 merge / rebase）
#   feature/priority      —— 和 main 改了同一行（可演示 merge 冲突）
#   tag v0.1.0            —— 打在第一个提交上
set -euo pipefail
cd "$(dirname "$0")/.."

if git rev-parse --verify -q HEAD >/dev/null; then
  echo "仓库已有提交，跳过（只在空仓库上运行）"; exit 1
fi

# 1. 初始提交
git add .gitignore README.md src/todo.py docs/CHANGELOG.md scripts/
git commit -qm "feat: 初始化 todo CLI（add/list/done）"
git tag v0.1.0

# 2. 加测试
git add tests/
git commit -qm "test: 增加 add/done 单元测试"

# 3. feature/delete 分支：新增 delete 命令
git switch -qc feature/delete
python3 - <<'PY'
from pathlib import Path
p = Path("src/todo.py"); s = p.read_text(encoding="utf-8")
s = s.replace('''def main(argv):''', '''def delete(todo_id):
    save([t for t in load() if t["id"] != todo_id])
    print(f"已删除：{todo_id}")


def main(argv):''')
s = s.replace('''    elif cmd == "done":
        done(int(argv[2]))''', '''    elif cmd == "done":
        done(int(argv[2]))
    elif cmd == "delete":
        delete(int(argv[2]))''')
s = s.replace("[add <标题> | list | done <id>]", "[add <标题> | list | done <id> | delete <id>]")
p.write_text(s, encoding="utf-8")
PY
git commit -qam "feat: 新增 delete 命令"
printf '\n## 未发布\n- 新增 delete 命令\n' >> docs/CHANGELOG.md
git commit -qam "docs: 更新 CHANGELOG"

# 4. 回到 main，改 README 第一行（为冲突埋伏笔）
git switch -q main
sed -i '' '1s/.*/# Todo CLI —— 极简待办工具/' README.md
git commit -qam "docs: 调整 README 标题"

# 5. feature/priority 分支：从 main 的上一个提交拉出，改同一行 → 合并时冲突
git switch -qc feature/priority HEAD~1
sed -i '' '1s/.*/# Todo CLI（支持优先级）/' README.md
git commit -qam "docs: README 标题标注优先级功能"

git switch -q main
echo "✅ 演示历史已构造完成："
git log --oneline --graph --all --decorate
