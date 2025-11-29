from flask import Flask, request, render_template
import pickle
import numpy as np
import time

app = Flask(__name__)


weather_classes = ['clear', 'cloudy', 'drizzly', 'foggy', 'hazey', 'misty', 'rain', 'smokey', 'thunderstorm']


def load_model(model_path='model/model.pkl'):
    # Fixed: Added because the opened file was not being closed by pickle
    with open(model_path, 'rb') as f:
        return pickle.load(f)


def classify_weather(features):
    model = load_model()
    start = time.time()
    prediction_index = model.predict(features)[0]
    latency = round((time.time() - start) * 1000, 2)  # we are here
    # Fixed the prediction index error
    indx = int(prediction_index)
    prediction = weather_classes[indx]
    return prediction, latency


@app.route('/', methods=['GET', 'POST'])
def home():
    if request.method == 'POST':
        try:
            temperature = request.form.get('temperature')
            pressure = request.form.get('pressure')
            humidity = request.form.get('humidity')
            wind_speed = request.form.get('wind_speed')
            wind_deg = request.form.get('wind_deg')
            # Fixed:  Check if all the required fields are passed
            if temperature is None:
                return render_template('form.html', error="Pressure cannot be None")
            if pressure is None:
                return render_template('form.html', error="Temperature cannot be None")
            if humidity is None:
                return render_template('form.html', error="Humidity cannot be None")
            if wind_speed is None:
                return render_template('form.html', error="Wind speed cannot be None")
            if wind_deg is None:
                return render_template('form.html', error="Wind degree cannot be None")
            # Extract floats from form data
            # Fixed: numpy issue by converting inputs to floats from string since np does not mix types
            temperature = float(temperature)
            pressure = float(pressure)
            humidity = float(humidity)
            wind_speed = float(wind_speed)
            wind_deg = float(wind_deg)
            rain_1h = float(request.form.get('rain_1h', 0) or 0)
            rain_3h = float(request.form.get('rain_3h', 0) or 0)
            snow = float(request.form.get('snow', 0) or 0)
            clouds = float(request.form.get('clouds', 0) or 0)

            features = np.array([
                temperature, pressure, humidity,
                wind_speed, wind_deg, rain_1h,
                rain_3h, snow, clouds
            ]).reshape(1, -1)

            prediction, latency = classify_weather(features)

            return render_template('result.html', prediction=prediction, latency=latency)

        except Exception as e:
            error_msg = f"Error processing input: {e}"
            return render_template('form.html', error=error_msg)
    # GET method: show the input form
    return render_template('form.html')


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)
