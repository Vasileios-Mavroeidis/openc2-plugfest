#This function checks the 5 tuple and extracts the appropriate information. Treats missing values as "any"

five_tuple_extractor <- function(){
   #checks source address 
   if (exists("src_addr", openc2$target[[1]])==TRUE){
      ACL$source_addr <<- openc2$target[[1]]$src_addr
   }else ACL$source_addr <<- "any"
   #checks destination address 
   if (exists("dst_addr", openc2$target[[1]])==TRUE){
      ACL$destination_addr <<- openc2$target[[1]]$dst_addr
   }else ACL$destination_addr <<- "any"
   #checks source port
   if (exists("src_port", openc2$target[[1]])==TRUE){
      if (is.na(str_extract(openc2$target[[1]]$src_port, "[[:alnum:]]{1,5}\\:[[:alnum:]]{1,5}"))==FALSE){
         port <- str_replace(string = openc2$target[[1]]$src_port, pattern = ":", replacement = " " )
         ACL$source_operator_port <<- paste("range", port, sep = " ")
      }else if (is.na(str_extract(openc2$target[[1]]$src_port, "[[:digit:]]{1,5}"))==FALSE){
         port <- str_extract(openc2$target[[1]]$src_port, "[[:digit:]]{1,5}")
         ACL$source_operator_port <<- paste("eq", port, sep = " ")
      }
   }#else ACL$source_operator_port <<- "any" (Note: Ommited port in a Cisco ACL is treated as any)
   #checks destination port
   if (exists("dst_port", openc2$target[[1]])==TRUE){
      if (is.na(str_extract(openc2$target[[1]]$dst_port, "[[:alnum:]]{1,5}\\:[[:alnum:]]{1,5}"))==FALSE){
         port <- str_replace(string = openc2$target[[1]]$dst_port, pattern = ":", replacement = " " )
         ACL$destination_operator_port <<- paste("range", port, sep = " ")
      }else if (is.na(str_extract(openc2$target[[1]]$dst_port, "[[:digit:]]{1,5}"))==FALSE){
         port <- str_extract(openc2$target[[1]]$dst_port, "[[:digit:]]{1,5}")
         ACL$destination_operator_port <<- paste("eq", port, sep = " ")
      }
   }#else ACL$destination_operator_port <<- "any" (Note: Ommited port in a Cisco ACL is treated as any)
   #checks protocol
   if (exists("protocol", openc2$target[[1]])==TRUE){
      if (openc2$target[[1]]$protocol == "tcp"){
         ACL$protocol <<- openc2$target[[1]]$protocol
      }else if (openc2$target[[1]]$protocol=="udp"){
         ACL$protocol <<- openc2$target[[1]]$protocol
      }else if (openc2$target[[1]]$protocol == "icmp"){
         ACL$protocol <<- openc2$target[[1]]$protocol
         ACL$icmp_type <<- openc2$target[[1]]$icmp_type
         ACL_icmp_code <<- openc2$target[[1]]$icmp_code
         if ("src_port" %in% names(openc2$target[[1]])  || "dst_port"  %in% names(openc2$target[[1]])  ){
            stop("ICMP protocol cannot have ports specified - Invalid OpenC2 Command", call= TRUE)
         }
      }else stop("WRONG Protocol")
   }else stop("Protocol should be specified")
}
