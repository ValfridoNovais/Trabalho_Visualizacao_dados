# 🛡️ Portal de Inteligência Operacional - 19º BPM

> **Sistema Integrado de Monitoramento e Análise Criminal**
> *19º Batalhão de Polícia Militar de Minas Gerais - Seção de Inteligência (P3)*

![Status](https://img.shields.io/badge/Status-Em_Desenvolvimento-yellow?style=for-the-badge)
![R](https://img.shields.io/badge/R-4.4.0+-blue?style=for-the-badge&logo=r)
![Shiny](https://img.shields.io/badge/Shiny-1.8.0-blueviolet?style=for-the-badge&logo=rstudio)
![Leaflet](https://img.shields.io/badge/Mapas-Leaflet-green?style=for-the-badge&logo=leaflet)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker)

---

## 📸 Visão Geral do Sistema

O **Portal de Inteligência** é uma solução *Full-Stack* desenvolvida para modernizar a gestão de dados de segurança pública. O sistema substitui planilhas estáticas por inteligência geoespacial em tempo real, permitindo o policiamento orientado por dados (*Data-Driven Policing*).

### 🖥️ Dashboard Tático (Analítico)
*Visualização de clusters de criminalidade, filtros hierárquicos e métricas de desempenho.*
<!-- ![Dashboard Preview](www/print_dashboard.png) -->

### 🌐 Landing Page (Acesso)
*Portal de entrada rápido e responsivo para direcionamento de tráfego interno.*
<!-- ![Landing Page Preview](www/print_landing.png) -->

---

## 🚀 Funcionalidades Principais

### 1. Inteligência Geoespacial
- **Mapeamento de Polígonos:** Visualização exata dos setores, companhias e pelotões do 19º BPM.
- **Heatmaps e Clusters:** Identificação imediata de zonas quentes de criminalidade.
- **Filtros em Cascata:** Selecione uma Cia e o sistema filtra automaticamente os Pelotões e Sub-setores correspondentes.

### 2. Análise Estatística
- **Séries Temporais:** Acompanhamento da evolução do crime (diário, mensal, anual).
- **KPIs Dinâmicos:** Cards de "Value Box" que mostram metas e alertas em tempo real.
- **Comparativos:** Análise de Natureza do delito x Bairro x Horário.

### 3. Arquitetura Moderna
- **Frontend Híbrido:** HTML/Tailwind para leveza na entrada + Shiny para poder analítico.
- **Responsividade:** Funciona em Desktops (COPOM/SOU) e Tablets (Viaturas).
- **Modo Escuro:** Interface "Dark Mode" nativa para ambientes com baixa luminosidade (operacional).

---

## 🛠️ Tecnologias Utilizadas

Este projeto utiliza o estado da arte em análise de dados com R:

* **Core:** [R Language](https://www.r-project.org/) (v4.4+)
* **Web Framework:** [Shiny](https://shiny.rstudio.com/) & [Bslib](https://rstudio.github.io/bslib/) (Bootstrap 5)
* **Frontend Estático:** HTML5, [Tailwind CSS](https://tailwindcss.com/)
* **Mapas:** [Leaflet](https://rstudio.github.io/leaflet/) & [Sf](https://r-spatial.github.io/sf/) (Simple Features)
* **Visualização:** [Plotly](https://plotly.com/r/) & [DT](https://rstudio.github.io/DT/)
* **Infraestrutura:** Docker, Easypanel, Renv (Gerenciamento de pacotes)

---

## 📂 Estrutura do Repositório

```plaintext
Trabalho_Visualizacao_dados/
├── app/                              # 🧠 Módulos de Inteligência
│   ├── dashboard-principal/          # Painel Tático (Shiny)
│   │   ├── app.R                     # Código Fonte Único
│   │   ├── www/                      # GeoJSON e Assets Locais
│   │   └── renv.lock                 # Dependências Isoladas
│   ├── dashboard-roubos/             # (Em desenvolvimento)
│   └── dashboard-efetivo/            # (Em desenvolvimento)
│
├── relatorios/                       # 📄 Relatórios Automatizados
│   ├── relatorio-mensal.qmd          # Quarto Document
│   └── comparativos.qmd
│
├── static/                           # 🌐 Frontend Estático
│   └── index.html                    # Landing Page
│
├── www/                              # 🎨 Assets Globais
│   ├── logo_19bpm.png
│   └── styles.css
│
└── .easypanel.json                   # ☁️ Configuração de Deploy
```

---

## 💻 Instalação e Execução Local

Siga os passos abaixo para rodar o projeto na sua máquina:

### Pré-requisitos
- R e RStudio instalados.
- Git instalado.

### 1. Clonar o Repositório
```bash
git clone [https://github.com/SEU_USUARIO/portal-19bpm.git](https://github.com/SEU_USUARIO/portal-19bpm.git)
cd Trabalho_Visualizacao_dados
```

### 2. Restaurar o Ambiente (Renv)
O projeto usa `renv` para garantir que todos tenham as mesmas versões das bibliotecas. Abra o arquivo `app/dashboard-principal/app.R` no RStudio e execute no console:

```r
install.packages("renv")
renv::restore() # Isso vai baixar todas as bibliotecas necessárias automaticamente
```

### 3. Executar
Abra o arquivo `app.R` e clique no botão **Run App** (ou pressione `Ctrl+Shift+Enter`).

---

## ☁️ Deploy (Produção)

O projeto está configurado para deploy via **Easypanel/Docker**.
O arquivo `.easypanel.json` na raiz orquestra três serviços simultâneos:

1.  **Static Site:** Serve a Landing Page na rota raiz (`/`).
2.  **App Service:** Serve o Shiny Server na rota `/app/`.
3.  **Reports Service:** Renderiza os HTMLs do Quarto na rota `/relatorios/`.

---

## 📝 Licença e Autoria

**Desenvolvido por:** [Seu Nome / 1º Ten Ataíde]
**Unidade:** 19º Batalhão de Polícia Militar (Teófilo Otoni - MG)
**Contato:** [Seu Email Profissional]

> *Aviso: Este software é de uso interno e estratégico. A divulgação de dados sensíveis contidos no GeoJSON deve seguir os protocolos da P3.*
            