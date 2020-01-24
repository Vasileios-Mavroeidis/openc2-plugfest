#This file contains functions for success response codes "200" and messages. Everything is saved into a database for later reference.

#Device is alive
successful_response_device_alive <- function(){
      #Reponse Message
      response_message <- list(status="", status_text="")
      
      #Response Status Code
      #Reference the OpenC2 specifications for the exact meaning of each code
      status_code <- c("102", "200", "400", "500", "501", "503")
      
      uuid_time_date_list <- get("uuid_time_date_list", pos = parent.frame())
      consumer <- get("consumer", envir = parent.frame()) #gets the consumer object from the parent environment
      
      response_message$status <- status_code[2]
      response_message$status_text <- "The Actuator is Alive"
      response <- toJSON(response_message,auto_unbox = TRUE, pretty = TRUE)
      assign("response", response, envir = .GlobalEnv ) #assigns response variable - code and text to the Global Environment. This variable can be used from the front-end etc.
      
      conn <- dbConnect(RSQLite::SQLite(), database_name) #creates a database connection
      query <- dbSendQuery(conn = conn,
                           "INSERT INTO OpenC2 (UID, Date, Time, Asset_ID, OpenC2_Command, Status_Code, Status_Text)
                           VALUES (?,?,?,?,?,?,?)", list(uuid_time_date_list$uid, uuid_time_date_list$date, uuid_time_date_list$time, consumer$asset_id, json_copy_of_openc2_command, response_message$status, response_message$status_text))
      dbClearResult(query) #frees all resources (local and remote) associated with a result set. In some cases (e.g., very large result sets) this can be a critical step to avoid exhausting resources (memory, file descriptors, etc.)
      dbDisconnect(conn)
      response_requested() #function that inspects the response_requested argument of the OpenC2 command. 
}


#Success "200" for update, allow, delete commands
successful_response_ok_generic <- function(){

      #Reponse Message
      response_message <- list(status="", status_text="")
      
      #Response Status Code
      #Reference the OpenC2 specifications for the exact meaning of each code
      status_code <- c("102", "200", "400", "500", "501", "503")
      
      uuid_time_date_list <- get("uuid_time_date_list", envir = parent.frame())
      
      response_message$status <- status_code[2]
      response_message$status_text <- "OK"
      response <- toJSON(x = response_message, pretty = TRUE, auto_unbox = TRUE)
      assign("response", response, envir = .GlobalEnv ) #assigns response variable - code and text to the Global Environment. This variable can be used from the front-end etc.
      
      consumer <- get("consumer",envir = parent.frame()) #gets the consumer object from the parent environment
      
      conn <- dbConnect(RSQLite::SQLite(), database_name) #creates a database connection
      query <- dbSendQuery(conn = conn,
                           "INSERT INTO OpenC2 (UID, Date, Time, Asset_ID, OpenC2_Command,Vendor_Specific_Command, Status_Code, Status_Text)
                           VALUES (?,?,?,?,?,?,?,?)", list(uuid_time_date_list$uid, uuid_time_date_list$date, uuid_time_date_list$time, consumer$asset_id, json_copy_of_openc2_command, vendor_specific_command, response_message$status, response_message$status_text))
      dbClearResult(query) #frees all resources (local and remote) associated with a result set. In some cases (e.g., very large result sets) this can be a critical step to avoid exhausting resources (memory, file descriptors, etc.)
      dbDisconnect(conn)
      response_requested() #function that inspects the response_requested argument of the OpenC2 command. 
}
