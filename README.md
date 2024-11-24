# Summative Assignment: Linear Regression and API Deployment

This repository contains all components of the summative assignment for **BSE Machine Learning and Mathematics for Machine Learning**. The project addresses a specific use case with linear regression and includes a comparison with other machine learning models, API deployment, and a Flutter-based mobile app for predictions.

## My Mission and Use Case

### Mission:  
To empower young women in STEAM (Science, Technology, Engineering, Arts, and Mathematics) fields, foster DEI (Diversity, Equity, and Inclusion), and drive environmental sustainability for a better future.

### Use Case:  
The project aims to predict an individual's carbon footprint based on their daily habits, such as electronic usage, meal consumption, transportation, grocery expenditure, and clothing purchases. This use case is **unique and specific**, aligning with my mission to drive environmental sustainability for a better future.

---

## Dataset

### Description:
- **Dataset**: The dataset contains variables representing daily habits and corresponding carbon footprint. Variables include:
  - **Electronic devices owned** (integer)
  - **Screen time (hours/day)** (float)
  - **Monthly grocery bill** (float, in USD)
  - **Monthly transportation expenditure** (float, in USD)
  - **New clothes bought monthly** (integer)
  - **Meals consumed weekly** (integer)

- **Source**: Retrieved from [Kaggle](https://kaggle.com), titled *Daily Habits and Carbon Footprint Dataset*.
- **Dataset Link**: https://www.kaggle.com/datasets/dumanmesut/individual-carbon-footprint-calculation

### Key Visualizations:
1. **Correlation Heatmap**: Shows relationships among variables.
2. **Variable Distribution**: Histograms for each feature to understand spread and outliers.

## Task Details

### Task 1: Linear Regression Implementation
1. Implemented **Linear Regression**, **Decision Trees**, and **Random Forest** models.
2. Optimized Linear Regression using **Gradient Descent**.
3. Evaluated all models using metrics such as **Mean Squared Error (MSE)** and **R²** score.
4. Saved the best-performing model (Random Forest) as `model.pkl`.

### Task 2: API Development
1. Developed a FastAPI-based **prediction API** with:
   - **POST endpoint**: `/predict`
   - **Pydantic validation**: Ensures proper input types and ranges.
   - **CORS middleware**: For cross-origin access.
2. Hosted the API on **Render** with Swagger UI available at:
   - **[Public Swagger URL](https://linear-regression-model-pjjl.onrender.com//docs)**

### Task 3: Flutter Mobile App
1. Developed a mobile app with Flutter to interact with the API.
   - **Input Fields**: Text boxes for all input variables.
   - **Button**: "Predict" button to send data to the API.
   - **Output Display**: Shows predicted carbon footprint or error messages.
2. The app fetches predictions using the deployed API.

### Task 4: Video Demo
- **YouTube Demo**: A 2-minute video showcasing:
  - API functionality via Swagger UI.
  - Mobile app making predictions using the API.
- [Video Link](https://youtu.be/0cbiCNLjREA)

---

## How to Run the Project

### Step 1: Linear Regression Model
1. Clone the repository.
2. Navigate to the `summative/linear_regression/` directory.
3. Open `multivariate.ipynb` and run all cells in a Jupyter Notebook environment.

### Step 2: API Deployment
1. Navigate to `summative/API/` directory.
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Run the API locally for testing:
   ```bash
   uvicorn prediction:app --reload
   ```
4. Access Swagger UI at `http://127.0.0.1:8000/docs` or use the **[deployed API link](https://linear-regression-model-pjjl.onrender.com//docs)**.

### Step 3: Flutter Mobile App
1. Navigate to `summative/FlutterApp/`.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```
4. Ensure the app connects to the API via the provided endpoint.

---

## Evaluation Metrics

### Linear Regression Model
- **Mean Squared Error (MSE)**: Evaluated on test data.
- **R² Score**: Indicates goodness-of-fit.

### API
- Validated inputs using Pydantic models.
- Implemented error handling for invalid input ranges.

### Mobile App
- Tested with multiple scenarios for prediction and error handling.
- Ensured seamless communication with the deployed API.

## Demo Links
1. **Swagger UI**: [https://linear-regression-model-pjjl.onrender.com/docs](https://linear-regression-model-pjjl.onrender.com/docs)
2. **YouTube Video**: [https://youtu.be/0cbiCNLjREA](https://youtu.be/0cbiCNLjREA)
