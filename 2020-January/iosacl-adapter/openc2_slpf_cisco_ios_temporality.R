#function that inspects the temporal args of an OpenC2 Command, such as start_time, stop_time, and duration
temporal <- function(){
      if (is.null(openc2$args$start_time)==FALSE && is.null(openc2$args$stop_time)==FALSE){#if the start_time and stop_time exists
            time_range_name <<- paste("time_range_name", Sys.Date(), format(Sys.time(), "-%H-%M-%S",),sep = "") #creates a time range name for a cisco ios device
            start_time <- format(as.POSIXlt(openc2$args$start_time/1000, tz = "", origin = "1970-1-1"), "%H:%M %d %B %Y") #converts milliseconds to seconds and translates to Cisco ios format
            stop_time <- format(as.POSIXlt(openc2$args$stop_time/1000, tz = "", origin = "1970-1-1"), "%H:%M %d %B %Y")
            
            entry_three <- paste("time-range", time_range_name, sep = " ") #the command that is submitted to a cisco ios device
            entry_four <- paste("absolute start", start_time, "end", stop_time, sep = " ")
            command_set <- list(entry_three, entry_four)
      }else if (is.null(openc2$args$start_time)==FALSE && is.null(openc2$args$stop_time)==TRUE){ #If the start_time exists and stop_time is not populated it checks for existing duration argument
            
            if (is.null(openc2$args$duration)==FALSE){ #the duration per OpenC2 is defined in milliseconds - if the duration argument is populated - it calculates the stop time
                  time_range_name <<- paste("time_range_name", Sys.Date(), format(Sys.time(), "-%H-%M-%S",),sep = "") #creates a time range name for a cisco ios device
                  start_time <- format(as.POSIXlt(openc2$args$start_time/1000, tz = "", origin = "1970-1-1"), "%H:%M %d %B %Y") #converts milliseconds to seconds and translates to Cisco ios format
                  duration <- openc2$args$start_time + openc2$args$duration #duration is in milliseconds
                  stop_time <- format(as.POSIXlt(duration/1000, tz = "", origin = "1970-1-1"), "%H:%M %d %B %Y") #the stop time is the start_time + the duration
                  
                  entry_three <- paste("time-range", time_range_name, sep = " ") #the command that is submitted to a cisco ios device
                  entry_four <- paste("absolute start", start_time, "end", stop_time, sep = " ")
                  command_set <- list(entry_three, entry_four)
            }else{ #the duration arg is not populated -  the end time is infinite - only the start field is populated in cisco ios syntax
                  time_range_name <<- paste("time_range_name", Sys.Date(), format(Sys.time(), "-%H-%M-%S",),sep = "") #creates a time range name for a cisco ios device
                  start_time <- format(as.POSIXlt(openc2$args$start_time/1000, tz = "", origin = "1970-1-1"), "%H:%M %d %B %Y") #converts milliseconds to seconds and translates to Cisco ios format
                  
                  entry_three <- paste("time-range", time_range_name, sep = " ") #the command that is submitted to a cisco ios device
                  entry_four <- paste("absolute start", start_time, sep = " ")
                  command_set <- list(entry_three, entry_four)
            }
      }else if (is.null(openc2$args$start_time)==FALSE){  #if the start_time argument is not populated
      }
}