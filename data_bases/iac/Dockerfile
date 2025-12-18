FROM hashicorp/terraform:latest

# utilitários (opcional, mas ajuda em debug/parse)
RUN apk add --no-cache bash curl jq

WORKDIR /iac

# copia TODOS esses arquivos do seu diretório iac/
COPY . /iac

# garante leitura e execução do script
RUN chmod -R a+rX /iac \
 && chmod +x /iac/run_pipeline.sh \
 && sed -i 's/\r$//' /iac/run_pipeline.sh

CMD ["sh", "-c", "sleep infinity"]

