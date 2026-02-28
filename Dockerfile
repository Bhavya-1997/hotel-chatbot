FROM rasa/rasa:3.6.4-full

USER root

# Install curl (for health checks) and Flask dependencies
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Flask and gunicorn (Rasa + TensorFlow already in base image)
RUN pip install flask==2.3.3 gunicorn==21.2.0 werkzeug==3.1.3

# Copy ONLY training-related files first.
# Docker caches each layer — rasa train only re-runs if these files change.
COPY data/ /app/data/
COPY actions/ /app/actions/
COPY config.yml /app/config.yml
COPY domain.yml /app/domain.yml

# Train the model (cached by Docker unless training files above change)
RUN cd /app && rasa train --out /app/models/

# Copy remaining files separately — changes here (e.g. app.py) won't trigger re-training
COPY app.py endpoints.yml credentials.yml start.sh /app/
COPY templates/ /app/templates/

RUN chmod +x /app/start.sh

# Override the rasa base image entrypoint so we can run our own startup script
ENTRYPOINT []

# Hugging Face Spaces requires port 7860
EXPOSE 7860

CMD ["/bin/bash", "/app/start.sh"]
