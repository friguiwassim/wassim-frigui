# Étape 1: Build
FROM python:3.9-slim as builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Étape 2: Runtime
FROM python:3.9-slim

WORKDIR /app

# Copier les packages depuis le builder
COPY --from=builder /root/.local /root/.local
COPY . .

# Ajouter .local/bin au PATH
ENV PATH=/root/.local/bin:$PATH

# Variables d'environnement
ENV FLASK_APP=app.py
ENV BUILD_DATE=${BUILD_DATE}
ENV BUILD_ID=${BUILD_ID}

# Exposer le port
EXPOSE 5000

# Commande de démarrage
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
