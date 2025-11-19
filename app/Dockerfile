FROM python:3.12-slim-trixie

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Ensure the installed binary is on the `PATH`
ENV PATH="/root/.local/bin/:$PATH"

WORKDIR /app
COPY . .

# Install dependencies and acticate env
RUN uv sync --frozen
ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 8080
CMD ["python", "app.py"]