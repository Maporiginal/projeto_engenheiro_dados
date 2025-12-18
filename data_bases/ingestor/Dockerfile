FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY . /app

# garante leitura/execução pra qualquer usuário
RUN chmod -R a+rX /app

CMD ["sh", "-c", "python /app/main.py || true; tail -f /dev/null"]

