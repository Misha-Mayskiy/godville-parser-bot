FROM mcr.microsoft.com/playwright/python:v1.55.0-jammy

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

RUN mkdir -p /app/data && chown -R pwuser:pwuser /app

USER pwuser

ENV PYTHONUNBUFFERED=1

CMD ["python", "app.py"]