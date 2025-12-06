# Usa uma imagem base que já tem R e dependências essenciais
FROM rocker/r-ver:4.4.0

# 1. Instala dependências de sistema necessárias para pacotes como 'sf'
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev

# 2. Define o diretório de trabalho
WORKDIR /app

# 3. Copia o arquivo renv.lock da RAIZ do projeto e restaura o ambiente R
# O renv.lock garante as versões corretas
COPY renv.lock ./
# Instala o renv, restaura as dependências do lock file
RUN R -e "install.packages('renv', repos = 'https://cloud.r-project.org')"
RUN R -e "renv::restore(prompt = FALSE)"

# 4. Copia o restante do código da aplicação
COPY . .

# 5. Expõe a porta que o Shiny usa (8080 conforme .easypanel.json)
EXPOSE 8080

# 6. Comando para iniciar o servidor Shiny
# O app.R está em app/dashboard-principal/app.R
CMD ["Rscript", "app/dashboard-principal/app.R"]