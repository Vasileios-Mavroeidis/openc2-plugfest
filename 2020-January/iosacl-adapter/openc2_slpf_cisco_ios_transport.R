#Supported specifiers according to the SLPF specification are: 1-hostname(domain or ip), 2-named_group(for pub/sub very useful), 3-asset_id(unique identifier for a particular slpf), 4-asset_tuple(unique tuple identifier for a particular slpf consisting of a list of up to 10 strings).
#This implementation (PoC) supports only "asset_id"

###############################################################################################################
#Transport function for actions "allow" or "deny" with "IPV4_Connection" or "IPV6_Connection target
###############################################################################################################
openc2_slpf_cisco_ios_TRANSPORT_allow_deny <- function(slpf_action){
   #Extracts the "actuator(s)" details from the OpenC2 command and assigns them to a new variable. The action must be one but the actuators can be many. 
   actuator_specifier <- openc2$actuator$slpf 
   
   #Extracts the actuator(s) info, opens a connection (consumer side) and submits the commands.
   for (i in actuator_specifier){
      consumer <- asset_id_mapping() #extracts info from the actuator file based on the asset_id(s) specified
      assign("acl_id", value = consumer$acl_id, envir = .GlobalEnv) #assigns the acl_id in the global environment. From there it is assigned to the ACL$access_list_number_or_name
      
      #Takes the argument from the function that defines which function from the "openc2_slpf_cisco_ios_action.R file we have to run to bring the appropriate sequence of commands back for submission using netmiko. This function brings in the current environment a list named "commands". The commands are parsed one-by-one and submitted to the consumer
      commands <- slpf_action()
      commands <- unlist(commands)
      
      #Netmiko (python library) is used to initiate a connection to the consumer and submit/issue the commands
      #Username and Password are used. Replace with token or different authentication mechanisms in the front end technology and openc2proxy (encryption should be supported)
      connection <- netmiko$ConnectHandler(device_type = "cisco_xe", ip = consumer$hostname, username = consumer$username, port = consumer$port, use_keys='True', key_file="gcp.txt")
      
      #Generates Time, UUIDv4, Date
      uuid_time_date_list <- uuid_time_date()
      
      #Checks if the changes have to be persistent or not
      if (is.null(openc2$args$slpf$persistent) || openc2$args$slpf$persistent==TRUE){
         #Issues the commands needed for the configuration and the ACE
         output <- connection$send_config_set(config_commands = commands)
         output1 <- connection$save_config()
      }else if (openc2$args$slpf$persistent==FALSE) {
         #Issues the commands needed for the configuration and the ACE
         output <- connection$send_config_set(config_commands = commands)
      }
      connection$disconnect() #disconnects the session after executing the commands
      
      assign("vendor_specific_command", value = paste(commands, collapse = "; "), envir = .GlobalEnv) #flattens the commands before inserting them into the database
      
      if (grepl("Invalid input detected at", output, fixed = TRUE) == TRUE || grepl("% Ambiguous command:", output, fixed = TRUE) == TRUE){
         error_response_consumer_side_parsing() #consumer didnt parse the command correctly. Most probably wrong syntax. Generates response object and submits it into the database
      }else if (grepl("% Duplicate sequence number", output, fixed = TRUE) == TRUE) { #rule number currently in use error
         error_response_consumer_side_rule_number_in_use()
      }else{
         successful_response_ok_generic() #generates response object and submits it into the database
      }
   }
}
###############################################################################################################
###############################################################################################################

