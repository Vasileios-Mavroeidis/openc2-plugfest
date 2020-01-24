#response_requested argument - Supports "complete" and "none" - Its supported only for commands that have been consumed successfully Error codes will still print as response_requested:"complete" 
response_requested <- function() {
      if (is.null(openc2$args$response_requested) || openc2$args$response_requested == "complete"){  #the response_requested argument is NULL and is treated as complete, or the response_requested argument is complete
            response <- get(x = "response", envir = parent.frame())
            print (response)
      }else if (openc2$args$response_requested == "none"){
            #no response
      }    
}
