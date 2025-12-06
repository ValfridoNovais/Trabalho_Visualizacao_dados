# app/dashboard-principal/app.R
library(shiny)
library(bslib)
library(leaflet)
library(sf)
library(dplyr)
library(plotly)
library(DT)
library(bsicons)

# === 1. CONFIGURAÇÃO (Recursos Estáticos) ===
addResourcePath(prefix = "assets", directoryPath = "../../www")

# === 2. DADOS (Mantido igual) ===
sf::sf_use_s2(FALSE)
setores <- st_read("www/19_bpm.json.geojson", quiet = TRUE) %>%
  st_make_valid() %>% st_transform(4326) %>% mutate(across(where(is.character), trimws)) 

# Gera dados fictícios (Resumido para economizar espaço aqui, use o seu loop original)
set.seed(2025)
ocorrencias_list <- list()
for(i in 1:nrow(setores)) {
  poly <- setores[i, ]
  bbox <- st_bbox(poly)
  pts_cand <- data.frame(lon = runif(100, bbox[1], bbox[3]), lat = runif(100, bbox[2], bbox[4])) %>% st_as_sf(coords = c("lon","lat"), crs = 4326)
  dentro <- st_filter(pts_cand, poly)
  if(nrow(dentro) > 0) {
    qtd <- min(nrow(dentro), sample(5:20, 1))
    dados_geo <- dentro[1:qtd, ]
    dados_geo$SETOR_PM <- poly$SETOR_PM; dados_geo$SUB_SETOR <- poly$SUB_SETOR; dados_geo$CIA_PM <- poly$CIA_PM; dados_geo$PELOTAO <- poly$PELOTAO; dados_geo$BAIRRO <- poly$BAIRRO
    dados_geo$natureza <- sample(c("Roubo","Furto","Tráfico","Homicídio","Vias de Fato"), qtd, replace = TRUE)
    dados_geo$data <- sample(seq(as.Date('2025-01-01'), Sys.Date(), by="day"), qtd, replace = TRUE)
    dados_geo$gravidade <- sample(c("Baixa","Média","Alta","Gravíssima"), qtd, replace = TRUE, prob = c(.3,.4,.2,.1))
    ocorrencias_list[[i]] <- dados_geo
  }
}
ocorrencias <- do.call(rbind, ocorrencias_list)

# === 3. UI ===
theme <- bs_theme(
  version = 5,
  bootswatch = "darkly", 
  primary = "#3b82f6",
  base_font = font_google("Inter"),
  heading_font = font_google("Oswald")
)

