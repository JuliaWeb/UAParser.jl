module UAParser

export parsedevice, parseuseragent, parseos, DeviceResult, OSResult, UAResult, DataFrame


##############################################################################
##
## Dependencies
##
##############################################################################

using YAML, DataFrames
import DataFrames.DataFrame, DataFrames.colnames!

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
  user_agent_re::Regex
  family_replacement::Union(String, Nothing)
  v1_replacement::Union(String, Nothing)
  v2_replacement::Union(String, Nothing)
end
  
immutable OSParser
  user_agent_re::Regex
  os_replacement::Union(String, Nothing)
  os_v1_replacement::Union(String, Nothing)
  os_v2_replacement::Union(String, Nothing)
end

immutable DeviceParser
  user_agent_re::Regex
  device_replacement::Union(String, Nothing)
end

##############################################################################
##
## Create custom types to hold function results
##
##############################################################################

immutable DeviceResult
  family::UTF8String  
end

immutable UAResult
  family::String
  major::Union(String, Nothing)
  minor::Union(String, Nothing)
  patch::Union(String, Nothing)
end

immutable OSResult
  family::String
  major::Union(String, Nothing)
  minor::Union(String, Nothing)
  patch::Union(String, Nothing)
  patch_minor::Union(String, Nothing)
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
      _user_agent_re = Regex(_ua_parser["regex"])
      _family_replacement = get(_ua_parser, "family_replacement", nothing)
      _v1_replacement = get(_ua_parser, "v1_replacement", nothing)
      _v2_replacement = get(_ua_parser, "v2_replacement", nothing)
        
    #Add values to array 
      push!(temp, UserAgentParser(_user_agent_re,
                                  _family_replacement,
                                  _v1_replacement,
                                  _v2_replacement
                                  ))
    
  end
  return temp
end #End loadua

const USER_AGENT_PARSERS = loadua()

function loados()
  #Create empty array to hold os information
  temp = {}

  #Loop over entire set of os_parsers, add to OS_PARSERS
  for _os_parser in REGEXES["os_parsers"]
    _user_agent_re = Regex(_os_parser["regex"])
    _os_replacement = get(_os_parser, "os_replacement", nothing)
    _os_v1_replacement = get(_os_parser, "os_v1_replacement", nothing)
    _os_v2_replacement = get(_os_parser, "os_v2_replacement", nothing)
    
    #Add values to array
    push!(temp, OSParser(_user_agent_re,
                         _os_replacement,
                         _os_v1_replacement,
                         _os_v2_replacement
                         ))
    
  end
  return temp
end #End loados

const OS_PARSERS = loados()

function loaddevice()
  #Create empty array to hold device information
  temp = {}

  #Loop over entire set of device_parsers, add to DEVICE_PARSERS
  for _device_parser in REGEXES["device_parsers"]
      _user_agent_re = Regex(_device_parser["regex"])
      _device_replacement = get(_device_parser, "device_replacement", nothing)

    #Add values to array
      push!(temp, DeviceParser(_user_agent_re, _device_replacement))
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
      if value.device_replacement != nothing
        if ismatch(r"\$1", value.device_replacement)
          device = replace(value.device_replacement, "\$1", match(value.user_agent_re, user_agent_string).captures[1])
        else 
          device = value.device_replacement
        end
      else 
        device = match(value.user_agent_re, user_agent_string).captures[1]
      end

        return DeviceResult(device)
    end
  end

return DeviceResult("Other")  #Fail-safe for no match
end #End parsedevice

#Vectorize parsedevice for any array of user-agent strings
Base.@vectorize_1arg String parsedevice

function parseuseragent(user_agent_string::String)
  for value in USER_AGENT_PARSERS
    if ismatch(value.user_agent_re, user_agent_string)

      match_vals = match(value.user_agent_re, user_agent_string).captures

      #family
      if value.family_replacement != nothing
        if ismatch(r"\$1", value.family_replacement)
          family = replace(value.family_replacement, "\$1", match_vals[1])
        else 
          family = value.family_replacement
        end 
      else 
        family = match_vals[1]
      end

      #major
      if value.v1_replacement != nothing
        v1 = value.v1_replacement
      elseif length(match_vals) > 1
        v1 = match_vals[2]
      else 
        v1 = nothing
      end

      #minor
      if value.v2_replacement != nothing
        v2 = value.v2_replacement
      elseif length(match_vals) > 2
        v2 = match_vals[3]
      else 
        v2 = nothing
      end

      #patch
      if length(match_vals) > 3
        v3 = match_vals[4]
      else 
        v3 = nothing
      end

      return UAResult(family, v1, v2, v3)

    end
  end

