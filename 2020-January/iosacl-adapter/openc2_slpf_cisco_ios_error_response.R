#This file contains functions for error response codes and messages. Everything is saved into a database for later reference.

#Not Specified Asset_id in the OpenC2 command
error_response_asset_id <- function(){
   #Reponse Message
   response_message <- list(status="", status_text="")
   
   #Response Status Code
   #Reference the OpenC2 specifications for the exact meaning of each code
   status_code <- c("102", "200", "400", "500", "501", "503")
   
   #Actuator asset_id is not specified - error
   uuid_time_date_list <- uuid_time_date() #generates time, date, and UUIDv4
   consumer <- get("consumer", pos = parent.frame()) #gets consumer details
   response_message$status <- status_code[4]
   response_message$status_text <- "Asset_id is not Specified"
   response <- toJSON(response_message,auto_unbox = TRUE, pretty = TRUE)
   assign("response", response, envir = .GlobalEnv ) #assigns response variable - code and text to the Global Environment. This variable can be used from the front-end etc.
   
   conn <- dbConnect(RSQLite::SQLite(), database_name) #creates a database connection
   query <- dbSendQuery(conn = conn,
                        "INSERT INTO OpenC2 (UID, Date, Time, OpenC2_Command, Status_Code, Status_Text)
                           VALUES (?,?,?,?,?,?)", list(uuid_time_date_list$uid, uuid_time_date_list$date, uuid_time_date_list$time, json_copy_of_openc2_command, response_message$status, response_message$status_text))
   dbClearResult(query) #frees all resources (local and remote) associated with a result set. In some cases (e.g., very large result sets) this can be a critical step to avoid exhausting resources (memory, file descriptors, etc.)
   dbDisconnect(conn)
   stop(response)
}

#Wrong Action or Target in Action-Target Pair
error_response_action_target_argument_pair <- function(){
   #Reponse Message
   response_message <- list(status="", status_text="")
   
   #Response Status Code
   #Reference the OpenC2 specifications for the exact meaning of each code
   status_code <- c("102", "200", "400", "500", "501", "503")
   
   uuid_time_date_list <- uuid_time_date() #generates time, date, and UUIDv4
   consumer <- get("consumer", envir = parent.frame()) #gets consumer details
   
   response_message$status <- status_code[5]
   response_message$status_text <- "Bad Request. Unable to process Command - Not Supported Action/Target Pair or Argument"
   response <- toJSON(response_message, auto_unbox = TRUE, pretty = TRUE)
   assign("response", response, envir = .GlobalEnv ) #assigns response variable - code and text to the Global Environment. This variable can be used from the front-end etc.
   
   conn <- dbConnect(RSQLite::SQLite(), database_name) #creates a database connection
   query <- dbSendQuery(conn = conn,
                        "INSERT INTO OpenC2 (UID, Date, Time, Asset_ID, OpenC2_Command, Status_Code, Status_Text)
                           VALUES (?,?,?,?,?,?,?)", list(uuid_time_date_list$uid, uuid_time_date_list$date, uuid_time_date_list$time, consumer$asset_id, json_copy_of_openc2_command, response_message$status, response_message$status_text))
   dbClearResult(query) #frees all resources (local and remote) associated with a result set. In some cases (e.g., very large result sets) this can be a critical step to avoid exhausting resources (memory, file descriptors, etc.)
   dbDisconnect(conn)
   stop(response)
}

#Not Supported Feature in Query-Feature Pair
error_response_target_feature <- function(){
   #Reponse Message
   response_message <- list(status="", status_text="")
   
   #Response Status Code
   #Reference the OpenC2 specifications for the exact meaning of each code
   status_code <- c("102", "200", "400", "500", "501", "503")
   
   uuid_time_date_list <- uuid_time_date() #generates time, date, and UUIDv4
   response_message$status <- status_code[3]
   response_message$status_text <- "Bad Request. Unable to process Command - Not Supported Feature"
   response <- toJSON(response_message,auto_unbox = TRUE, pretty = TRUE)
   assign("response", response, envir = .GlobalEnv ) #assigns response variable - code and text to the Global Environment. This variable can be used from the front-end etc.
   
   conn <- dbConnect(RSQLite::SQLite(), database_name) #creates a database connection
   query <- dbSendQuery(conn = conn,
                        "INSERT INTO OpenC2 (UID, Date, Time, OpenC2_Command, Status_Code, Status_Text)
                           VALUES (?,?,?,?,?,?)", list(uuid_time_date_list$uid, uuid_time_date_list$date, uuid_time_date_list$time, json_copy_of_openc2_command, response_message$status, response_message$status_text))
   dbClearResult(query) #frees all resources (local and remote) associated with a result set. In some cases (e.g., very large result sets) this can be a critical step to avoid exhausting resources (memory, file descriptors, etc.)
   dbDisconnect(conn)
   stop(response)
}

#Actuator Not Alive in Query-Feature Pair
error_response_device_offline <- function(){
   #Reponse Message
   response_message <- list(status="", status_text="")
   
   #Response Status Code
   #Reference the OpenC2 specifications for the exact meaning of each code
   status_code <- c("102", "200", "400", "500", "501", "503")
   
   uuid_time_date_list <- get("uuid_time_date_list", pos = parent.frame())
   consumer <- get("consumer", pos = parent.frame()) #gets consumer details
   
   response_message$status <- status_code[6]
   response_message$status_text <- "Service Unavailable - The Actuator is not Alive"
   response <- toJSON(response_message,auto_unbox = TRUE, pretty = TRUE)
   assign("response", response, envir = .GlobalEnv ) #assigns response variable - code and text to the Global Environment. This variable can be used from the front-end etc.
   
   conn <- dbConnect(RSQLite::SQLite(), database_name) #creates a database connection
   query <- dbSendQuery(conn = conn,
                        "INSERT INTO OpenC2 (UID, Date, Time, Asset_ID, OpenC2_Command, Status_Code, Status_Text)
                           VALUES (?,?,?,?,?,?,?)", list(uuid_time_date_list$uid, uuid_time_date_list$date, uuid_time_date_list$time, consumer$asset_id, json_copy_of_openc2_command, response_message$status, response_message$status_text))
   dbClearResult(query) #frees all resources (local and remote) associated with a result set. In some cases (e.g., very large result sets) this can be a critical step to avoid exhausting resources (memory, file descriptors, etc.)
   dbDisconnect(conn)
   stop(response)
}

#File Not Found in Update-File Pair
error_response_file_not_found <- function(){
   #Reponse Message
   response_message <- list(status="", status_text="")
   
   #Response Status Code
   #Reference the OpenC2 specifications for the exact meaning of each code
   status_code <- c("102", "200", "400", "500", "501", "503")
   
   uuid_time_date_list <- uuid_time_date() #generates time, date, and UUIDv4
   response_message$status <- status_code[4]
   response_message$status_text <- paste("Cannot Access File - File not Found in: ", getwd(),sep ="" )
   response <- toJSON(x = response_message, pretty = TRUE, auto_unbox = TRUE)
   assign("response", response, envir = .GlobalEnv ) #assigns response variable - code and text to the Global Environment. This variable can be used from the front-end etc.
   
   conn <- dbConnect(RSQLite::SQLite(), database_name) #creates a database connection
   query <- dbSendQuery(conn = conn,
                        "INSERT INTO OpenC2 (UID, Date, Time, Asset_ID, OpenC2_Command, Status_Code, Status_Text)
                           VALUES (?,?,?,?,?,?,?)", list(uuid_time_date_list$uid, uuid_time_date_list$date, uuid_time_date_list$time, consumer$asset_id, json_copy_of_openc2_command, response_message$status, response_message$status_text))
   dbClearResult(query) #frees all resources (local and remote) associated with a result set. In some cases (e.g., very large result sets) this can be a critical step to avoid exhausting resources (memory, file descriptors, etc.)
   dbDisconnect(conn)
   stop(response)
}

#File name is not specified
error_response_file_name <- function(){
   
   #Reponse Message
   response_message <- list(status="", status_text="")
   
   #Response Status Code
   #Reference the OpenC2 specifications for the exact meaning of each code
   status_code <- c("102", "200", "400", "500", "501", "503")
   
   uuid_time_date_list <- uuid_time_date() #generates time, date, and UUIDv4
   response_message$status <- status_code[3]
   response_message$status_text <- "Bad Request. Unable to process Command - File Name MUST be Populated"
   response <- toJSON(response_message,auto_unbox = TRUE, pretty = TRUE)
   assign("response", response, envir = .GlobalEnv ) #assigns response variable - code and text to the Global Environment. This variable can be used from the front-end etc.
   
   conn <- dbConnect(RSQLite::SQLite(), database_name) #creates a database connection
   query <- dbSendQuery(conn = conn,
                        "INSERT INTO OpenC2 (UID, Date, Time, OpenC2_Command, Status_Code, Status_Text)
                           VALUES (?,?,?,?,?,?)", list(uuid_time_date_list$uid, uuid_time_date_list$date, uuid_time_date_list$time, json_copy_of_openc2_command, response_message$status, response_message$status_text))
   dbClearResult(query) #frees all resources (local and remote) associated with a result set. In some cases (e.g., very large result sets) this can be a critical step to avoid exhausting resources (memory, file descriptors, etc.)
   dbDisconnect(conn)
   stop(response)
}

#Unable to Parse command at the Actuator/Consumer Side
error_response_consumer_side_parsing <- function(){
   #Reponse Message
   response_message <- list(status="", status_text="")
   
   #Response Status Code
   #Reference the OpenC2 specifications for the exact meaning of each code
   status_code <- c("102", "200", "400", "500", "501", "503")
   
   uuid_time_date_list <- get("uuid_time_date_list", pos = parent.frame()) #gets uuid time and date from the parent environment - the time is more accurate, since it was checked exactly before issuing the command to the actuator
   consumer <- get("consumer", pos = parent.frame()) #gets consumer details
   
   response_message$status <- status_code[3]
   response_message$status_text <- "Bad Request. Unable to process Command"
   response <- toJSON(response_message,auto_unbox = TRUE, pretty = TRUE)
   assign("response", response, envir = .GlobalEnv ) #assigns response variable - code and text to the Global Environment. This variable can be used from the front-end etc.
   
   conn <- dbConnect(RSQLite::SQLite(), database_name) #creates a database connection
   query <- dbSendQuery(conn = conn,
                        "INSERT INTO OpenC2 (UID, Date, Time, Asset_ID, OpenC2_Command,Vendor_Specific_Command, Status_Code, Status_Text)
                           VALUES (?,?,?,?,?,?,?,?)", list(uuid_time_date_list$uid, uuid_time_date_list$date, uuid_time_date_list$time, consumer$asset_id, json_copy_of_openc2_command, vendor_specific_command, response_message$status, response_message$status_text))
   dbClearResult(query) #frees all resources (local and remote) associated with a result set. In some cases (e.g., very large result sets) this can be a critical step to avoid exhausting resources (memory, file descriptors, etc.)
   dbDisconnect(conn)
   stop(response)
}

#Generic function for bad request error code 400
error_response_bad_request_generic <- function(){
   
   #Reponse Message
   response_message <- list(status="", status_text="")
   
   #Response Status Code
   #Reference the OpenC2 specifications for the exact meaning of each code
   status_code <- c("102", "200", "400", "500", "501", "503")
   
   uuid_time_date_list <- uuid_time_date() #generates time, date, and UUIDv4
   response_message$status <- status_code[3]
   response_message$status_text <- "Bad Request"
   response <- toJSON(response_message,auto_unbox = TRUE, pretty = TRUE)
   assign("response", response, envir = .GlobalEnv ) #assigns response variable - code and text to the Global Environment. This variable can be used from the front-end etc.
   
   conn <- dbConnect(RSQLite::SQLite(), database_name) #creates a database connection
   query <- dbSendQuery(conn = conn,
                        "INSERT INTO OpenC2 (UID, Date, Time, OpenC2_Command, Status_Code, Status_Text)
                           VALUES (?,?,?,?,?,?)", list(uuid_time_date_list$uid, uuid_time_date_list$date, uuid_time_date_list$time, json_copy_of_openc2_command, response_message$status, response_message$status_text))
   dbClearResult(query) #frees all resources (local and remote) associated with a result set. In some cases (e.g., very large result sets) this can be a critical step to avoid exhausting resources (memory, file descriptors, etc.)
   dbDisconnect(conn)
   stop(response)
}

#Rule Number Currently in Use ERROR
error_response_consumer_side_rule_number_in_use <- function(){
   #Reponse Message
   response_message <- list(status="", status_text="")
   
   #Response Status Code
   #Reference the OpenC2 specifications for the exact meaning of each code
   status_code <- c("102", "200", "400", "500", "501", "503")
   
   uuid_time_date_list <- get("uuid_time_date_list", pos = parent.frame()) #gets uuid time and date from the parent environment - the time is more accurate, since it was checked exactly before issuing the command to the actuator
   consumer <- get("consumer", pos = parent.frame()) #gets consumer details
   
   response_message$status <- status_code[5]
   response_message$status_text <- "Rule Number Currently in Use"
   response <- toJSON(response_message,auto_unbox = TRUE, pretty = TRUE)
   assign("response", response, envir = .GlobalEnv ) #assigns response variable - code and text to the Global Environment. This variable can be used from the front-end etc.
   
   conn <- dbConnect(RSQLite::SQLite(), database_name) #creates a database connection
   query <- dbSendQuery(conn = conn,
                        "INSERT INTO OpenC2 (UID, Date, Time, Asset_ID, OpenC2_Command,Vendor_Specific_Command, Status_Code, Status_Text)
                           VALUES (?,?,?,?,?,?,?,?)", list(uuid_time_date_list$uid, uuid_time_date_list$date, uuid_time_date_list$time, consumer$asset_id, json_copy_of_openc2_command, vendor_specific_command, response_message$status, response_message$status_text))
   dbClearResult(query) #frees all resources (local and remote) associated with a result set. In some cases (e.g., very large result sets) this can be a critical step to avoid exhausting resources (memory, file descriptors, etc.)
   dbDisconnect(conn)
   stop(response)
}