#Generates Time, UUIDv4, Date
uuid_time_date <- function(){
      time <- format(Sys.time(), "%H:%M:%S %p %Z") #the time the commands were executed on an actuator
      #generates a unique identifier for the OpenC2 command - This can be part of the OpenC2 command itself which is the recommended way, since the front end will keep track of all the OpenC2 commands
      uid <- UUIDgenerate(use.time = TRUE) #version 4
      date <- Sys.Date()
      date <- as.character(date)
      uuid_time_date_list <- list(uid=uid,time=time,date=date)
      return(uuid_time_date_list)
}