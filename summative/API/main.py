from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel, Field, ValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exception_handlers import RequestValidationError
from fastapi.responses import JSONResponse
import joblib
import uvicorn

# Initialize FastAPI app
app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins, customize as needed
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the trained model
model = joblib.load("linear_model.pkl")  

# Define Pydantic model for input validation
class PredictionRequest(BaseModel):
    monthly_grocery_bill: float = Field(..., gt=0, description="Monthly grocery bill in dollars")
    vehicle_monthly_distance_km: float = Field(..., gt=0, description="Vehicle monthly distance in kilometers")
    waste_bag_weekly_count: int = Field(..., ge=0, description="Number of waste bags per week")
    how_long_tv_pc_daily_hour: float = Field(
        ..., ge=0, le=24, description="Hours spent on TV/PC daily"
    )
    how_many_new_clothes_monthly: int = Field(..., ge=0, description="Number of new clothes purchased monthly")
    how_long_internet_daily_hour: float = Field(
        ..., ge=0, le=24, description="Hours spent on the internet daily"
    )

# Define a POST endpoint for predictions
@app.post("/predict/")
async def predict(data: PredictionRequest):
    try:
        # Extract input features
        input_features = [
            [
                data.monthly_grocery_bill,
                data.vehicle_monthly_distance_km,
                data.waste_bag_weekly_count,
                data.how_long_tv_pc_daily_hour,
                data.how_many_new_clothes_monthly,
                data.how_long_internet_daily_hour,
            ]
        ]
        
        # Make prediction
        prediction = model.predict(input_features)
        return {"predicted_carbon_emission": prediction[0]}
    
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Root endpoint
@app.get("/")
async def root():
    return {"message": "Welcome to the Carbon Emission Prediction API!"}

# Custom error handler for validation errors
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = exc.errors()
    friendly_errors = [
        f"Invalid value for '{err['loc'][-1]}': {err['msg']} (Your input: {err.get('input')})"
        for err in errors
    ]
    return JSONResponse(
        status_code=422,
        content={"errors": friendly_errors},
    )

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

