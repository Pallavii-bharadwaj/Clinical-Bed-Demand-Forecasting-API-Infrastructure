# Clinical Bed Demand Forecasting API & Infrastructure

A Ridge Regression REST API that predicts 30-day hospital bed occupancy from patient clinical features, trained on real MSc coursework data and deployed to **AWS EC2 (London region)** with a **GitHub Actions CI/CD pipeline** that runs on every push.

https://github.com/Pallavii-bharadwaj/Clinical-Bed-Demand-Forecasting-API-Infrastructure/actions/workflows/deploy.yml/badge.svg

## Status

The API is packaged to deploy to AWS EC2 (eu-west-2) and run as a FastAPI service on port 8000. The EC2 instance is spun up on demand rather than left running continuously, so the public endpoint is not always live. The GitHub Actions pipeline runs on every push and is the standing proof that the service builds, trains, starts, and passes its health check.

## Endpoints

| Endpoint   | Method | Description                                     |
| ---------- | ------ | ----------------------------------------------- |
| `/health`  | GET    | Health check, confirms the service is running   |
| `/predict` | POST   | Returns predicted bed-days for a patient record |
| `/docs`    | GET    | Auto-generated interactive API documentation    |

Example request against a running instance:

```
curl -X POST http://<instance-host>:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"age":73,"cci":2,"los_index":5,"prior_adm_12m":2,"crp":36.2,"creatinine":163.1,"has_carer":1,"imd":4,"site":0}'
```

---

## Model

Trained on 2,400 real patient records from MSc Data Science coursework (University of York, DEEP Q1).

**Features:** age, Charlson Comorbidity Index (cci), length-of-stay index, prior admissions (12m), CRP, creatinine, carer status, IMD deprivation decile, hospital site.

**Pipeline:**

- `ColumnTransformer`: StandardScaler on numeric features, OneHotEncoder on categorical
- Benchmarked OLS, Ridge, Lasso, ElasticNet with repeated 5-fold cross-validation
- `GridSearchCV` hyperparameter tuning across all models
- Ridge automatically selected (lowest CV RMSE)

**Results:**

| Metric    | Value                            |
| --------- | -------------------------------- |
| CV RMSE   | 1.52 bed-days                    |
| Test RMSE | 1.50 bed-days                    |
| Test R²   | 0.678 (67.8% variance explained) |

---

## Architecture

```
GitHub (push to main)
       │
       ▼
GitHub Actions CI/CD
  ├── Install dependencies
  ├── Train model (train_model.py)
  ├── Start FastAPI server
  └── Test /health endpoint
       │
       ▼
AWS EC2 t3.micro (eu-west-2, London)
  └── FastAPI + Uvicorn (port 8000)
        ├── GET  /health
        └── POST /predict
```

---

## Stack

- **Cloud:** AWS EC2 t3.micro, eu-west-2 (London)
- **API:** Python, FastAPI, Uvicorn
- **ML:** Scikit-learn, Pandas, NumPy, Joblib
- **CI/CD:** GitHub Actions (auto-runs on every push to main)
- **OS:** Amazon Linux 2023

---

## Run Locally

```
# Clone the repo
git clone https://github.com/pallavii-bharadwaj/Clinical-Bed-Demand-Forecasting-API-Infrastructure.git
cd Clinical-Bed-Demand-Forecasting-API-Infrastructure

# Install dependencies
pip install -r requirements.txt

# Train the model
python3 train_model.py

# Start the API
uvicorn main:app --host 0.0.0.0 --port 8000
```

Then open `http://localhost:8000/docs` for the interactive API docs.

---

## CI/CD Pipeline

Every push to `main` triggers the GitHub Actions workflow (`.github/workflows/deploy.yml`) which:

1. Sets up Python 3.11
2. Installs all dependencies
3. Trains the Ridge Regression model
4. Starts the FastAPI server
5. Tests the `/health` endpoint with `curl`

If any step fails, the pipeline reports a failure, keeping the main branch always deployable.

---

## Project Structure

```
Clinical-Bed-Demand-Forecasting-API-Infrastructure/
├── train_model.py                  # trains, selects, and saves the model
├── main.py                         # FastAPI service
├── hospital_bed_days_regression_data.csv
├── requirements.txt
└── .github/
    └── workflows/
        └── deploy.yml              # CI/CD pipeline
```

---

*Model trained on anonymised clinical coursework data. MSc Data Science, University of York, 2025 to 2026.*
