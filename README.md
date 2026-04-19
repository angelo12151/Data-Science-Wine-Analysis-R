# Analisi Esplorativa e Multivariata dei Vini (R)

Analisi statistica avanzata finalizzata alla comprensione delle relazioni chimiche, alla riduzione della dimensionalità e all'identificazione di gruppi omogenei (Clustering).

## 📊 Dataset Overview
- **Dimensione**: 178 campioni e 13 caratteristiche chimico-fisiche (es. Alcohol, Flavonoids, Proline).
- **Preprocessing**: Rimozione della variabile "Customer Segment" per operare in modalità non supervisionata.
- **Standardizzazione**: Necessaria per gestire scale e unità di misura differenti tra le variabili.

## 🔬 Fasi dell'Analisi

### 1. Exploratory Data Analysis (EDA)
- **Distribuzioni**: Studio di Skewness e Kurtosis tramite indice di Fisher per identificare asimmetrie e picchi leptocurtici.
- **Visualizzazione**: Implementazione di istogrammi, grafici di densità e boxplot per l'individuazione di outlier (es. Magnesium, Color Intensity).
- **Correlazioni**: Calcolo della matrice di Pearson; identificata forte ridondanza tra Fenoli Totali e Flavonoidi ($\rho=0.86$).

### 2. Principal Component Analysis (PCA)
- **Metodo**: Applicazione di `prcomp` su matrice di correlazione per massimizzare la varianza spiegata.
- **Selezione**: Scelta di 3 Componenti Principali (PC) tramite Scree Plot e criterio di Kaiser (65.5% varianza totale spiegata).
- **Contributi**: La PC1 sintetizza l'informazione di Flavonoidi e Fenoli, la PC2 la Color Intensity.

### 3. Clustering
- **K-means**: Determinazione del numero ottimale di cluster ($k=3$) tramite Elbow Method (somma quadrati inter/intra cluster) e indice Silhouette.
- **Gerarchico**: Costruzione di un dendrogramma con Ward linkage method e distanze euclidee al quadrato.
- **Profiling**: Identificazione di tre gruppi distinti: vini strutturati (C1), leggeri (C2) e giovani ad alta acidità (C3).

## 🛠️ Tech Stack
- **Linguaggio**: R.
- **Librerie**: `ggplot2` (visualizzazione), `factoextra` (PCA), `GGally` (pair plot), `knitr` (reportistica).

---

## 📂 Documentazione
È possibile consultare la relazione tecnica completa e i dettagli metodologici tramite il link seguente:
* 📄 **Relazione tecnica:** [Visualizza il PDF](https://docs.google.com/viewer?url=https://raw.githubusercontent.com/angelo12151/Data-Science-Wine-Analysis-R/main/Progetto_Data_Science.pdf) 
