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
## Functions for parsing user agent strings
##
##############################################################################

function getdevice(user_agent_string::String)
#Look for a matching regex...Once there is a match
#If there is already a value for device_replacement (string more than zero characters)
    #Check to see if device_replacement has $1 in it: if it does, substitute the regex matched value for the $1 token
    #If there isn't a $1 in the value, then just use the device_replacement value directly
#If there is no value for device_replacement, then just use the regex match directly

  for value in DEVICE_PARSERS
    if ismatch(value.user_agent_re, user_agent_string)
      if length(value.device_replacement) > 0
        if ismatch(r"\$1", value.device_replacement)
          device = replace(value.device_replacement, r"\$1", match(value.user_agent_re, user_agent_string).captures[1])
        else 
          device = value.device_replacement
        end
      else 
        device = match(value.user_agent_re, user_agent_string).captures[1]
      end

      return {"family" => device}
        
    end #Check if regex match
  end #Loop over DEVICE_PARSER end

return {"family" => "Other"}  #Fail-safe for no match
end #Function end


end # module
