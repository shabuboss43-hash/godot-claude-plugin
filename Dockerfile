FROM python:3.11-slim

# Set a default Godot version and asset filename. Update GODOT_VERSION ARG if you want a different release.
ARG GODOT_VERSION=4.2.2-stable
ARG GODOT_FILENAME=Godot_v${GODOT_VERSION}_linux.x86_64.zip
ARG GODOT_URL=https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/${GODOT_FILENAME}

RUN apt-get update && apt-get install -y \
    curl unzip wget ca-certificates git build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Godot headless binary into /opt/godot
RUN mkdir -p /opt/godot \
    && echo "Downloading Godot: ${GODOT_URL}" \
    && wget -O /tmp/godot.zip "${GODOT_URL}" || (echo "Godot download failed"; exit 0) \
    && unzip -o /tmp/godot.zip -d /opt/godot || true \
    && chmod -R +x /opt/godot || true

ENV GODOT_BIN=/opt/godot/Godot_v${GODOT_VERSION}_linux.x86_64
ENV PROJECTS_DIR=/workspace/projects
ENV PORT=8000

COPY app ./app
COPY app/static ./static

EXPOSE ${PORT}

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
