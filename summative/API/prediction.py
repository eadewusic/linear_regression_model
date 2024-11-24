from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
import joblib
import pandas as pd
import numpy as np
from fastapi.middleware.cors import CORSMiddleware

# Load the pre-trained model (Random Forest in this case)
model = joblib.load('random_forest_model.pkl')  # Ensure this path is correct to where the model is stored

# Initialize FastAPI app
app = FastAPI()

# Allow CORS for all origins (change according to your security requirements)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods
    allow_headers=["*"],  # Allow all headers
)

# Define input data model using Pydantic
class PredictionRequest(BaseModel):
    Monthly_Grocery_Bill: float = Field(..., ge=0, le=10000)  # Example constraint: 0 <= value <= 10000
    Vehicle_Monthly_Distance_Km: float = Field(..., ge=0, le=20000)  # Example constraint: 0 <= value <= 20000
    Waste_Bag_Weekly_Count: int = Field(..., ge=0, le=7)  # Example constraint: 0 <= value <= 7
    How_Long_TV_PC_Daily_Hour: float = Field(..., ge=0, le=24)  # Example constraint: 0 <= value <= 24
    How_Many_New_Clothes_Monthly: int = Field(..., ge=0, le=50)  # Example constraint: 0 <= value <= 50
    How_Long_Internet_Daily_Hour: float = Field(..., ge=0, le=24)  # Example constraint: 0 <= value <= 24

# Define preprocessing pipeline
numerical_cols = ['Monthly_Grocery_Bill', 'Vehicle_Monthly_Distance_Km', 'Waste_Bag_Weekly_Count', 'How_Long_TV_PC_Daily_Hour', 'How_Many_New_Clothes_Monthly', 'How_Long_Internet_Daily_Hour']
categorical_cols = []  # Add categorical columns if necessary

preprocessor = ColumnTransformer(
    transformers=[
        ('num', StandardScaler(), numerical_cols),  # Scale numerical features
        ('cat', OneHotEncoder(drop='first'), categorical_cols)  # One-hot encode categorical features (if any)
    ])

# Function to make predictions
def make_prediction(input_data: PredictionRequest):
    # Convert the input data to a DataFrame
    input_df = pd.DataFrame([input_data.dict()])
    
    # Apply the preprocessing
    processed_input = preprocessor.fit_transform(input_df)
    
    # Make the prediction
    prediction = model.predict(processed_input)
    return prediction[0]

# API endpoint to make a prediction
@app.post("/predict")
def predict(input_data: PredictionRequest):
    try:
        # Call the prediction function
        prediction = make_prediction(input_data)
        
        return {"predicted_carbon_emission": prediction}
    
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Run the app using Uvicorn (use this command in terminal to start the app)
# uvicorn prediction:app --reload