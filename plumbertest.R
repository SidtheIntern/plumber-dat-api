# Randomizer Script (Refactored with Plumber API for Upload Handling)

library(plumber)
library(readxl)
library(openxlsx)
library(dplyr)
library(stringr)
library(lubridate)
library(googledrive)

# Authenticate with Google Drive
drive_auth()

# Get folder ID for a subfolder by name
get_drive_folder_id <- function(parent_id, folder_name) {
  folders <- drive_ls(as_id(parent_id), type = "folder") %>% filter(name == folder_name)
  if (nrow(folders) != 1) stop(paste("Folder not uniquely found:", folder_name))
  return(folders$id)
}

# Upload a file to a specific subfolder
upload_drive_file <- function(parent_id, subfolder_name, local_path) {
  folder_id <- get_drive_folder_id(parent_id, subfolder_name)
  drive_upload(media = local_path, path = as_id(folder_id), overwrite = TRUE)
}

# Locate main folder
main_folder <- drive_get("DAT Application")
main_id <- main_folder$id

#* Upload Employee File from Power Pages
#* @post /upload-employees
#* @serializer unboxedJSON
function(req) {
  if (is.null(req$bodyRaw)) {
    return(list(success = FALSE, message = "No file received."))
  }
  
  # Save file locally
  temp_file <- tempfile(fileext = ".xlsx")
  writeBin(req$bodyRaw, temp_file)
  
  # Upload to GDrive "Uploads" folder
  tryCatch({
    upload_drive_file(main_id, "Uploads", temp_file)
    list(success = TRUE, message = "File uploaded to Google Drive Uploads folder.")
  }, error = function(e) {
    list(success = FALSE, message = paste("Upload failed:", e$message))
  })
}

# To run the API:
pr("plumbertest.R") %>% pr_run(port = 8000)
