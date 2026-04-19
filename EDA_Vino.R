library(tidyverse)     # Manipolazione dati e grafici
library(corrplot)      # Grafici di correlazione
library(GGally)        # Grafici avanzati tipo ggpairs
library(knitr)         # Tabelle ben formattate (kable)
library(cowplot)       # Grafici combinati in grid
library(factoextra)    # Visualizzazione PCA e clustering
library(scatterplot3d) # Creazione di scatterplot 3D statici
library(plotly)        # Grafici interattivi (2D e 3D)
library(stats)         # Funzioni statistiche di base (es. hclust, lm, test)
library(e1071)         # Funzioni per skewness e curtosi
library(gridExtra)     # Visualizzazione grafici in griglia
library(cluster)       # Indice silhouette

wines <- read.csv("C:/Users/lapac/OneDrive - Università degli Studi di Bari/Desktop/Wine.csv")

wines <- wines[, -14]

kable(head(wines))

summary(wines)


#--------------- Istogramma ---------------#


long_wines <- gather(wines, Attributes, value)

ggplot(long_wines, aes(x = value, fill = Attributes)) +
  geom_histogram(colour = "black", show.legend = FALSE) +
  facet_wrap(~Attributes, scales = "free") +
  labs(x = "Valori", y = "Frequenza",
       title = "Attributi del vino - Istogramma") +
  theme_bw()


#--------------- Densità ---------------#


ggplot(long_wines, aes(x = value, fill = Attributes)) +
  geom_density(colour = "black", alpha = 0.8, show.legend = FALSE) +
  facet_wrap(~Attributes, scales = "free") +
  labs(x = "Valori", y = "Densità",
       title = "Attributi del vino - Grafico densità") +
  theme_bw()


#--------------- Skewness e Curtosi ---------------#


data.frame(
  Variabile = colnames(wines),
  Skewness = sapply(wines, skewness),
  Kurtosis = sapply(wines, kurtosis)
)


#--------------- Boxplots ---------------#


ggplot(long_wines, aes(x = value, y = Attributes, fill = Attributes)) +
  geom_boxplot(show.legend = FALSE, width = 0.4) +  
  facet_wrap(~Attributes, scales = "free") +
  labs(title = "Attributi del vino - Boxplot") +
  theme_bw() +
  theme(axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        axis.text.y = element_blank())


#--------------- Grafico di correlazione ---------------#


corrplot(cor(wines, method = "pearson"),
         method = "color", 
         type = "lower",
         addCoef.col = "black",
         tl.col = "black",
         diag = FALSE,
         col = colorRampPalette(c("white", "red"))(200)) 


#--------------- Regressione lineare ---------------#


