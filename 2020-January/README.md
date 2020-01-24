# OpenC2 Plugfest - University of Oslo
January 27 & 28, 2020

For more information about OpenC2 please visit the [OpenC2 Official Technical Committee Web Page](https://www.oasis-open.org/committees/tc_home.php?wg_abbrev=openc2)
## Use Case 
The iosacl-adapter accepts OpenC2 commands that conform to the SLPF Specification and executes those commands on Cisco devices (IOS and IOS-XE) that support Access Control Lists (ACL) for packet filtering.

In this particular use case, we control a Cisco Cloud Service Router (CSR1000V with Cisco IOS XE Software, Version 16.12.01a) in the Google Cloud Platform.

## Statement of Purpose
This Proof of Concept (PoC) demonstrates that the OpenC2 Stateless Packet Filtering Specification (SLPF) is robust enough to provide the appropriate functionality needed for integrating with Cisco devices that support ACL. Ultimately, this PoC provides a mapping service by translating OpenC2 to Cisco Proprietary syntax. Finally, this PoC conforms with the SLPF Specification Version 1.0.

For more details please visit: https://github.com/oasis-open/openc2-iosacl-adapter

Note: this tool is not a native interface for Cisco devices or is supported by Cisco.

## Test Commands

### 1. Check if the Actuator is alive

#### Terminal: 
Rscript openc2_iosacl_adapter.R -o '{"action":"query","target":{"features":[]},"actuator":{"slpf":{"asset_id":"gcp_ipv4"}}}' -a actuators.json

#### JSON:
```json
{
  "action":"query",
  "target":{
    "features":[

    ]
  },
  "actuator":{
    "slpf":{
      "asset_id":"gcp_ipv4"
    }
  }
}
```
### 2. Allow ipv4_connection

#### Terminal: 
Rscript openc2_iosacl_adapter.R -o '{"action":"allow","target":{"ipv4_connection":{"protocol":"tcp","dst_addr":"10.10.10.24"}},"actuator":{"slpf":{"asset_id":"gcp_ipv4"}}}' -a actuators.json

#### JSON:
```json
{ 
  "action":"allow",
  "target":{ 
    "ipv4_connection":{ 
      "protocol":"tcp",
      "dst_addr":"10.10.10.24"
    }
  },
  "actuator":{ 
    "slpf":{ 
      "asset_id":"gcp"
    }
  }
}
```

#### Cisco Syntax (executed):
ip access-list extended wan_inbound;  
permit tcp any any 10.10.10.24 0.0.0.0

#### Note:
Missed source address is treated as any by the iosacl-adapter


### 3. Allow ipv4_connection – response requested complete – insert rule

#### Terminal: 
Rscript openc2_iosacl_adapter.R -o '{"action":"allow","target":{"ipv4_connection":{"protocol":"udp","src_addr":"10.10.10.22","src_port":80,"dst_addr":"10.10.10.23"}},"args":{"response_requested":"complete","slpf":{"insert_rule":100}},"actuator":{"slpf":{"asset_id":"gcp_ipv4"}}}' -a actuators.json

#### JSON:
```json
{ 
  "action":"allow",
  "target":{ 
    "ipv4_connection":{ 
      "protocol":"udp",
      "src_addr":"10.10.10.22",
      "src_port":80,
      "dst_addr":"10.10.10.23"
    }
  },
  "args":{ 
    "response_requested":"complete",
    "slpf":{ 
      "insert_rule":100
    }
  },
  "actuator":{ 
    "slpf":{ 
      "asset_id":"gcp"
    }
  }
}
```
#### Cisco Syntax (executed):
ip access-list extended wan_inbound;  
100 permit udp 10.10.10.22 0.0.0.0 eq 80 10.10.10.23 0.0.0.0

#### Note:
OpenC2 Producers MUST populate the Command Arguments field with "response_requested" : "complete" if the insert_rule Argument is populated.

### 4. Allow ipv4_connection – start time – duration – response requested complete – insert rule – persistent  

#### Terminal: 
Rscript openc2_iosacl_adapter.R -o '{"action":"allow","target":{"ipv4_connection":{"protocol":"tcp","src_addr":"10.10.10.6","src_port":80,"dst_addr":"10.10.10.7","dst_port":8080}},"args":{"start_time":1534775460000,"duration":500000,"response_requested":"complete","slpf":{"insert_rule":70,"persistent":true}},"actuator":{"slpf":{"asset_id":"gcp_ipv4"}}}' -a actuators.json

#### JSON:
```json
{ 
  "action":"allow",
  "target":{ 
    "ipv4_connection":{ 
      "protocol":"tcp",
      "src_addr":"10.10.10.6",
      "src_port":80,
      "dst_addr":"10.10.10.7",
      "dst_port":8080
    }
  },
  "args":{ 
    "start_time":1534775460000,
    "duration":500000,
    "response_requested":"complete",
    "slpf":{ 
      "insert_rule":70,
      "persistent":true
    }
  },
  "actuator":{ 
    "slpf":{ 
      "asset_id":"gcp"
    }
  }
}
```
#### Cisco Syntax (executed):
ip access-list extended wan_inbound;  
70 permit tcp 10.10.10.6 0.0.0.0 eq 80 10.10.10.7 0.0.0.0 eq 8080 time-range time_range_name2020-01-20-15-20-29;  
time-range time_range_name2020-01-20-15-20-29;   
absolute start 16:31 20 August 2018 end 16:39 20 August 2018

#### Note:
The DB field “vendor_specific_command” wont not show the commands ran for saving the configuration file: copy running-config startup-config. The problem with persistence is that if we populate it for a particular OpenC2 command when executed in a Cisco Router it will store all the changes applicable in the running configuration file.

### 5. Allow ipv4_connection – response requested none

#### Terminal: 
Rscript openc2_iosacl_adapter.R -o '{"action":"allow","target":{"ipv4_connection":{"protocol":"tcp","src_addr":"10.10.10.25"}},"args":{"response_requested":"none"},"actuator":{"slpf":{"asset_id":"gcp_ipv4"}}}' -a actuators.json

#### JSON:
```json
{ 
  "action":"allow",
  "target":{ 
    "ipv4_connection":{ 
      "protocol":"tcp",
      "src_addr":"10.10.10.25"
    }
  },
  "args":{ 
    "response_requested":"none"
  },
  "actuator":{ 
    "slpf":{ 
      "asset_id":"gcp"
    }
  }
}
```

#### Cisco Syntax (executed):
ip access-list extended wan_inbound;  
permit tcp 10.10.10.25 0.0.0.0 any

### 6. Allow ipv6_connection – response requested complete

#### Terminal: 
Rscript openc2_iosacl_adapter.R -o '{"action":"allow","target":{"ipv6_connection":{"protocol":"tcp","src_addr":"fda0:c496:2381:9cda::1/128","dst_addr":"fda0:c496:2381:9cda::2/128"}},"args":{"response_requested":"complete" },"actuator":{"slpf":{"asset_id":"gcp_ipv6"}}}' -a actuators.json

#### JSON:
```json
{ 
  "action":"allow",
  "target":{ 
    "ipv6_connection":{ 
      "protocol":"tcp",
      "src_addr":" fda0:c496:2381:9cda::1/128",
      "dst_addr":"fda0:c496:2381:9cda::2/128"
    }
  },
  "args":{ 
    "response_requested":"complete"
  },
  "actuator":{ 
    "slpf":{ 
      "asset_id":"gcp_ipv6"
    }
  }
}
```

#### Cisco Syntax (executed):
ipv6 access-list wan_inbound_ipv6;  
permit tcp fda0:c496:2381:9cda::1/128 fda0:c496:2381:9cda::2/128

### 7. Allow ipv6_connection – response requested none

#### Terminal: 
Rscript openc2_iosacl_adapter.R -o '{"action":"allow","target":{"ipv6_connection":{"protocol":"tcp","src_addr":"fda0:c496:2381:9cda::1/128","dst_addr":"fda0:c496:2381:9cda::5/128"}},"args":{"response_requested":"none" },"actuator":{"slpf":{"asset_id":"gcp_ipv6"}}}' -a actuators.json

#### JSON:
```json
{ 
  "action":"allow",
  "target":{ 
    "ipv6_connection":{ 
      "protocol":"tcp",
      "src_addr":"fda0:c496:2381:9cda::1/128",
      "dst_addr":"fda0:c496:2381:9cda::5/128"
    }
  },
  "args":{ 
    "response_requested":"none"
  },
  "actuator":{ 
    "slpf":{ 
      "asset_id":"gcp_ipv6"
    }
  }
}
```

#### Cisco Syntax (executed):
ipv6 access-list wan_inbound_ipv6;  
permit tcp fda0:c496:2381:9cda::1/128 fda0:c496:2381:9cda::5/128

### 8. Allow ipv6_connection – insert rule number

#### Terminal: 
Rscript openc2_iosacl_adapter.R -o '{"action":"allow","target":{"ipv6_connection":{"protocol":"tcp","src_addr":"fda0:c496:2381:9cda::1/128","dst_addr":"fda0:c496:2381:9cda::10/128"}},"args":{"response_requested":"complete","slpf":{"insert_rule":100}},"actuator":{"slpf":{"asset_id":"gcp_ipv6"}}}' -a actuators.json

#### JSON:
```json
{ 
  "action":"allow",
  "target":{ 
    "ipv6_connection":{ 
      "protocol":"tcp",
      "src_addr":"fda0:c496:2381:9cda::1/128",
      "dst_addr":"fda0:c496:2381:9cda::10/128"
    }
  },
  "args":{ 
    "response_requested":"complete",
    "slpf":{ 
      "insert_rule":100
    }
  },
  "actuator":{ 
    "slpf":{ 
      "asset_id":"gcp_ipv6"
    }
  }
}
```

#### Cisco Syntax (executed):
ipv6 access-list wan_inbound_ipv6;  
permit tcp fda0:c496:2381:9cda::1/128 fda0:c496:2381:9cda::10/128 sequence 100

#### Note:
OpenC2 Producers MUST populate the Command Arguments field with "response_requested" : "complete" if the insert_rule Argument is populated.

### 9.	Allow ipv6_connection – start time – stop time – insert rule number

#### Terminal: 
Rscript openc2_iosacl_adapter.R -o '{"action":"allow","target":{"ipv6_connection":{"protocol":"tcp","src_addr":"fda0:c496:2381:9cda::1/128","dst_addr":"fda0:c496:2381:9cda::15/128"}},"args":{"response_requested":"complete","start_time":1534775460000,"stop_time":1538775460000,"slpf":{"insert_rule":150}},"actuator":{"slpf":{"asset_id":"gcp_ipv6"}}}' -a actuators.json

#### JSON:
```json
{ 
  "action":"allow",
  "target":{ 
    "ipv6_connection":{ 
      "protocol":"tcp",
      "src_addr":"fda0:c496:2381:9cda::1/128",
      "dst_addr":"fda0:c496:2381:9cda::15/128"
    }
  },
  "args":{ 
    "response_requested":"complete",
    "start_time":1534775460000,
    "stop_time":1538775460000,
    "slpf":{ 
      "insert_rule":150
    }
  },
  "actuator":{ 
    "slpf":{ 
      "asset_id":"gcp_ipv6"
    }
  }
}
```

#### Cisco Syntax (executed):
ipv6 access-list wan_inbound_ipv6;  
permit tcp fda0:c496:2381:9cda::1/128 fda0:c496:2381:9cda::15/128 sequence 150 time-range time_range_name2020-01-22-11-52-04;   
time-range time_range_name2020-01-22-11-52-04;  
absolute start 16:31 20 August 2018 end 23:37 05 October 2018

### 10. Delete firewall rule – Example for Rule included into an IPv4 ACL

#### Terminal: 
Rscript openc2_iosacl_adapter.R -o '{"action":"delete","target":{"slpf:rule_number":20},"args":{"response_requested":"complete"},"actuator":{"slpf":{"asset_id":"gcp_ipv4"}}}' -a actuators.json

#### JSON:
```json
{
  "action":"delete",
  "target":{
    "slpf:rule_number":20
  },
  "args":{
    "response_requested":"complete"
  },
  "actuator":{
    "slpf":{
      "asset_id":"gcp_ipv4"
    }
  }
}
```

#### Cisco Syntax (executed):
ip access-list extended wan_inbound;  
no 20

### 11.	Delete firewall rule – Example for Rule included into an IPv6 ACL

#### Terminal: 
Rscript openc2_iosacl_adapter.R -o '{"action":"delete","target":{"slpf:rule_number":20},"args":{"response_requested":"complete"},"actuator":{"slpf":{"asset_id":"gcp_ipv6"}}}' -a actuators.json

#### JSON:
```json
{
  "action":"delete",
  "target":{
    "slpf:rule_number":20
  },
  "args":{
    "response_requested":"complete"
  },
  "actuator":{
    "slpf":{
      "asset_id":"gcp_ipv6"
    }
  }
}
```

#### Cisco Syntax (executed):
ipv6 access-list wan_inbound_ipv6;  
no sequence 20

### 12. Update file – name (of the file) – path (optional)

#### Terminal: 
Rscript openc2_iosacl_adapter.R -o '{"action":"update","target":{"file":{"name":"cisco_ace_list.txt"}},"actuator":{"slpf":{"asset_id":"gcp_ipv4"}}}' -a actuators.json

#### JSON:
```json
{ 
  "action":"update",
  "target":{ 
    "file":{ 
      "name":"cisco_ace_list.txt"
    }
  },
  "actuator":{ 
    "slpf":{ 
      "asset_id":"gcp_ipv4"
    }
  }
}
```

#### Cisco Syntax (executed):
ip access-list extended wan_inbound;  
permit tcp 10.10.10.10 0.0.0.0 10.10.10.20 0.0.0.0;  
permit tcp 10.10.10.11 0.0.0.0 10.10.10.21 0.0.0.0 eq 80;  
permit tcp 10.10.10.12 0.0.0.0 10.10.10.21 0.0.0.0 eq 80

#### Note: 
Our file "cisco_ace_list.txt" updates (adds) ACEs. It can also be used to update the configuration of a device.

### 13. Wrong Allow ipv4 – insert rule – without response requested complete 

#### Terminal: 
Rscript openc2_iosacl_adapter.R -o '{"action":"allow","target":{"ipv4_connection":{"protocol":"udp","src_addr":"10.10.10.200","dst_addr":"10.10.10.21","dst_port":80}},"args":{"slpf":{"insert_rule":100}},"actuator":{"slpf":{"asset_id":"gcp_ipv4"}}}' -a actuators.json

#### JSON:
```json
{ 
  "action":"allow",
  "target":{ 
    "ipv4_connection":{ 
      "protocol":"udp",
      "src_addr":"10.10.10.200",
      "dst_addr":"10.10.10.21",
      "dst_port":80
    }
  },
  "args":{ 
    "slpf":{ 
      "insert_rule":500
    }
  },
  "actuator":{ 
    "slpf":{ 
      "asset_id":"gcp_ipv4"
    }
  }
}
```

#### Note: 
OpenC2 Producers MUST populate the Command Arguments field with "response_requested" : "complete" if the insert_rule Argument is populated.

### 14. Query the actuator capability – versions – profiles – pairs (hardcoded in our code in our case)

#### Terminal: 
Rscript openc2_iosacl_adapter.R -o '{"action":"query","target":{"features":["versions","profiles","pairs"]},"actuator":{"slpf":{"asset_id":"gcp_ipv4"}}}' -a actuators.json

#### JSON:
```json
{ 
  "action":"query",
  "target":{ 
    "features":[ 
      "versions",
      "profiles",
      "pairs"
    ]
  },
  "actuator":{ 
    "slpf":{ 
      "asset_id":"gcp_ipv4"
    }
  }
}
```
#### Response from iosacl-adapter:
```json
{
  "status": "200",
  "results": {
    "versions": "1.0",
    "profiles": "slpf",
    "pairs": {
      "allow": [
        "ipv4_connection",
        "ipv6_connection"
      ],
      "deny": [
        "ipv4_connection",
        "ipv6_connection"
      ],
      "query": [
        "features"
      ],
      "update": [
        "file"
      ],
      "delete": [
        "slpf:rule_number"
      ]
    }
  }
} 
```


## Native Support: How an OpenC2 command for a NATIVE Cisco interface may look like

### Example 1

```json
{
  "action": "deny",
  "target": {
    "ipv4_connection": {
      "protocol": "tcp",
      "src_addr": "192.168.1.2",
      "dst_addr": "192.168.2.2",
      "dst_port": 80
    }
  },
  "args": {
    "start_time": 1534775460000,
    "duration": 50000000,
    "response_requested": "complete",
    "slpf": {
      "drop_process": "none",
      "vendor_specific": {
      	"cisco": {
      		"cisco_acl":{
      			"cisco_acl_id": "acl_1"
      		}
      	}
      }          
    }
  },
  "actuator": {
    "slpf": {
      	"asset_id": "10"
    }
  }
}
```
### Example 2

```json
{
  "action": "deny",
  "target": {
    "ipv4_connection": {
      "protocol": "tcp",
      "src_addr": "192.168.1.2",
      "dst_addr": "192.168.2.2",
      "dst_port": 80
    }
  },
  "args": {
    "response_requested": "complete",
    "slpf": {
      "drop_process": "none",
      "vendor_specific": {
      	"cisco": {
      		"cisco_acl":{
      			"cisco_acl_id": "acl_1",
			"time_range":"mon_wed_fri"
      		}
      	}
      }          
    }
  },
  "actuator": {
    "slpf": {
      	"asset_id": "10"
    }
  }
}
```

### Explanation and Remarks

* Cisco ACLs are attached on an interface, for example Fast Ethernet 01 (is not needed in an OpenC2 command).
*	When you define an ACL you need to specify if it will include IPv4 addresses or IPv6 addresses. So trying to submit an IPv4 rule into an IPv6 ACL will fail.
* Directionality is specified when the ACL is attached on an interface (is not needed in an OpenC2 command).
* A command needs to include the name of the ACL. Multiple ACLs may have been configured on a router. The device (e.g., Cisco router) when getting the OpenC2 command should be able to differentiate between IPv4 and IPv6 list just by the ACL name that is part of the OpenC2 command.
* Persistence can be included in the command, but a Cisco router saves the whole running configuration based on the copy running-config startup-config command. So, not each rule submitted individually. Unexpected behavior may result out of this.
* Temporality can be included (absolute in the terminology of Cisco - OpenC2 supports only start time, stop time, and duration, and not periodicity) by introducing time-range lists. Two ways to do that have been identified: First, you can include the traditional time arguments in the OpenC2 command (Example 1). The Cisco device should be able to check if a time list with identical time parameters exists. If yes, then attach the time-range list on the rule submitted. If not, create a new time-range list and attach it on the rule submitted. Second, a new argument should be defined as part of an OpenC2 command that specifies the name of the time-range list (Example 2). That means that a human analyst already has knowledge of the time-range lists, or the orchestrator has the capability of receiving this information “formally” from the actuator.

### Note:
Extending the query:features command is a viable solution to accommodate such cases as the aforementioned where an orchestrator needs extra information for populating OpenC2 commands without human intervention  – also the arguments of the action/target pairs should be identified and all of the above most probably be part of the arguments included in the OpenC2 command.



## OpenC2 Course of Action - Commands with a Common Purpose

**How?** : Just a JSON array of individual commands [{command 1},{command 2},{command n}]

The mechanics of how to parse this array is implemented by the entity that controls the orchestrator. The mechanics are out of OpenC2 scope.  

Different scenarios demand this array to be treated differently (different levels of processing sophistication).  

Case 1: The commands are similar and do not need any conditional logic for execution.
•	The commands are treated one by one. For example, blocking multiple identified C2 domains relevant to a specific Threat Actor attack campaign. Also the array can be shared standalone OR as part of a new object if it requires any extra granularity.
•	IOCs for detection, mitigation, and remediation are applicable, as long as the commands are not interdependent.

Note: The point is to be able to parse a JSON array with commands in the simplest way possible. It’s also a robust way of sharing this information/array as part of CTI.  

Case 2: The commands are similar and do require conditional logic for execution.

•	Potential Solution: An entity should identify how to process the commands. For example if the sequence or the execution of a command is directly related with the successful execution of a previous command, then we can use the response codes as an indication, where a 200 code allows us to process and execute the next command in the array, and a failed command stops the execution.

•	Very important is how the response codes are generated. For example, for a COA, such as scan a system for a particular malicious process (hash) and in the case where it is identified then investigate and remediate. The action scan is successful (200) regardless if the process was identified as long as the scan was completed as an operation. The result, positive or negative should be unrelated with the code, but maybe as part of the status text or extra an extra property. A 200 code will allow the orchestrator to forward the second command.

•	Another way would be to create a new object that can accommodate the JSON array such as:

```
{
"sequence": true
"openc2_array_id": "UUIDv4"
"openc2_array":[{OpenC2 Command 1},{OpenC2 Command 2},{OpenC2 Command n}]
}
```

Also, a course of action can include multiple arrays in an array that can be executed in parallel and have a different goal. The way they are processed is the same as previously mentioned. Maybe for each array in the main array we would have to define a UUIDV4.

Transfer: Implementing an OpenC2 array over HTTPS for example, would change nothing in the headers utilized. The orchestrator is responsible for tracking the Course of Action.

### Example: Block malicious C2 related to “ABC” Malware

#### Terminal:
Rscript openc2_iosacl_adapter.R -f multiple-commands.json -a actuators.json  

#### JSON:
```json
[ 
  { 
    "action":"deny",
    "target":{ 
      "ipv4_connection":{ 
        "protocol":"tcp",
        "src_addr":"192.168.1.2",
        "dst_addr":"192.168.2.2",
        "dst_port":80
      }
    },
    "actuator":{ 
      "slpf":{ 
        "asset_id":"gcp_ipv4"
      }
    }
  },
  { 
    "action":"deny",
    "target":{ 
      "ipv4_connection":{ 
        "protocol":"tcp",
        "src_addr":"192.168.1.2",
        "dst_addr":"192.168.2.3",
        "dst_port":80
      }
    },
    "actuator":{ 
      "slpf":{ 
        "asset_id":"gcp_ipv4"
      }
    }
  }
]
```

**Concerns:** The impact that an unsuccessful command may have in respect to the previously consumed commands in a target system and the halted executions therefore.


