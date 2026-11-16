import unittest
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from main import app


class TestAPI(unittest.TestCase):

    def setUp(self):
        self.client = app.test_client()

    def test_inicio(self):
        respuesta = self.client.get("/")

        self.assertEqual(respuesta.status_code, 200)
        self.assertEqual(
            respuesta.get_json()["mensaje"],
            "Hola desde DevOps Educomser"
        )

    def test_health(self):
        respuesta = self.client.get("/health")

        self.assertEqual(respuesta.status_code, 200)
        self.assertEqual(
            respuesta.get_json()["status"],
            "ok"
        )

if __name__ == "__main__":
    unittest.main()
