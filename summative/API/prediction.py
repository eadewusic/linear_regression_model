import joblib
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from flask import Flask, request, jsonify

# Load the saved model
model = joblib.load('random_forest_model.pkl')

# Initialize Flask app
app = Flask(__name__)

# Define numerical and categorical columns
numerical_cols = ['Monthly Grocery Bill', 'Vehicle Monthly Distance Km', 'Waste Bag Weekly Count', 'How Long TV PC Daily Hour', 'How Many New Clothes Monthly', 'How Long Internet Daily Hour']
categorical_cols = ['Body Type', 'Sex', 'Diet', 'How Often Shower', 'Heating Energy Source', 'Transport', 'Vehicle Type', 'Social Activity', 'Frequency of Traveling by Air', 'Waste Bag Size', 'Energy efficiency', 'Recycling', 'Cooking_With']

# Preprocessing pipeline
preprocessor = ColumnTransformer(
    transformers=[
        ('num', StandardScaler(), numerical_cols),  # Scale numerical features
        ('cat', OneHotEncoder(drop='first'), categorical_cols)  # One-hot encode categorical features
    ])

# Define a prediction function
def predict_carbon_emission(input_data):
    # Apply the preprocessing
    input_df = pd.DataFrame([input_data], columns=numerical_cols + categorical_cols)
    processed_input = preprocessor.fit_transform(input_df)

    # Make a prediction using the loaded model
    prediction = model.predict(processed_input)
    return prediction[0]

# Define an API route for prediction
@app.route('/predict', methods=['POST'])
def predict():
    # Get the JSON data from the request
    data = request.get_json()

    # Extract the input features from the JSON data
    input_data = data['features']

    # Get the prediction
    prediction = predict_carbon_emission(input_data)

    # Return the prediction as a JSON response
    return jsonify({"predicted_carbon_emission": prediction})

# Run the Flask app
if __name__ == '__main__':
    app.run(debug=True)
