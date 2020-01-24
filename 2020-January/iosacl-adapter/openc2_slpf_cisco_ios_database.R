#RSQLite
###########################!!NOTE!!##########################
#############################################################
#SQLite vs SQL                                              #
#"Lite" version of SQL                                      #
#Supports most of the SQL syntax                            #
#No user management                                         #
#Only single writer at a time                               #
#Best for mobile applications                               #
#NOT for big-scale data                                     #
#NOT for enterprises due to security reasons                #
#############################################################
###########################!!NOTE!!##########################

database <- function(){
   database_name <- "openc2.db"
   assign("database_name", database_name, envir = .GlobalEnv)
   #Checks if the DB "openc2.db" exists. If not creates the DB and the appropriate Table.
   if (!database_name %in% dir(working_directory)){
      conn <- dbConnect(RSQLite::SQLite(), "openc2.db") #creates the DB or connects to the database
      dbSendQuery(conn = conn,
                  "CREATE TABLE OpenC2
                  (UID TEXT,
                  Date TEXT,
                  Time TEXT,
                  Asset_ID TEXT,
                  OpenC2_Command TEXT,
                  Vendor_Specific_Command TEXT,
                  Status_Code TEXT,
                  Status_Text TEXT)")
      dbDisconnect(conn)
   }
}