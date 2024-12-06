### **README File for AMR Study**

---

## **1. System Requirements**

### **Software Dependencies:**
- **R (version 4.4.1 or higher)** – The software is developed and tested using the R programming language.
- **Required R Packages**:
  - `dplyr` (A Grammar of Data Manipulation)
  - `reshape2` (Flexibly Reshape Data: A Reboot of the Reshape Package)
  - `car` (Companion to Applied Regression)
  - `scales` (Scale Functions for Visualization)
  - `INLA` (Full Bayesian Analysis of Latent Gaussian Models using Integrated Nested Laplace)
  - `ggplot2` (Create Elegant Data Visualisations Using the Grammar of Graphics)
  - `ggrepel` (Automatically Position Non-Overlapping Text Labels with 'ggplot2')
  - `ggsci` (Scientific Journal and Sci-Fi Themed Color Palettes for 'ggplot2')
  - `patchwork` (The Composer of Plots)

### **Operating Systems:**
- **Windows** (tested on `x86_64-w64-mingw32` platform)
- **Linux (Ubuntu/Debian)**
- **macOS (tested on version 10.15 or higher)**

### **Non-Standard Hardware:**
- **No specific hardware requirements**. Standard desktop computers with 4GB of RAM or more should be sufficient.

### **Software Versions Tested:**
- R version 4.4.1 (Pile of Leaves) – tested and compatible.
- All required libraries are compatible with R version 2 and above.

---

## **2. Installation Guide**

### **Instructions:**

