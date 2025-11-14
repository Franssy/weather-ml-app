import unittest, re
from app import app


class TestAppSmoke(unittest.TestCase):
    def setUp(self):
        app.testing = True
        self.client = app.test_client()

    # Complete the function below to test a success in running the application
    def test_prediction_route_success(self):
        response = self.client.get('/')
        self.assertEqual(response.status_code, 200, "Expected route '/' to return 200 OK")


    # Complete the function below to test a form is rendered
    def test_get_form(self):
        response = self.client.get('/')
        html = response.data.decode('utf-8').lower()
        pattern = "<form [a-z=\" /]*>"
        match = re.search(pattern, html)
        self.assertTrue(match is not  None, "Expected an HTML form to be rendered on the main page")
        self.assertIn('type="submit"', html, "Form should have a submit button")


if __name__ == '__main__':
    unittest.main()
