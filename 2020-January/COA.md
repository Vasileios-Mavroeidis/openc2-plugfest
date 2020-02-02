# OpenC2 Course of Action - Commands with a Common Purpose

**How?** : Just a JSON array of individual commands [{command 1},{command 2},{command n}]

The mechanics of how to parse this array is implemented by the entity that controls the orchestrator. The mechanics are out of OpenC2 scope.  

Different scenarios demand this array to be treated differently (different levels of processing sophistication).  

Case 1: The commands are similar and do not need any conditional logic for execution.
•	The commands are treated one by one. For example, blocking multiple identified C2 domains relevant to a specific Threat Actor attack campaign. Also the array can be shared standalone OR as part of a new object if it requires any extra granularity.
•	IOCs for detection, mitigation, and remediation are applicable, as long as the commands are not interdependent.

Note: The point is to be able to parse a JSON array with commands in the simplest way possible. It’s also a robust way of sharing this information/array as part of CTI.  

Case 2: The commands are similar and do require conditional logic for execution.

•	Potential Solution: An entity should identify how to process the commands. For example if the sequence or the execution of a command is directly related with the successful execution of a previous command, then we can use the response codes as an indication, where a 200 code allows us to process and execute the next command in the array, and a failed command stops the execution.

•	Very important is how the response codes are generated. For example, for a COA, such as scan a system for a particular malicious process (hash) and in the case where it is identified then investigate and remediate. The action scan is successful (200) regardless if the process was identified as long as the scan was completed as an operation. The result, positive or negative should be unrelated with the code, but maybe as part of the status text or a newly defined element. A 200 code will allow the orchestrator to forward the second command.

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


