#The PoC includes extra functionality such as multiple checks that normally an orchestrator should do. Removing those checking mechanisms and using this code purely as a block for processing OpenC2 commands would improve its runtime performance.
main <- function(){
   
   #################################################################################################################################################
   #Copies OpenC2 command. It is inserted later into the database
   json_copy_of_openc2_command <<- toJSON(openc2,pretty = TRUE, auto_unbox = TRUE)
   #################################################################################################################################################
   
   #options(digits.secs = 6) #sets the System time to show miliseconds
   options("scipen" = 10)
   
   ##################################Cisco IOS ACL Syntax##################################
   #Cisco action list
   cisco_action_list <<- list("permit", "deny") #input for the "action" list element in the [ACL list] below
   #Protocol list
   protocol <<- list("tcp","udp", "icmp")
   #Cisco access list
   cisco_access_list <<- list("ip access-list", "ipv6 access-list") #input for the "access_list" list element in the [ACL list] below
   #Cisco access list type
   cisco_access_list_type <<- list("standard", "extended")
   
   #Cisco ACL
   ACL <<- list(access_list = "", access_list_type = "", access_list_number_or_name="", action="", protocol="", source_addr="",
                source_wildcard="", source_operator_port="",
                destination_addr="", destination_wildcard="",
                destination_operator_port="", time_range="")
   
   #Reponse Message
   response_message <- list(status="", status_text="")
   #Response Status Code
   #Reference the OpenC2 specifications for the exact meaning of each code
   status_code <- c("102", "200", "400", "500", "501", "503")
   
   ###########################################################################################
   
   #Supported Language Specification Versions (QUERY:FEATURES)
   #This PoC focuses on developing a piece of code that can be integrated in a OpenC2 Proxy, the capabilities of the actuator are "harcoded" in the code. In a normal schenario where an actuator supports a native OpenC2 interface this information should be provided directly from the actuator.
   versions <- list("1.0")
   
   #Supported Profiles (QUERY:FEATURES)
   #This PoC focuses on developing a piece of code that can be integrated in a OpenC2 Proxy, the capabilities of the actuator are "harcoded" in the code. In a normal schenario where an actuator supports a native OpenC2 interface this information should be provided directly from the actuator.
   profiles <- ("slpf")
   
   #Supported Pairs (QUERY:FEATURES)
   # This PoC focuses on developing a piece of code that can be integrated in a OpenC2 Proxy, the capabilities of the actuator are "harcoded" in the code. In a normal schenario where an actuator supports a native OpenC2 interface this information should be provided directly from the actuator.
   allow <- list("ipv4_connection", "ipv6_connection")
   deny <- list("ipv4_connection", "ipv6_connection")
   update <- list("file")
   query <- list("features")
   delete <- list("slpf:rule_number")
   pairs <- list(allow=allow, deny=deny,query=query, update=update, delete=delete)
   
   ##################################################################################################################################################################
   #Functions that parse an OpenC2 action with the purpose of calling the appropriate transport function
   openc2_action_ipv4_connection <- function(){
      if (openc2$action == "allow"){
         ACL$action <<- cisco_action_list[1]
         openc2_slpf_cisco_ios_TRANSPORT_allow_deny(slpf_action = openc2_slpf_cisco_ios_ACTION_allow_deny_ipv4_connection)
         ACL$access_list_number_or_name <<- acl_id
      }else if (openc2$action == "deny"){
         ACL$action <<- cisco_action_list[2]
         openc2_slpf_cisco_ios_TRANSPORT_allow_deny(slpf_action = openc2_slpf_cisco_ios_ACTION_allow_deny_ipv4_connection)
         ACL$access_list_number_or_name <<- acl_id
      }
   }
   
   openc2_action_ipv6_connection <- function(){
      if (openc2$action == "allow"){
         ACL$action <<- cisco_action_list[1]
         openc2_slpf_cisco_ios_TRANSPORT_allow_deny(slpf_action = openc2_slpf_cisco_ios_ACTION_allow_deny_ipv6_connection)
         ACL$access_list_number_or_name <<- acl_id
      }else if (openc2$action == "deny"){
         ACL$action <<- cisco_action_list[2]
         openc2_slpf_cisco_ios_TRANSPORT_allow_deny(slpf_action = openc2_slpf_cisco_ios_ACTION_allow_deny_ipv6_connection)
         ACL$access_list_number_or_name <<- acl_id
      }
   }
   
   openc2_action_update <- function(){
      openc2_slpf_cisco_ios_TRANSPORT_update()
   }
   
   openc2_action_delete <- function(){
      openc2_slpf_cisco_ios_TRANSPORT_delete(slpf_action = openc2_slpf_cisco_ios_ACTION_delete_slpf_rule_number)
   }
   ##################################################################################################################################################################
   
   ##################################################################################################################################################################
   #Extracts OpenC2 TARGET, evaluates conformance, and calls the relevant OpenC2 action function
   #Maps to Cisco ACL
   ##################################################################################################################################################################
   if (names(openc2$target) == "ipv4_net"){ #TARGET: IPV4_NET - standard IPv4 ACL
      ACL$access_list <<- cisco_access_list[1] #access_list notation is "access-list"
      #not supported
      response_message$status <<- status_code[5]
      response_message$status_text <<- "Command Not Supported"
      response <<- toJSON(x = response_message, pretty = TRUE, auto_unbox = TRUE)
      stop(response)
   }else if (names(openc2$target) == "ipv6_net"){ #TARGET: IPV6_NET - standard IPv6 list - IPv6 ACLs do not use wildcard masks. Instead, the prefix-length is used to indicate how much of an IPv6 source or destination address should be matched
      ACL$access_list <<- cisco_access_list[2] #access_list notation is "IPv6 access-list"
      #not supported
      response_message$status <<- status_code[5]
      response_message$status_text <<- "Command Not Supported"
      response <<- toJSON(x = response_message, pretty = TRUE, auto_unbox = TRUE)
      stop(response)
   }else if (names(openc2$target) == "ipv4_connection" && length(openc2$target) == 1){ #TARGET: IPV4_CONNECTION - extended IPv4 ACL
      if (openc2$action=="allow" || openc2$action=="deny"){
         ACL$access_list <<- cisco_access_list[1] #access_list notation is "ip access-list"
         ACL$access_list_type <<- cisco_access_list_type[2]
         five_tuple_extractor()
         ##################################################################################################################################################################
         #Calculates the wildcard mask for the ACL rule
         ##################################################################################################################################################################
         if(!is.null(openc2$target$ipv4_connection$src_addr)){
            ipnet(openc2$target$ipv4_connection$src_addr)
            ACL$source_wildcard <<- wildcard
         }
         if(!is.null(openc2$target$ipv4_connection$dst_addr)){
            ipnet(openc2$target$ipv4_connection$dst_addr)
            ACL$destination_wildcard <<- wildcard
         }
         ##################################################################################################################################################################
         openc2_action_ipv4_connection() #calls the ipv4 action function
      }else { #not supported action-target pair
         error_response_action_target_argument_pair()
      } 
   }else if (names(openc2$target) == "ipv6_connection" && length(openc2$target) == 1){ #TARGET: IPV6_CONNECTION - extended IPv6 ACL - IPv6 ACLs do not use wildcard masks. Instead, the prefix-length is used to indicate how much of an IPv6 source or destination address should be matched
      if (openc2$action=="allow" || openc2$action=="deny"){
         ACL$access_list <<- cisco_access_list[2] #access_list notation should be "ipv6 access-list"
         five_tuple_extractor()
         openc2_action_ipv6_connection() #calls the action function
      }else { #not supported action-target pair
         error_response_action_target_argument_pair()
      } 
   }else if (names(openc2$target) == "file") { #TARGET:FILE
      if (openc2$action=="update"){
         if (is.null(openc2$target$file$name)==TRUE){ #file name is not specified/populated in the OpenC2 command
            error_response_file_name()
         }else if (is.null(openc2$target$file$name)==FALSE && is.null(openc2$target$file$path)==TRUE){# if the filename is given and the path is not, checks if the file exists in the working directory
            if (openc2$target$file$name %in% dir(working_directory)==TRUE){ #if the file exists in the working directory it parses the file (commands)
               update_file <<- openc2$target$file$name
            }else {
               error_response_file_not_found() #file not found
            }
         }else if (is.null(openc2$target$file$name)==FALSE && is.null(openc2$target$file$path)==FALSE){ #if the filename and the path are given, it combines them to find the file to read
            if (endsWith(openc2$target$file$path, suffix = "/")==TRUE){
               update_file <<- paste0(openc2$target$file$path, openc2$target$file$name,collapse = "") #reads the file
            }else update_file <<- paste0(openc2$target$file$path, openc2$target$file$name,collapse = "/")
         }
         read_update_file <- read_file(file= update_file) #reads the file that is to be pushed to the consumer. The object is used for submitting the commands into the database
         assign("vendor_specific_command",value = read_update_file, envir = .GlobalEnv) #assigns the variable to the global environment
         openc2_action_update() #calls the openc2_action() action function
      }else{
         error_response_action_target_argument_pair() #not supported action-target pair; Update - File
      }
   }else if (names(openc2$target) == "features") { #QUERY:FEATURES
      if (openc2$action == "query"){
         if (is.null(openc2$args)==TRUE || openc2$args$response_requested=="complete"){
            if (length(openc2$target$features)==0){ #an array of length 0 [] is used to check if an asset_id is alive. Note: that asset_id(s) need to be specified in the OpenC2 command
               if(is.null(openc2$actuator$slpf$asset_id)==FALSE){ #actuator asset_id is specified
                  #Extracts the "actuators" from the OpenC2 command and assigns them to a new variable. The action must be one but the actuators can be many. 
                  actuator_specifier <- openc2$actuator$slpf
                  #Extracts the actuator(s) info, initiates a connection to the end-point, and submits the commands.
                  for (i in actuator_specifier){ #the for loop extracts info from the asset id one by one in case there is more than one
                     consumer <- asset_id_mapping()
                     uuid_time_date_list <- uuid_time_date() #generates time, date, and UUIDv4
                     
                     #Checks if the device is alive
                     x <- tryCatch({
                        connection <- netmiko$ConnectHandler(device_type = "cisco_xe", ip = consumer$hostname, username = consumer$username, port = consumer$port, use_keys='True', key_file="gcp.txt")
                     },
                     error = function(cond){
                        assign("device_off",value = TRUE,envir = .GlobalEnv) #if we catch an error (asset/device is offline) we generate the variable "device_off" with a TRUE value. This allows the next if statement to generate the appropriate response messages (status_code, status_text) 
                     }
                     )
                     
                     if (exists("device_off")==FALSE){ #if the object device_off is not found (device is ALIVE) then generate the appropriate response messages and add them into the database
                        successful_response_device_alive()
                     }else{ #if the object device_off is found (device is OFFLINE) then generate the appropriate response messages and submit them into the database
                        error_response_device_offline()
                     }
                  }
               }else { #actuator asset_id is not specified - error function is called
                  error_response_asset_id() 
               }
            }else if (length(openc2$target$features) >= 1){
               checker <- list(versions="", profiles="", pairs="")
               results <- list()
               for (feature in openc2$target$features){
                  if (feature=="versions"){
                     checker$versions=1
                  }else if (feature=="profiles"){
                     checker$profiles=1
                  }else if (feature=="pairs"){
                     checker$pairs=1
                  }else { #if the feature in the OpenC2 command is not one of the above, issue an error code and save the response into the database
                     error_response_target_feature() #wrong feature in the target
                  }
               }
               z <- 0
               if (checker$versions==1){
                  results <- append(results,values = versions )
                  z <- z+1
                  names(results)[z] <- "versions"
               }
               if (checker$profiles==1){
                  results <- append(results,values = profiles )
                  z <- z+1
                  names(results)[z] <- "profiles"
               }
               if (checker$pairs==1){
                  pairs <- list(pairs=pairs)
                  results <- append(results,values = pairs)
               }
               response_message$status <- status_code[2]
               results <- list(status=response_message$status, results=results)  #results are appended to the status message
               response <- toJSON(x = results, pretty = TRUE, auto_unbox = TRUE)
               uuid_time_date_list <- uuid_time_date() #generates time, date, and UUIDv4
               conn <- dbConnect(RSQLite::SQLite(), database_name) #creates a database connection
               query <- dbSendQuery(conn = conn,
                                    "INSERT INTO OpenC2 (UID, Date, Time, OpenC2_Command, Status_Code, Status_Text)
                           VALUES (?,?,?,?,?,?)", list(uuid_time_date_list$uid, uuid_time_date_list$date, uuid_time_date_list$time, json_copy_of_openc2_command, response_message$status, response_message$status_text))
               dbClearResult(query) #frees all resources (local and remote) associated with a result set. In some cases (e.g., very large result sets) this can be a critical step to avoid exhausting resources (memory, file descriptors, etc.)
               dbDisconnect(conn)
               response
            }
         }else { #if any argument else than "response_requested: complete" exists then the execution stops and the appropriate error response message is issued
            error_response_bad_request_generic()
         }
      }else { #if the action is not query but the target is feature (QUERY:FEATURE) then the execution stops and the appropriate error response message is issued
         error_response_action_target_argument_pair() #wrong action-target pair
      }
   }else if (names(openc2$target) == "slpf:rule_number" && length(openc2$target) == 1){ #TARGET: SLPF:RULE_NUMBER (DELETE:SLPF:RULE_NUMBER)
      if (openc2$action == "delete"){ #the action can be only "delete"
         if(is.null(openc2$actuator$slpf$asset_id)==FALSE){#actuator asset_id is specified
            if (is.null(openc2$args)==TRUE || openc2$args$response_requested=="complete"){
               openc2_action_delete() #call openc2_action() action function
            }else{ #if any argument else than "response_requested: complete" exists then the execution stops and the appropriate error response message is issued
               error_response_action_target_argument_pair()
            }  
         }else{#actuator asset_id is not specified
            error_response_asset_id() #no asset_id specified
         }
      }else {
         error_response_action_target_argument_pair() #wrong action-target pair
      }
   }else{
      error_response_bad_request_generic() #the target MUST include exactly one rule_number 
   }
}
##################################################################################################################################################################