#The asset_id_mapping() function extracts the asset_id from an OpenC2 command and searches all the network-connection-relevant information in the actuator file. It extracts all the information needed for connecting to an actuator

asset_id_mapping <- function(){
   #Consumer info
   consumer <- list(hostname=NULL, username=NULL, password=NULL, port=NULL, asset_id=NULL, acl_id=NULL, acl_type=NULL)
   #Extracts the actuator(s) info
   consumer$asset_id <- get(x = "i", envir = parent.frame())
   for (j in actuators$asset){
      if (j$asset_id == consumer$asset_id){
         consumer$hostname <- j$network$hostname
         consumer$acl_id <- j$network$acl_id
         consumer$acl_type <- j$network$acl_type
         consumer$username <- j$network$username
         consumer$password <- j$network$password
         if ("port" %in% names(j$network)){
            consumer$port <- j$network$port
         }else consumer$port <- "22"
      }
   }
   return(consumer)
}
