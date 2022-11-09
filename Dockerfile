FROM python:3.10-slim as python-base
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/venv" \
    VENV_PATH="/opt/venv/.venv"
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

FROM python-base as builder-base
RUN apt-get update
RUN apt-get install -y --no-install-recommends curl build-essential gcc libffi-dev libssl-dev libxml2-dev libxslt1-dev zlib1g-dev libxslt-dev gcc libjpeg-dev zlib1g-dev libwebp-dev
# rustc is needed to compile Python packages
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN curl -sSL https://install.python-poetry.org | python3 - 
WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./
RUN poetry install --only main

FROM python-base as production
RUN apt-get update
RUN apt-get install -y --no-install-recommends libjpeg-dev libxslt1-dev libxml2-dev libxslt-dev tree
COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH
COPY . /app/
WORKDIR /app
EXPOSE 8000
CMD ["./misc/docker_start.sh"]
