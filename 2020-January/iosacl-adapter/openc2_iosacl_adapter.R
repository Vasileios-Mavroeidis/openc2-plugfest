#!/usr/bin/env Rscript

#Version 1.0
#
#Conformance: -Language Specification Version 1.0
#             -Stateless Packet Filterning Specification Version 1.0
#             
#Author: Vasileios Mavroeidis - University of Oslo
#
#
#################################################################################################################################################
#Installs and loads required packages
list_of_packages <- c("jsonlite", "ssh", "stringr", "reticulate", "RSQLite", "openssl", "readr", "uuid", "optparse")
for (p in list_of_packages) {if(p %in% rownames(installed.packages()) == FALSE) {
   install.packages(p, repos = "http://cran.us.r-project.org")
   library(p, character.only = TRUE)} else library(p, character.only = TRUE)
}
#################################################################################################################################################

#################################################################################################################################################
#Terminal Options
option_list <- list(
   make_option(c("-o", "--openc2"), type = "character", default= NULL,
               help = "OpenC2 command in JSON - The command needs to be given as a single line enclosed in single quotation marks"),
   make_option(c("-f", "--file"), type = "character", default = NULL,
               help = "path of a file with one or more OpenC2 commands in JSON - optimally, full path should be specified"),
   make_option(c("-a", "--actuators"), type = "character", default = NULL,
               help = "consumer/actuator information file")
)
opt_parser <-  OptionParser(option_list=option_list);
opt <- parse_args(opt_parser);
#################################################################################################################################################

#################################################################################################################################################
# Set the path to the Python executable file - Configure which python executable to use
#use_python("/usr/bin/python", required = T)

#The Python library "netmiko" must be installed for the code to run. This can be done manually with "pip install netmiko"
netmiko <- import("netmiko")
#################################################################################################################################################

#################################################################################################################################################
#Reads the actuator file (actuators.json) that includes all relevant information/details to initiate a connection and configure ACLs to actuators/consumers

#actuators <- "actuators.json" #path of the actuator file
if (is.null(opt$actuators)==FALSE){ #path was given as a parameter in the terminal command
   actuators <- opt$actuators
   actuators <- read_json(actuators)
}else if (exists("actuators")){ #path is hardcoded - uncomment the variable "actuators"
   actuators <- read_json(actuators)
}else if (is.null(opt$actuators)==TRUE && exists("actuators")==FALSE ){
   stop("A file with the details of the actuator(s) should be specified. Either the -a flag and a path should be specified OR alternatively the path of the file should be specified in the code by using the 'actuators' variable in the calling code file")
}
#################################################################################################################################################

#################################################################################################################################################
#Sets working directory
working_directory <- NULL #provide the working space (path)
if (is.null(working_directory) == FALSE){
   setwd(working_directory)
}else working_directory <- getwd() #if the path is not provided, assigns the current directory as the working directory
#################################################################################################################################################

#################################################################################################################################################
#Reads R Code from a File, a Connection or Expressions
source("https://raw.githubusercontent.com/Vasileios-Mavroeidis/ipnet/master/ipnet.R")
source("openc2_slpf_cisco_ios_main.R")
source("openc2_slpf_cisco_ios_five_tuple.R")
source("openc2_slpf_cisco_ios_transport.R")
source("openc2_slpf_cisco_ios_action.R")
source("openc2_slpf_cisco_ios_database.R")
source("openc2_slpf_cisco_ios_uuid_time_date.R")
source("openc2_slpf_cisco_ios_asset_id_mapping.R")
source("openc2_slpf_cisco_ios_successful_response.R")
source("openc2_slpf_cisco_ios_error_response.R")
source("openc2_slpf_cisco_ios_response_requested_argument_validator.R")
source("openc2_slpf_cisco_ios_temporality.R")
#################################################################################################################################################

#################################################################################################################################################
#Checks if a database to store the requests and responses related to OpenC2 commands exists. If not, a new database is created - (name: openc2.db)
database()
#################################################################################################################################################

#################################################################################################################################################
#Parses parameters given via terminal - openc2 command or file with openc2 command(s), file with relevant information for the actuators
if (is.null(opt$openc2)==TRUE && is.null(opt$file)==TRUE){
   stop("OpenC2 command or File is not specified. Type --help for more information")
}else if (is.null(opt$openc2)==FALSE && is.null(opt$file)==FALSE){
   stop("Both OpenC2 command and File were specified. Only one out of the two should be used per execution. Type -- help for more information")
}else if (is.null(opt$openc2)==FALSE && is.null(opt$file)== TRUE){ #openc2 command was specified
   openc2 <- fromJSON(opt$openc2)
   main()
}else if (is.null(opt$openc2)==TRUE && is.null(opt$file)== FALSE){ #file was specified
   openc2_commands <- read_json(path = opt$file)
   #a file can contain multiple OpenC2 Commands, for example part of coordinated defence actions. The commands are parsed one by one.
   for (openc2 in openc2_commands) {
      main()
   }
}
#################################################################################################################################################