1. **Install R**:  
   Download and install R from the official R website: [https://cran.r-project.org/](https://cran.r-project.org/).
   
2. **Download RStudio**:  
   RStudio is a popular integrated development environment (IDE) for R, making it easier to write and debug R scripts. Below are the steps to install RStudio:
  
   Download RStudio:
   Visit the official RStudio website at https://posit.co/download/rstudio-desktop/. Select the version suitable for your operating system (Windows, macOS, or Linux).
  
   Install RStudio:
  
   Windows: Run the downloaded .exe file and follow the installation wizard. Default settings are typically sufficient.
   macOS: Open the downloaded .dmg file, drag the RStudio icon into the Applications folder, and follow any additional prompts.
   Linux: Install the .deb or .rpm package depending on your distribution using the package manager, e.g., for Ubuntu:
   ```bash
   sudo apt install ./rstudio-<version>.deb
   ```
   Verify Installation:
   Open RStudio and ensure it detects the installed R version automatically. If not, ensure the R binary path is correctly set in RStudio preferences.

3. **Install Required R Packages**:  
   Open R or RStudio and install the required packages by running the following command:
   ```r
   install.packages(c("dplyr", "reshape2", "car", "scales", "ggplot2", "ggrepel", "ggsci", "pactchwork"))
   ```
   For INLA package:
   ```r
   if (!requireNamespace("BiocManager", quietly = TRUE))
   install.packages("BiocManager")
   BiocManager::install("Rgraphviz")
   install.packages("INLA", repos=c(getOption("repos"), INLA="https://inla.r-inla-download.org/R/stable"), dep=TRUE)
   ```

### **Typical Install Time**:
On a normal desktop computer: The process typically takes 5–10 minutes, depending on internet speed and system performance.
By completing this step, you will have a fully functional R and RStudio environment for running the provided code.

---

### **3. Demo**

#### **Instructions to Run on Data:**

To run the demo on the provided data, follow these steps:

1. **Download and Extract Files**:  
   Ensure that all four folders (`1 AMR data`, `2 Covariant`, `3 INLA model`, `4 Scenario`) and their corresponding files are placed within the same directory.

2. **Open RStudio**:  
   Launch RStudio and navigate to the folder where the files are stored.

3. **Load and Install Dependencies**:  
   Open the relevant script file from each folder (e.g., `AMR variable.R` in the `1 AMR data` folder) and run the initial part of the script to install required packages:
   ```r
   install.packages(c("dplyr", "car", "ggplot2", "ggsci", "scales", "patchwork"))
   library(dplyr)
   library(car)
   library(ggplot2)
   library(ggsci)
   library(scales)
   library(patchwork)
   ```
   This will install and load the necessary libraries to run the code.

4. **Load Data**:  
   After the dependencies are installed, run the script to load the dataset:
   ```r
   AMR <- read.csv("AMR_rawdata.csv")
   ```

5. **Run Functions**:  
   In the `functions` section of the script, define necessary functions for calculating geometric means and finding modes. Run the following:
   ```r
   # Geometric mean
    mean_geo <- function(vector, na.rm = T, adjust = T){
      if(sum(!is.na(vector)) == 0){
        return(NA)
      }else if(max(vector, na.rm = T) == 0){
        return(0)
      }else if(adjust){
        vector[which(vector == 0)] <- min(vector[vector != 0], na.rm = T)
      }
      return(ifelse(sum(!is.na(vector)) == 0, NA, prod(vector, na.rm = na.rm)^(1/sum(!is.na(vector)))))
    } 
    # Find the mode number
    find_mode <- function(x){
      u <- unique(na.omit(x))
      tab <- tabulate(match(x, u))
      return(u[tab == max(tab)][1])
    }
   ```

6. **Process and Aggregate Data**:  
   Run the section of the code to process and aggregate the data, as specified in the `Aggregate AMR` part:
   ```r
   AMR <- 
    AMR %>% 
    mutate(
      R_not0 = case_when(
        R == 0 ~ min(R[R>0]),
        TRUE ~ R),
      .by = AMR
    ) %>% 
    mutate(
      R_geomean = mean_geo(R_not0),
      isolates_total = sum(isolates),
      source_total = find_mode(source),
      .by = c(country, year)
    ) %>% 
    select(-R_not0) %>% 
    # Logit transformation
    mutate(
      R_geomean_logit = logit(R_geomean, adjust = min(R_geomean[R_geomean>0])),
      IncomeGroup = factor(IncomeGroup, 
                           levels = c("High-income", "Upper-middle-income", 
                                      "Lower-middle-income", "Low-income")),
      year_5 = cut(year, c(1999, seq(2004, 2019, 5), 2022))
    )
   ```

7. **Visualize Data**:  
   Finally, use the `Visualization` section to generate plots. Run the following:
   ```r
   # Aggregate AMR
    agg_plot <-
      AMR %>% 
      select(-3:-6) %>% 
      unique() %>% 
      ggplot(aes(x = year, y = R_geomean*100)) +
      geom_boxplot(aes(group = year_5), width = 1, colour = "grey70", outliers = F) +
      geom_jitter(aes(colour = IncomeGroup, size = isolates_total, shape = source_total), 
                  width = 0.3, alpha = 0.35) +
      geom_smooth(aes(colour = IncomeGroup), method = "lm", se = F, key_glyph = "abline") +
      scale_x_continuous(breaks = seq(2000, 2020, 2)) +
      scale_size_continuous(name = "Isolates",
                            range = c(1, 5),
                            transform = "log10",
                            breaks = trans_breaks("log10", function(x) 10^x),
                            labels = trans_format("log10", math_format(10^.x))) +
      scale_shape_discrete(name = "Data sources",
                           breaks = c("EARS-Net", "GLASS", "CAESAR", "Others")) +
      scale_colour_d3(name = "Income groups",
                      breaks = c("High-income", "Low-income",
                                 "Upper-middle-income", "Lower-middle-income")) +
      scale_y_sqrt(labels = scales::comma) +
      labs(x = "", y = "Averge prevalence of antimicrobial resistance (%)") +
      theme_classic() +
      theme(
        plot.title = element_text(size = 15),
        legend.position = "inside",
        legend.position.inside = c(0.25, 0.73),
        legend.text = element_text(size = 13),
        legend.title = element_text(size = 15),
        legend.background = element_blank(),
        strip.background = element_rect(fill = "grey90"),
        panel.background = element_blank(),
        axis.title = element_text(size = 16),
        axis.text = element_text(size = 10),
        axis.text.x = element_text(size = 10, angle = 0),
        axis.line.y = element_line(arrow = arrow(length = unit(0.25, "cm"), angle = 20)),
        text = element_text(family = "serif")
      ) + 
      guides(
        color = guide_legend(override.aes = list(alpha = 1, shape = NA), order = 2, nrow = 2),
        shape = guide_legend(override.aes = list(alpha = 1, colour = "Black", size = 4), order = 3, nrow = 2),
        size = guide_legend(override.aes = list(alpha = 1, colour = "Black"), order = 1, 
                            title.position = "top", direction = "horizontal")
      )
    
    # Six AMR profiles
    AMR_plot <- 
      ggplot(AMR, aes(x = year, y = R*100)) +
      geom_jitter(aes(colour = IncomeGroup, size = isolates, shape = source), 
                  width = 0.4, alpha = 0.2) +
      geom_smooth(aes(colour = IncomeGroup), method = "lm", se = F, linewidth = 0.8) +
      scale_size_continuous(range = c(0.7, 3),
                            trans = log10_trans(),
                            breaks = trans_breaks("log10", function(x) 10^x),
                            labels = trans_format("log10", math_format(10^.x))) +
      scale_color_d3() +
      scale_y_sqrt(labels = comma) +
      scale_x_continuous(breaks = seq(2000, 2020, 5)) +
      facet_wrap(AMR ~ ., scale = "free", nrow = 2) +
      # ggtitle("(B) Antimicrobial resistance of different profiles (%)") +
      labs(x = "", y = "Antimicrobial resistance of different profiles (%)") +
      theme_classic() +
      theme(
        plot.title = element_text(size = 15),
        legend.position = "none",
        strip.text = element_text(size = 16),
        axis.title = element_text(size = 16),
        panel.background = element_blank(),
        axis.line.y = element_line(arrow = arrow(length = unit(0.25, "cm"), angle = 20)),
        text = element_text(family = "serif")
      )
    
    # patchwork
    ggsave("AMR_year.png", height = 12, width = 9, dpi = 500,
           plot = agg_plot / AMR_plot + 
             plot_annotation(tag_levels = 'A') & 
             theme(plot.tag = element_text(size = 25, face = "bold")))
   ```
   This will produce a plot that matches the `AMR_year.png` file in the `1 AMR data` folder.

#### **Expected Output:**

After running all the scripts, you should see the following outputs:
- **Data Processing Output**: The dataset will be processed and aggregated as required for the analysis.
- **Visualization Output**: A plot (`AMR_year.png`) will be generated that visualizes the processed AMR data. The plot will show the trends and patterns in AMR data over time, consistent with the figure provided in the folder.

![AMR_year](https://github.com/user-attachments/assets/619186d9-671b-4b90-96eb-627a360471bb)

#### **Expected Run Time on a "Normal" Desktop Computer:**

- **Installation of dependencies**: Approximately 2-3 minutes (depending on internet speed).
- **Data Processing and Analysis**: The data processing, model fitting, and visualization steps will take approximately **Half a minute to a minute** on a typical desktop computer with 4GB of RAM or more. Complex models or larger datasets might take slightly longer.

---

### **4. Instructions for Use**

#### **How to Run the Software on Your Data:**

To run the software on your own data, follow these general steps:

1. **Prepare Your Data**:  
   Ensure your data is formatted as `.csv` or `.rds` files, similar to the example datasets provided in the folders. Place your data files in the appropriate folder based on the type of analysis you wish to conduct.

2. **Load and Install Dependencies**:  
   As shown in the demo, install the required R packages.

3. **Run Your Code**:  
   Open and run the code files in the appropriate order.

4. **Check the Output**:  
   After running the scripts, check the output directory for your visualizations and processed data.

#### **Reproduction Instructions**:

To reproduce the results presented in the article, you should follow these instructions:

1. **Ensure your environment matches the required software versions** (R version 4.4.1 and required packages).
2. **Use the provided datasets** or format your own data to match the structure in the example files.
3. **Run all scripts in the order provided** for each section (`AMR data`, `Covariant`, `INLA model`, `Scenario`), ensuring that each step is completed before moving to the next.
4. **Compare the output**: After running the scripts, compare the generated outputs (e.g., plots) with the ones in the article to verify consistency.

By following these steps, you can reproduce the analysis and results described in the article using your own data or the provided datasets.

---