a <- ggplot(wines, aes(x = Total_Phenols, y = Flavanoids)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Relazione tra fenoli totali e flavonoidi") +
  theme_bw()

b <- ggplot(wines, aes(x = OD280, y = Flavanoids)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Relazione tra OD280 e flavonoidi") +
  theme_bw()

grid.arrange(a, b, nrow = 1, ncol = 2)


#--------------- PCA ---------------#


wines_pca <- prcomp(wines, center = TRUE, scale = TRUE)

summary(wines_pca)

lambda <- (wines_pca$sdev)^2

wines_scree <- data.frame(
  PC = 1:length(lambda),
  Autovalori = lambda)

var <- get_pca_var(wines_pca) 

corrplot(var$cos2, tl.col = "black", method = "number")

ggplot(wines_scree, aes(x = PC, y = Autovalori)) +
  geom_line(color = "blue") +
  geom_point(size = 3, color = "blue") +
  geom_hline(yintercept = mean(lambda), linetype = "dashed", color = "red", linewidth = 1) +
  geom_text(aes(label = round(Autovalori, 2)), vjust = -0.7, size = 3) +
  labs(title = "Scree Plot con criterio di Kaiser",
       x = "Numero Componenti Principali",
       y = "Autovalori") +
  scale_x_continuous(breaks = seq(1, length(lambda), by = 2)) +
  theme_minimal(base_size = 13)

wines_var_perc <- lambda / sum(lambda)

wines_var <- data.frame(
  PC = 1:length(lambda),
  Varianza_Cumulativa = cumsum(wines_var_perc))

ggplot(wines_var, aes(x = PC, y = Varianza_Cumulativa)) +
  geom_line(color = "darkgreen") +
  geom_point(size = 3, color = "darkgreen") +
  geom_hline(yintercept = 0.9, linetype = "dashed", color = "blue", linewidth = 1) +
  geom_hline(yintercept = 0.7, linetype = "dashed", color = "blue", linewidth = 1) +
  geom_text(aes(label = paste0(round(Varianza_Cumulativa*100, 1), "%")),
            vjust = -0.7, size = 3) +
  labs(title = "Varianza Cumulativa Spiegata",
       x = "Componenti Principali",
       y = "Varianza Cumulativa") +
  scale_y_continuous(labels = scales::percent) +
  scale_x_continuous(breaks = seq(1, length(lambda), by = 2)) +
  theme_minimal(base_size = 13)


#--------------- k-means ---------------#


wines_norm <- as.data.frame(scale(wines))

set.seed(1234)

bss <- numeric()
wss <- numeric()

for(i in 1:10){
  
  bss[i] <- kmeans(wines_norm, centers=i)$betweenss
  wss[i] <- kmeans(wines_norm, centers=i)$tot.withinss
  
}

a <- ggplot(data.frame(x = 1:10, y = bss), aes(x = x, y = y)) +
  geom_point() +
  geom_line() +
  scale_x_continuous(breaks = seq(0, 10, 1)) +
  labs( 
    x = "Numero di cluster",
    y = "Somma dei quadrati tra i cluster (betweenss)") +
  theme_bw()

b <- ggplot(data.frame(x = 1:10, y = wss), aes(x = x, y = y)) +
  geom_point() +
  geom_line() +
  scale_x_continuous(breaks = seq(0, 10, 1)) +
  labs( 
    x = "Numero di cluster",
    y = "Somma dei quadrati all'interno dei cluster (withinss)") +
  theme_bw()

plot_grid(a, b, ncol = 2)

set.seed(1234)

wines_k3 <- kmeans(wines_norm, centers = 3)

kable(aggregate(wines, by = list(wines_k3$cluster), mean))

ggpairs(cbind(wines, Cluster = as.factor(wines_k3$cluster)),
        columns = 1:13, aes(colour = Cluster, alpha = .5),
        lower = list(continuous = "points"),
        upper = list(continuous = "blank"),
        axisLabels = "none", switch = "both") +
  theme_bw()

fviz_nbclust(scale(wines), kmeans, method = "silhouette") + 
  ggtitle("Numero ottimale di cluster") +
  xlab("Numero di cluster k") +
  ylab("Valore medio di Silhouette")

pca_scores <- wines_pca$x[, 1:3]

fig <- plot_ly(x = pca_scores[,1], y = pca_scores[,2], z = pca_scores[,3],
        type = 'scatter3d', mode = 'markers',
        color = as.factor(wines_k3$cluster),   
        colors = c("red","green","blue"),
        marker = list(size = 5, opacity = 0.8)) 

layout(fig, scene = list(xaxis = list(title = 'PC1'),
                      yaxis = list(title = 'PC2'),
                      zaxis = list(title = 'PC3')),
         title = "PCA 3D - interattivo")

plot_ly(
  data = as.data.frame(pca_scores),
  x = ~PC1,
  y = ~PC2,
  color = ~as.factor(wines_k3$cluster),
  colors = c("red","darkgreen","blue"),
  type = 'scatter',
  mode = 'markers'
) %>% layout(title = "PC1 vs PC2")

plot_ly(
  data = as.data.frame(pca_scores),
  x = ~PC1,
  y = ~PC3,
  color = ~as.factor(wines_k3$cluster),
  colors = c("red","darkgreen","blue"),
  type = 'scatter',
  mode = 'markers'
) %>% layout(title = "PC1 vs PC3")

plot_ly(
  data = as.data.frame(pca_scores),
  x = ~PC2,
  y = ~PC3,
  color = ~as.factor(wines_k3$cluster),
  colors = c("red","darkgreen","blue"),
  type = 'scatter',
  mode = 'markers'
) %>% layout(title = "PC2 vs PC3")


#--------------- Dendrogramma ---------------#


dist_pca <- dist(pca_scores)

cluster_ger <- hclust(dist_pca, method = "ward.D2")

fviz_dend(cluster_ger, 
          k = 3,              
          cex = 0.7,                       
          rect = TRUE,        
          rect_fill = TRUE,   
          palette = "Dark2",
          rect_border = "Dark2",
          show_labels = FALSE,
          ylab = "Distanza (similarità)",
          main = "Dendrogramma")






