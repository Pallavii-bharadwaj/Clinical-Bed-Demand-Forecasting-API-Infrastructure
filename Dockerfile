FROM python:3.11-slim

# Keep Python output unbuffered and skip .pyc files
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# Install dependencies first so this layer is cached when only code changes
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project
COPY . .

# Train the model at build time so model.pkl exists inside the image.
# main.py loads model.pkl at startup, so it must be present before the server runs.
RUN python train_model.py

# The API listens on 8000
EXPOSE 8000

# Start the FastAPI service
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