###############################################################################################################
#Transport function for action "update" with "file" target
###############################################################################################################
openc2_slpf_cisco_ios_TRANSPORT_update <- function(){
   #Extracts the "actuator(s)" details from the OpenC2 command and assigns them to a new variable. The action must be one but the actuators can be many.
   actuator_specifier <- openc2$actuator$slpf 
   
   #Extracts the actuator(s) info, opens a connection (consumer side) and submits the commands
   for (i in actuator_specifier){
      consumer <- asset_id_mapping() #extracts info from the actuator file based on the asset_id(s) specified
      
      #Netmiko (python library) is used to initiate a connection to the consumer and submit/issue the commands
      #Username and Password are used. Replace with token or different authentication mechanisms in the front end technology and openc2proxy (encryption should be supported)
      connection <- netmiko$ConnectHandler(device_type = "cisco_xe", ip = consumer$hostname, username = consumer$username, port = consumer$port, use_keys='True', key_file="gcp.txt")
      
      #Generates Time, UUIDv4, Date
      uuid_time_date_list <- uuid_time_date()
      
      #Issues the commands needed for the configuration and the ACE
      output <- connection$send_config_from_file(update_file)
      output1 <- connection$save_config() #saves configuration file "copy running-config startup-config" - according to the SLPF spec. When updating a configuration file the changes are always persistent.
      connection$disconnect() #disconnects the session after executing the commands
      
      if (grepl("Invalid input detected at", output, fixed = TRUE) == FALSE || grepl("% Ambiguous command:", output, fixed = TRUE) == FALSE){
         successful_response_ok_generic() #generates response object and submits it into the database
      }else { #if invalid input is detected
         error_response_consumer_side_parsing() #consumer didnt parse the command correctly. Most probably wrong syntax. Generates response object and submits it into the database
      }
   }
}
###############################################################################################################
###############################################################################################################

###############################################################################################################
#Transport function for action "delete" with "slpf:rule_number" target
###############################################################################################################
openc2_slpf_cisco_ios_TRANSPORT_delete <- function(slpf_action){
   #Extracts the "actuator(s)" from the OpenC2 command and assigns them to a new variable. The action must be one but the actuators can be many. 
   actuator_specifier <- openc2$actuator$slpf 
   
   #Extracts the actuator(s) info, opens a connection (consumer side) and submits the commands
   for (i in actuator_specifier){
      consumer <- asset_id_mapping() #extracts info from the actuator file based on the asset_id(s) specified
      assign("acl_id", value = consumer$acl_id, envir = .GlobalEnv) #assigns the acl_id in the global environment. From there it is assigned to the ACL$access_list_number_or_name
   
      if (consumer$acl_type=="ipv4"){ #if the consumer_id is binded with an IPv4 ACL then:
         ACL$access_list <<- cisco_access_list[1]
         ACL$access_list_type <<- cisco_access_list_type[2]
      }else if (consumer$acl_type=="ipv6"){ #if the consumer_id is binded with an IPv6 ACL then:
         ACL$access_list <<- cisco_access_list[2]
      }else{
         #stop execution if needed and issue response message
      }
      
      #Takes the argument from the function that defines which function from the "openc2_slpf_cisco_ios_action.R file we have to run to bring the appropariate sequence of commands back for submitting using netmiko. This function brings in the present environment a list named "commands". The commands are parsed one-by-one and submitted to the consumer
      commands <- slpf_action()
      commands <- unlist(commands)
      
      #Netmiko (python library) is used to initiate a connection to the consumer and submit/issue the commands
      #Username and Password are used. Replace with token or different authentication mechanisms in the front end technology and openc2proxy (encryption should be supported)
      connection <- netmiko$ConnectHandler(device_type = "cisco_xe", ip = consumer$hostname, username = consumer$username, port = consumer$port, use_keys='True', key_file="gcp.txt")
      
      #Generates Time, UUIDv4, Date
      uuid_time_date_list <- uuid_time_date()
      
      #Issues the commands needed for the configuration and the ACE
      output <- connection$send_config_set(config_commands = commands)
      connection$disconnect() #disconnects the session after executing the commands
      
      assign("vendor_specific_command", value = paste(commands, collapse = "; "), envir = .GlobalEnv) #flattens the commands to insert into the database
      
      if (grepl("Invalid input detected at", output, fixed = TRUE) == FALSE || grepl("% Ambiguous command:", output, fixed = TRUE) == FALSE){
         successful_response_ok_generic() #generates response object and submits into the database
      }else {
         error_response_consumer_side_parsing() #consumer didnt parse the command correctly. Most probably wrong syntax. Generates response object and submits into the database
      }
   }
}
###############################################################################################################
###############################################################################################################