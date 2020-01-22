# OpenC2 Plugfest - University of Oslo
January 27 & 28, 2020


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










