import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "src"))
import todo  # noqa: E402


class TodoTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        todo.DB = Path(self.tmp.name) / "todos.json"

    def tearDown(self):
        self.tmp.cleanup()

    def test_add(self):
        todo.add("写报告")
        self.assertEqual(todo.load()[0]["title"], "写报告")

    def test_done(self):
        todo.add("写报告")
        todo.done(1)
        self.assertTrue(todo.load()[0]["done"])


if __name__ == "__main__":
    unittest.main()
