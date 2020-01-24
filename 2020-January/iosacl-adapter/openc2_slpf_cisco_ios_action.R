#OpenC2 Action:allow or deny with Target: ipv4_connection
openc2_slpf_cisco_ios_ACTION_allow_deny_ipv4_connection <- function(){
   if (is.null(openc2$args$slpf$insert_rule)==FALSE){ #if the SLPF argument insert_rule is populated and
      if(!is.null(openc2$args$response_requested) && openc2$args$response_requested=="complete"){#if the argument response_requested:complete is populated"
         command_set1 <- temporal() #checks for time arguments
         rule_number <- openc2$args$slpf$insert_rule 
         if (is.null(command_set1)==TRUE){ #if the OpenC2 command does not include any time arguments
            entry_one <- paste(ACL$access_list, ACL$access_list_type, acl_id)
            entry_two <- paste(rule_number, ACL$action, ACL$protocol, ACL$source_addr, ACL$source_wildcard, ACL$source_operator_port, ACL$destination_addr, ACL$destination_wildcard, ACL$destination_operator_port)
            command_set2 <- list(entry_one, entry_two)
            commands <- list(command_set1, command_set2)
            return(commands)
         }else if (is.null(command_set1)==FALSE){ #if the OpenC2 command includes time arguments
            entry_one <- paste(ACL$access_list, ACL$access_list_type, acl_id)
            entry_two <- paste(rule_number, ACL$action, ACL$protocol, ACL$source_addr, ACL$source_wildcard, ACL$source_operator_port, ACL$destination_addr, ACL$destination_wildcard, ACL$destination_operator_port, "time-range", time_range_name,sep = " ")
            command_set2 <- list(entry_one, entry_two)
            commands <- list(command_set2, command_set1)
            return(commands)
         }
      }else{ #if the argument "response_requested:complete" is not populated, the appropriate error response is issued and the execution stops
         consumer <- get("consumer", envir = parent.frame())
         error_response_action_target_argument_pair()
      }
   }else{ #if the SLPF argument insert_rule is not populated
      command_set1 <- temporal() #checks for time arguments
      if (is.null(command_set1)==TRUE){ #if the OpenC2 command does not include any time arguments
         entry_one <- paste(ACL$access_list, ACL$access_list_type, acl_id)
         entry_two <- paste(ACL$action, ACL$protocol, ACL$source_addr, ACL$source_wildcard, ACL$source_operator_port, ACL$destination_addr, ACL$destination_wildcard, ACL$destination_operator_port)
         command_set2 <- list(entry_one, entry_two)
         commands <- list(command_set1, command_set2)
         return(commands)
      }else if (is.null(command_set1)==FALSE){ #if the OpenC2 command includes time arguments
         entry_one <- paste(ACL$access_list, ACL$access_list_type, acl_id)
         entry_two <- paste(ACL$action, ACL$protocol, ACL$source_addr, ACL$source_wildcard, ACL$source_operator_port, ACL$destination_addr, ACL$destination_wildcard, ACL$destination_operator_port, "time-range", time_range_name,sep = " ")
         command_set2 <- list(entry_one, entry_two)
         commands <- list(command_set1, command_set2)
         return(commands)
      }
   }
}

#OpenC2 Action: allow or deny with Target ipv6_connection
openc2_slpf_cisco_ios_ACTION_allow_deny_ipv6_connection <- function(){
   if (is.null(openc2$args$slpf$insert_rule)==FALSE){ #if the SLPF argument insert_rule is populated and
      if(!is.null(openc2$args$response_requested) && openc2$args$response_requested=="complete"){ #if the argument response_requested:complete is populated"
         command_set1 <- temporal() #checks for time arguments
         rule_number <- openc2$args$slpf$insert_rule 
         if (is.null(command_set1)==TRUE){ #if the OpenC2 command does not include any time arguments
            entry_one <- paste(ACL$access_list, acl_id)
            entry_two <- paste(ACL$action, ACL$protocol, ACL$source_addr, ACL$source_operator_port, ACL$destination_addr, ACL$destination_operator_port, "sequence", rule_number)
            command_set2 <- list(entry_one, entry_two)
            commands <- list(command_set1, command_set2)
            return(commands)
         }else if (is.null(command_set1)==FALSE){ #if the OpenC2 command includes time arguments
            entry_one <- paste(ACL$access_list, acl_id)
            entry_two <- paste(ACL$action, ACL$protocol, ACL$source_addr, ACL$source_operator_port, ACL$destination_addr, ACL$destination_operator_port, "sequence", rule_number, "time-range", time_range_name,sep = " ")
            command_set2 <- list(entry_one, entry_two)
            commands <- list(command_set2, command_set1)
            return(commands)
         }
      }else{ #if the argument "response_requested:complete" is not populated, the appropriate error response is issued and the execution stops
         consumer <- get("consumer", envir = parent.frame())
         error_response_action_target_argument_pair()
      }
   }else{ #if the SLPF argument insert_rule is not populated
      command_set1 <- temporal() #checks for time arguments
      if (is.null(command_set1)==TRUE){ #if the OpenC2 command does not include any time arguments
         entry_one <- paste(ACL$access_list, acl_id)
         entry_two <- paste(ACL$action, ACL$protocol, ACL$source_addr, ACL$source_operator_port, ACL$destination_addr, ACL$destination_operator_port)
         command_set2 <- list(entry_one, entry_two)
         commands <- list(command_set1, command_set2)
         return(commands)
      }else if (is.null(command_set1)==FALSE){ #if the OpenC2 command includes time arguments
         entry_one <- paste(ACL$access_list, acl_id)
         entry_two <- paste(ACL$action, ACL$protocol, ACL$source_addr, ACL$source_operator_port, ACL$destination_addr, ACL$destination_operator_port, "time-range", time_range_name,sep = " ")
         command_set2 <- list(entry_one, entry_two)
         commands <- list(command_set1, command_set2)
         return(commands)
      }
   }
}

#OpenC2 Action: delete with Target: slpf:rule_number
openc2_slpf_cisco_ios_ACTION_delete_slpf_rule_number <- function(){
   consumer <- get("consumer", pos = parent.frame()) #gets consumer details
   if (consumer$acl_type=="ipv4"){ #if the consumer_id is binded with an IPv4 ACL then:
      entry_one <- paste(ACL$access_list, ACL$access_list_type, acl_id)
      entry_two <- paste("no", openc2$target$`slpf:rule_number`, sep = " ")
      commands <- list(entry_one, entry_two)
      return(commands)
   }else if (consumer$acl_type=="ipv6"){ #if the consumer_id is binded with an IPv6 ACL then:
      entry_one <- paste(ACL$access_list, acl_id)
      entry_two <- paste("no", "sequence", openc2$target$`slpf:rule_number`, sep = " ")
      commands <- list(entry_one, entry_two)
      return(commands)
   }else{
      #stop execution if needed and issue response message
   }
}


