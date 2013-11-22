module UAParser


#Using UPPERCASE for lookup values
#Using CamelCase for types
#Using lowercase for functions


##############################################################################
##
## Dependencies
##
##############################################################################

using YAML

##############################################################################
##
## Load YAML file
##
##############################################################################

REGEXES = YAML.load(open(Pkg.dir("UAParser", "regexes.yaml")));

##############################################################################
##
## Create custom types to hold parsed YAML output
##
##############################################################################

immutable UserAgentParser
  pattern::String
  user_agent_re::Regex
  family_replacement::String
  v1_replacement::String
  v2_replacement::String
end
  
immutable OSParser
  pattern::String
  user_agent_re::Regex
  os_replacement::String
  os_v1_replacement::String
  os_v2_replacement::String
end

immutable DeviceParser
  pattern::String
  user_agent_re::Regex
  device_replacement::String
end

##############################################################################
##
## Create USER_AGENT_PARSERS, OS_PARSERS, and DEVICE_PARSERS arrays
##
##############################################################################

#Create empty array to hold user-agent information
USER_AGENT_PARSERS = {}

#Loop over entire set of user_agent_parsers, add to USER_AGENT_PARSERS
for _ua_parser in REGEXES["user_agent_parsers"]
    _pattern = _ua_parser["regex"]
    _user_agent_re = Regex(_pattern)
    _family_replacement = get(_ua_parser, "family_replacement", "")
    _v1_replacement = get(_ua_parser, "v1_replacement", "")
    _v2_replacement = get(_ua_parser, "v2_replacement", "")
      
  #Add values to array 
    push!(USER_AGENT_PARSERS, UserAgentParser(_pattern, _user_agent_re, _family_replacement, _v1_replacement, _v2_replacement))
  
end

#Create empty array to hold os information
OS_PARSERS = {}

#Loop over entire set of os_parsers, add to OS_PARSERS
for _os_parser in REGEXES["os_parsers"]
  _pattern = _os_parser["regex"]
  _user_agent_re = Regex(_pattern)
  _os_replacement = get(_os_parser, "os_replacement", "")
  _os_v1_replacement = get(_os_parser, "os_v1_replacement", "")
  _os_v2_replacement = get(_os_parser, "os_v2_replacement", "")
  
  #Add values to array
  push!(OS_PARSERS, OSParser(_pattern, _user_agent_re, _os_replacement, _os_v1_replacement, _os_v2_replacement))
  
end

#Create empty array to hold device information
DEVICE_PARSERS = {}

#Loop over entire set of device_parsers, add to DEVICE_PARSERS
for _device_parser in REGEXES["device_parsers"]
    _pattern = _device_parser["regex"]
    _user_agent_re = Regex(_pattern)
    _device_replacement = get(_device_parser, "device_replacement", "")

  #Add values to array
    push!(DEVICE_PARSERS, DeviceParser(_pattern, _user_agent_re, _device_replacement))
end

##############################################################################
##
## FOO
##
##############################################################################


end # module
