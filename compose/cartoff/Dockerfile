FROM python:3.12-slim-bookworm
WORKDIR /app
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*
EXPOSE 8001
CMD ["python3", "serve.py", "-p", "8001"]