return UAResult("Other", nothing, nothing, nothing) #Fail-safe for no match
end #End parseuseragent

#Vectorize parseuseragent for any array of user-agent strings
Base.@vectorize_1arg String parseuseragent

function parseos(user_agent_string::String)
    for value in OS_PARSERS
        if ismatch(value.user_agent_re, user_agent_string)
            match_vals = match(value.user_agent_re, user_agent_string).captures

            #os
            if value.os_replacement != nothing
                os = value.os_replacement
            else
                os = match_vals[1]
            end 

            #os_v1
            if value.os_v1_replacement != nothing
                os_v1 = value.os_v1_replacement
            elseif length(match_vals) > 1
                os_v1 = match_vals[2]
            else 
                os_v1 = nothing
            end

            #os_v2
            if value.os_v2_replacement != nothing
                os_v2 = value.os_v2_replacement
            elseif length(match_vals) > 2
                os_v2 = match_vals[3]
            else 
                os_v2 = nothing
            end

            #os_v3
            if length(match_vals) > 3
                os_v3 = match_vals[4]
            else 
                os_v3 = nothing
            end

            #os_v4
            if length(match_vals) > 4
                os_v4 = match_vals[5]
            else 
                os_v4 = nothing
            end

            return OSResult(os, os_v1, os_v2, os_v3, os_v4)

        end
    end

return OSResult("Other", nothing, nothing, nothing, nothing) #Fail-safe if no match
end #End parseos 

#Vectorize parseos for any array of user-agent strings
Base.@vectorize_1arg String parseos

##############################################################################
##
## Extend DataFrames to include UAParser methods 
##
##############################################################################

#Convenience function to take nothing type to UTF8String of length 0
#This is a hack for sure
function nothing_to_utf8empty(x::Union(String, Nothing))
  if x == nothing
    x = ""
  else
    x = convert(UTF8String, x)
  end
end

#DeviceResult to DataFrame method
function DataFrame(x::Array{DeviceResult, 1})
  temp = DataFrame([element.family for element in x])
  colnames!(temp, ["device"])
  return temp
end

#OSResult to DataFrame method
function DataFrame(x::Array{OSResult, 1})
  #Pre-allocate size of DataFrame based on array passed in
  temp = DataFrame(UTF8String, size(x, 1), 5)
  colnames!(temp, ["os_family", "os_major", "os_minor", "os_patch", "os_patch_minor"])

  #Family - Can use comprehension since family always UTF8String
  temp["os_family"] = UTF8String[element.family for element in x]

  #Major
  temp["os_major"] = UTF8String[nothing_to_utf8empty(element.major) for element in x]

  #Minor
  temp["os_minor"] = UTF8String[nothing_to_utf8empty(element.minor) for element in x]

  #Patch
  temp["os_patch"] = UTF8String[nothing_to_utf8empty(element.patch) for element in x]

  #Patch_Minor
  temp["os_patch_minor"] = UTF8String[nothing_to_utf8empty(element.patch_minor) for element in x]

  return temp  
end

#UAResult to DataFrame method
function DataFrame(x::Array{UAResult, 1})
  #Pre-allocate size of DataFrame based on array passed in
  temp = DataFrame(UTF8String, size(x, 1), 4)
  colnames!(temp, ["browser_family", "browser_major", "browser_minor", "browser_patch"])

  #Family - Can use comprehension since family always UTF8String
  temp["browser_family"] = UTF8String[element.family for element in x]

  #Major
  temp["browser_major"] = UTF8String[nothing_to_utf8empty(element.major) for element in x]

  #Minor
  temp["browser_minor"] = UTF8String[nothing_to_utf8empty(element.minor) for element in x]

  #Patch
  temp["browser_patch"] = UTF8String[nothing_to_utf8empty(element.patch) for element in x]

  return temp  
end

end # module