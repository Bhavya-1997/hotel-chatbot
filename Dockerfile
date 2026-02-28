FROM rasa/rasa:3.6.4-full

USER root

# Install curl (for health checks) and Flask dependencies
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Flask and gunicorn (Rasa + TensorFlow already in base image)
RUN pip install flask==2.3.3 gunicorn==21.2.0 werkzeug==3.1.3

# Copy all project files
COPY . /app/

RUN chmod +x /app/start.sh

# Override the rasa base image entrypoint so we can run our own startup script
ENTRYPOINT []

# Hugging Face Spaces requires port 7860
EXPOSE 7860

CMD ["/bin/bash", "/app/start.sh"]
