# Usa uma imagem base que já tem R e dependências essenciais
FROM rocker/r-ver:4.4.0

# 1. Instala TODAS as dependências de sistema necessárias (Correção Linux/Geo)
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    cmake \
    gdal-bin \
    libudunits2-dev \
    pandoc

# 🎯 CORREÇÃO C++: Variável para resolver erro de compilação do 'terra'
ENV CXX_STD=CXX11

# 2. Define o diretório de trabalho
WORKDIR /app

# 3. Copia o arquivo renv.lock da RAIZ do projeto e restaura o ambiente R
COPY renv.lock ./
# Instala o renv, restaura as dependências do lock file
RUN R -e "install.packages('renv', repos = 'https://cloud.r-project.org')"
RUN R -e "renv::restore(prompt = FALSE)"

# 4. Copia o restante do código da aplicação
# Isto copia app/ e a www/ da raiz para dentro de /app
COPY . .

# 5. Expõe a porta que o Shiny usa
EXPOSE 8080

# 6. Comando para iniciar o servidor Shiny (AGORA COM MULTI-APP DINÂMICO)
# Aponta para a pasta 'app/app', que contém todos os sub-dashboards (dashboard-principal, dashboard-efetivo, etc.)
CMD ["R", "-e", "shiny::runApp('app/app', port=8080, host='0.0.0.0')"]