### **README File for AMR Study**

---

## **1. System Requirements**

### **Software Dependencies:**
- **R (version 4.4.1 or higher)** – The software is developed and tested using the R programming language.
- **Required R Packages**:
  - `plyr` (Tools for Splitting, Applying and Combining Data)
  - `reshape2` (Flexibly Reshape Data: A Reboot of the Reshape Package)
  - `INLA` (Full Bayesian Analysis of Latent Gaussian Models using Integrated Nested Laplace)
  - `spdep` (Spatial Dependence: Weighting Schemes, Statistics)
  - `ggplot2` (Create Elegant Data Visualisations Using the Grammar of Graphics)
  - `sf` (Simple Features for R)
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
   
2. **Install Required R Packages**:  
   Open R or RStudio and install the required packages by running the following command:
   ```r
   install.packages(c("plyr", "reshape2", "spdep", "ggplot2", "sf", "pactchwork"))
   ```
   For INLA package:
   ```r
   if (!requireNamespace("BiocManager", quietly = TRUE))
   install.packages("BiocManager")
   BiocManager::install("Rgraphviz")
   install.packages("INLA", repos=c(getOption("repos"), INLA="https://inla.r-inla-download.org/R/stable"), dep=TRUE)
   ```

3. **Download RStudio**:  
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

### **Typical Install Time**:
On a normal desktop computer: The process typically takes 5–10 minutes, depending on internet speed and system performance.
By completing this step, you will have a fully functional R and RStudio environment for running the provided code.

---

## **3. Demo**

### **Instructions to Run on Data**:

1. **Prepare Your Data**:
   - The software is designed to handle antimicrobial resistance (AMR) data from a variety of sources. Ensure that your data is formatted similarly to the example dataset included in the repository.
   - The dataset should include the following columns:
     - `Country`
     - `Year`
     - `AMR Profile`
     - `AMR Value`
     - `Socioeconomic Variables`
     - `Climate Variables`

2. **Running the Demo**:
   - Navigate to the directory where the software is stored.
   - Run the following command in R:
   ```r
   source("demo_script.R")
   ```
   This script will process a small demo dataset, perform data analysis, and generate output figures.

3. **Expected Output**:
   - A summary of AMR profiles across countries and years, showing trends and comparisons.
   - Visualizations (e.g., line plots, bar charts) depicting AMR trends by region, year, and socioeconomic factors.
   - Tables summarizing key metrics and comparisons between different AMR profiles.

### **Expected Run Time**:
- On a typical desktop computer (e.g., 4GB RAM, modern processor), the demo should take approximately **3-5 minutes** to run depending on system performance.

---

## **4. Instructions for Use**

### **How to Run the Software on Your Own Data**:

1. **Prepare Data**:
   - Your data should follow the structure outlined in the demo dataset (see sample dataset in the repository).
   - Ensure that each variable is properly formatted (numeric values for AMR, year, socioeconomic and environmental variables).

2. **Running the Code**:
   - Once your dataset is ready, load the data into R:
   ```r
   data <- read.csv("your_data.csv")
   ```
   - Apply the analysis functions from the script to analyze AMR data and visualize trends:
   ```r
   source("main_analysis_script.R")
   ```
   - You can customize the script to run different types of analyses (e.g., temporal trends, comparisons by country, etc.).

3. **Generate Visualizations**:
   - The analysis functions will generate various visualizations, such as heatmaps, line plots, and bar charts. These plots will help you explore the relationship between AMR and factors like climate and socioeconomic data.

4. **Results Interpretation**:
   - Review the output tables and plots to identify trends, patterns, and any significant differences between countries or AMR profiles.

---

## **(OPTIONAL) Reproduction Instructions**

For users interested in reproducing the analysis:

1. **Data Sources**:
   - Data for AMR profiles can be accessed from:
     - **ResistanceMap** (global AMR data)
     - **EARS-Net**, **CAESAR**, **CARSS** (regional data)
     - **GLASS**, **ESAC-Net**, **GRAM** (antimicrobial consumption data)

2. **Data Processing Steps**:
   - The data processing steps are documented in the code. You will need to download the relevant datasets, clean and preprocess them, and then input them into the provided R scripts for analysis.

3. **Additional Notes**:
   - The analysis code assumes that data has already been cleaned and formatted. If you need assistance with data preprocessing, refer to the preprocessing section of the `main_analysis_script.R`.

---

### **Conclusion**

This README file provides a comprehensive guide to setting up, installing, and running the software for the global AMR study. By following the instructions, users will be able to perform AMR analysis on their own datasets and reproduce the results presented in the study.

---
