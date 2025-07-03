# Use the official Plumber image from RStudio
FROM rstudio/plumber

# Install R packages your script needs
RUN R -e "install.packages(c('plumber', 'readxl', 'openxlsx', 'dplyr', 'stringr', 'lubridate', 'googledrive'))"

# Copy your code into the container
COPY . /app
WORKDIR /app

# Open port 8000 for web traffic
EXPOSE 8000

# Run the API
CMD ["R", "-e", "pr <- plumber::pr('plumbertest.R'); pr$run(host='0.0.0.0', port=8000)"]