ui <- page_sidebar(
  theme = theme,
  fillable = FALSE, # <--- ISSO DESTRAVA O SCROLL (O "Body" pode crescer infinitamente)
  
  # === CSS PERSONALIZADO (Ajustes Visuais Finos) ===
  tags$head(
    tags$style(HTML("
      /* 1. Header Fixo (Sticky) */
      .bslib-sidebar-layout > .navbar {
         position: sticky;
         top: 0;
         z-index: 1050; /* Garante que fique acima do mapa */
         background-color: #0f172a !important; /* Mesma cor do sidebar */
         border-bottom: 1px solid #334155;
      }
      
      /* 2. Ajuste dos Cards (Menores e mais compactos) */
      .value-box {
         max-height: 110px; /* Força altura menor */
         padding: 0.5rem !important;
      }
      .value-box .value-box-value {
         font-size: 1.8rem !important; /* Fonte do número menor */
      }
      .value-box .value-box-title {
         font-size: 0.9rem !important;
         opacity: 0.8;
      }
      .bs-icon {
         font-size: 2rem !important; /* Ícone menor */
      }
    "))
  ),
  
  title = div(
    img(src = "assets/logo_19bpm.png", height = 40, style = "margin-right:10px; vertical-align: middle;"),
    span("19º BPM | INTELIGÊNCIA", style = "font-weight: 800; font-size: 1.2rem; vertical-align: middle;")
  ),
  
  sidebar = sidebar(
    width = 300,
    bg = "#0f172a",
    # position = "fixed", # <--- Se quiser que a barra lateral também fique fixa, descomente isso
    title = "Filtros Táticos",
    selectInput("cia", "Companhia", choices = c("Todas")),
    selectInput("pelotao", "Pelotão", choices = c("Todos")),
    selectInput("subsetor", "Sub-Setor", choices = c("Todos")),
    hr(),
    dateRangeInput("datas", "Período", start = "2025-01-01", end = Sys.Date(), language = "pt-BR"),
    checkboxGroupInput("natureza", "Natureza", choices = sort(unique(ocorrencias$natureza)), selected = sort(unique(ocorrencias$natureza))[1:3])
  ),
  
  # === CONTEÚDO ===
  
  # Cards Compactos
  layout_columns(
    fill = FALSE,
    value_box(
      title = "Total", value = textOutput("kpi_total"),
      showcase = bs_icon("shield-shaded"), theme = "primary",
      class = "shadow-sm" # Sombra leve
    ),
    value_box(
      title = "Crime Principal", value = textOutput("kpi_crime"),
      showcase = bs_icon("graph-up-arrow"), theme = "danger",
      class = "shadow-sm"
    ),
    value_box(
      title = "Bairro Crítico", value = textOutput("kpi_bairro"),
      showcase = bs_icon("geo-fill"), theme = "warning",
      class = "shadow-sm"
    )
  ),
  
  br(),
  
  # Navegação (Agora com gráficos mais altos pois a página rola)
  navset_card_underline(
    title = "Visão Operacional",
    
    nav_panel(
      "Mapa Tático", icon = bs_icon("map"),
      leafletOutput("mapa", height = "650px") # Mapa bem alto
    ),
    
    nav_panel(
      "Estatísticas", icon = bs_icon("bar-chart-line"),
      
      # Layout de Gráficos (Bootstrap Grid)
      layout_columns(
        col_widths = c(6, 6, 12),
        
        # Gráfico 1
        card(
          card_header("Por Natureza", class="bg-transparent border-0"),
          plotlyOutput("graf_natureza", height = "350px")
        ),
        
        # Gráfico 2
        card(
          card_header("Evolução Temporal", class="bg-transparent border-0"),
          plotlyOutput("graf_temporal", height = "350px")
        ),
        
        # Gráfico 3 (Ocupa largura total embaixo)
        card(
          card_header("Ranking de Bairros", class="bg-transparent border-0"),
          plotlyOutput("graf_bairro", height = "400px")
        )
      )
    ),
    
    nav_panel(
      "Base de Dados", icon = bs_icon("table"),
      DTOutput("tabela")
    )
  )
)

# === 4. SERVER ===
server <- function(input, output, session) {
  
  # (Lógica de filtros igual ao anterior...)
  observe({ updateSelectInput(session, "cia", choices = c("Todas", sort(unique(ocorrencias$CIA_PM)))) })
  observeEvent(input$cia, {
    opcoes <- if(input$cia == "Todas") sort(unique(ocorrencias$PELOTAO)) else sort(unique(ocorrencias$PELOTAO[ocorrencias$CIA_PM == input$cia]))
    updateSelectInput(session, "pelotao", choices = c("Todos", opcoes))
  })
  observeEvent(input$pelotao, {
    dados_t <- if(input$cia == "Todas") ocorrencias else filter(ocorrencias, CIA_PM == input$cia)
    opcoes <- if(input$pelotao == "Todos") sort(unique(dados_t$SUB_SETOR)) else sort(unique(dados_t$SUB_SETOR[dados_t$PELOTAO == input$pelotao]))
    updateSelectInput(session, "subsetor", choices = c("Todos", opcoes))
  })
  
  dados <- reactive({
    df <- ocorrencias
    if(input$cia != "Todas") df <- df %>% filter(CIA_PM == input$cia)
    if(input$pelotao != "Todos") df <- df %>% filter(PELOTAO == input$pelotao)
    if(input$subsetor != "Todos") df <- df %>% filter(SUB_SETOR == input$subsetor)
    if(!is.null(input$natureza)) df <- df %>% filter(natureza %in% input$natureza)
    df %>% filter(data >= input$datas[1] & data <= input$datas[2])
  })
  
  # KPIs
  output$kpi_total <- renderText({ nrow(dados()) })
  output$kpi_crime <- renderText({ d <- dados() %>% st_drop_geometry(); if(nrow(d)==0) return("-"); names(sort(table(d$natureza), decreasing=T))[1] })
  output$kpi_bairro <- renderText({ d <- dados() %>% st_drop_geometry(); if(nrow(d)==0) return("-"); names(sort(table(d$BAIRRO), decreasing=T))[1] })
  
  # Mapa
  output$mapa <- renderLeaflet({
    leaflet() %>% addProviderTiles(providers$CartoDB.DarkMatter) %>%
      addPolygons(data = setores, weight = 1, color = "#64748b", fillOpacity = 0.1) %>%
      addCircleMarkers(data = dados(), radius = 6, color = ~ifelse(gravidade=="Gravíssima","#ef4444","#22c55e"),
                       stroke = FALSE, fillOpacity = 0.8, popup = ~paste(natureza, BAIRRO))
  })
  
  # === GRÁFICOS OTIMIZADOS (BARRAS MAIS FINAS) ===
  
  output$graf_natureza <- renderPlotly({
    d <- dados() %>% st_drop_geometry() %>% count(natureza)
    plot_ly(d, x=~n, y=~reorder(natureza, n), type='bar', orientation='h', 
            marker=list(color='#3b82f6')) %>%
      layout(bargap = 0.4, # <--- DEIXA AS BARRAS MAIS FINAS (quanto maior, mais espaço entre elas)
             paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', 
             font=list(color='white'), xaxis=list(title=""), yaxis=list(title=""))
  })
  
  output$graf_temporal <- renderPlotly({
    d <- dados() %>% st_drop_geometry() %>% count(data)
    plot_ly(d, x=~data, y=~n, type='scatter', mode='lines+markers', 
            line=list(color='#ef4444', width = 2)) %>% # Linha mais fina
      layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', 
             font=list(color='white'), xaxis=list(title=""), yaxis=list(title=""))
  })
  
  output$graf_bairro <- renderPlotly({
    d <- dados() %>% st_drop_geometry() %>% count(BAIRRO) %>% arrange(desc(n)) %>% head(15) # Top 15 agora
    plot_ly(d, x=~BAIRRO, y=~n, type='bar', marker=list(color='#eab308')) %>%
      layout(bargap = 0.3, # <--- BARRAS MAIS FINAS
             paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', 
             font=list(color='white'), xaxis=list(title="", tickangle = -45), yaxis=list(title=""))
  })
  
  output$tabela <- renderDT({
    dados() %>% st_drop_geometry() %>% select(Data=data, Nat=natureza, Bairro=BAIRRO, Setor=SETOR_PM) %>%
      datatable(options = list(pageLength = 10))
  })
}

shinyApp(ui, server)