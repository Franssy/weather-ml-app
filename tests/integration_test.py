import unittest, re
from app import app  # Import your Flask app instance


class TestModelAppIntegration(unittest.TestCase):

    def setUp(self):
        app.testing = True
        self.client = app.test_client()

    def test_model_app_integration(self):
        # Valid test input that should work with the trained model
        form_data = {
            'temperature': '275.15',  # Kelvin
            'pressure': '1013',  # hPa
            'humidity': '85',  # %
            'wind_speed': '3.6',  # m/s
            'wind_deg': '180',  # degrees
            'rain_1h': '0',  # mm
            'rain_3h': '0',  # mm
            'snow': '0',  # mm
            'clouds': '20'  # %
        }

        response = self.client.post('/', data=form_data)

        html_text = response.data.decode('utf-8').lower()
        # Complete below
        # Ensure that the result page (response.data) should include a weather prediction
        self.assertTrue(response.status_code == 200, "Request was successful")
        pattern = "<p><strong>the weather is:</strong>"
        self.assertIn(pattern, html_text, "Weather was not found in HTML")
        match = re.search(pattern, html_text)
        self.assertTrue(match is not None, "Weather was not found in HTML")
        # Ensure that the result page should include a prediction time
        pattern = "<p><strong>prediction time:</strong>"
        self.assertIn(pattern, html_text, "Prediction was not found in HTML")
        match = re.search(pattern, html_text)
        self.assertTrue(match is not None, "Prediction was not found in HTML")

        valid_classes = [
            'clear', 'cloudy', 'drizzly', 'foggy', 'hazey',
            'misty', 'rainy', 'smokey', 'thunderstorm'
        ]
        found = any(weather in html_text for weather in valid_classes)

        # Ensure that classification is in valid classes, provide an error message if not.
        self.assertTrue(found, f"Expected one of {valid_classes} in response, but got:\n{html_text}")

if __name__ == '__main__':
    unittest.main()