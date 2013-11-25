module UAParser

export parsedevice, parseuseragent, parseos, parseall

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

const REGEXES = YAML.load(open(Pkg.dir("UAParser", "regexes.yaml")));

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


function loadua()
  #Create empty array to hold user-agent information
  temp = {}

  #Loop over entire set of user_agent_parsers, add to USER_AGENT_PARSERS
  for _ua_parser in REGEXES["user_agent_parsers"]
      _pattern = _ua_parser["regex"]
      _user_agent_re = Regex(_pattern)
      _family_replacement = get(_ua_parser, "family_replacement", "")
      _v1_replacement = get(_ua_parser, "v1_replacement", "")
      _v2_replacement = get(_ua_parser, "v2_replacement", "")
        
    #Add values to array 
      push!(temp, UserAgentParser(_pattern, _user_agent_re, _family_replacement, _v1_replacement, _v2_replacement))
    
  end
  return temp
end #End loadua

const USER_AGENT_PARSERS = loadua()

function loados()
  #Create empty array to hold os information
  temp = {}

  #Loop over entire set of os_parsers, add to OS_PARSERS
  for _os_parser in REGEXES["os_parsers"]
    _pattern = _os_parser["regex"]
    _user_agent_re = Regex(_pattern)
    _os_replacement = get(_os_parser, "os_replacement", "")
    _os_v1_replacement = get(_os_parser, "os_v1_replacement", "")
    _os_v2_replacement = get(_os_parser, "os_v2_replacement", "")
    
    #Add values to array
    push!(temp, OSParser(_pattern, _user_agent_re, _os_replacement, _os_v1_replacement, _os_v2_replacement))
    
  end
  return temp
end #End loados

const OS_PARSERS = loados()

function loaddevice()
  #Create empty array to hold device information
  temp = {}

  #Loop over entire set of device_parsers, add to DEVICE_PARSERS
  for _device_parser in REGEXES["device_parsers"]
      _pattern = _device_parser["regex"]
      _user_agent_re = Regex(_pattern)
      _device_replacement = get(_device_parser, "device_replacement", "")

    #Add values to array
      push!(temp, DeviceParser(_pattern, _user_agent_re, _device_replacement))
  end
  return temp
end #End loaddevice

const DEVICE_PARSERS = loaddevice()

##############################################################################
##
## Functions for parsing user agent strings
##
##############################################################################

function parsedevice(user_agent_string::String)
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
        
    end
  end

return {"family" => "Other"}  #Fail-safe for no match
end #End parsedevice

function parseuseragent(user_agent_string::String)
  for value in USER_AGENT_PARSERS
    if ismatch(value.user_agent_re, user_agent_string)

      match_vals = match(value.user_agent_re, user_agent_string).captures

      #family
      if length(value.family_replacement) > 0
        if ismatch(r"\$1", value.family_replacement)
          family = replace(value.family_replacement, r"\$1", match_vals[1])
        else 
          family = value.family_replacement
        end 
      else 
        family = match_vals[1]
      end

      #major
      if length(value.v1_replacement) > 0
        v1 = value.v1_replacement
      elseif length(match_vals) > 1
        v1 = match_vals[2]
      else 
        v1 = ""
      end

      #minor
      if length(value.v2_replacement) > 0
        v2 = value.v2_replacement
      elseif length(match_vals) > 2
        v2 = match_vals[3]
      else 
        v2 = ""
      end

      #patch
      if length(match_vals) > 3
        v3 = match_vals[4]
      else 
        v3 = ""
      end

      return {"family" => family, 
              "major" => v1, 
              "minor" => v2, 
              "patch" => v3}
      
    end
  end
return {"family" => "Other", 
        "major" => "", 
        "minor" => "", 
        "patch" => ""} #fail-safe for no match
end #End parseuseragent

function parseos(user_agent_string::String)
    for value in OS_PARSERS
        if ismatch(value.user_agent_re, user_agent_string)
            match_vals = match(value.user_agent_re, user_agent_string).captures

            #os
            if length(value.os_replacement) > 0
                os = value.os_replacement
            else
                os = match_vals[1]
            end 

            #os_v1
            if length(value.os_v1_replacement) > 0
                os_v1 = value.os_v1_replacement
            elseif length(match_vals) > 1
                os_v1 = match_vals[2]
            else 
                os_v1 = ""
            end

            #os_v2
            if length(value.os_v2_replacement) > 0
                os_v2 = value.os_v2_replacement
            elseif length(match_vals) > 2
                os_v2 = match_vals[3]
            else 
                os_v2 = ""
            end

            #os_v3
            if length(match_vals) > 3
                os_v3 = match_vals[4]
            else 
                os_v3 = ""
            end

            #os_v4
            if length(match_vals) > 4
                os_v4 = match_vals[5]
            else 
                os_v4 = ""
            end

            return {"family" => os, 
                    "major" => os_v1, 
                    "minor" => os_v2, 
                    "patch" => os_v3, 
                    "patch_minor" => os_v4}

        end
    end

return {"family" => "Other", 
        "major" => "", 
        "minor" => "", 
        "patch" => "", 
        "patch_minor" => ""} #Fail-safe if no match
end #End parseos 

function parseall(user_agent_string::String)

  return {"user_agent" => parseuseragent(user_agent_string),
          "os" => parseos(user_agent_string),
          "device" => parsedevice(user_agent_string),
          "string" => user_agent_string}
end #End parseall

end # module
