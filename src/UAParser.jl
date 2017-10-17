__precompile__(true)
module UAParser

export parsedevice, parseuseragent, parseos, DeviceResult, OSResult, UAResult, DataFrame


##############################################################################
##
## Dependencies
##
##############################################################################

using YAML, DataFrames
import DataFrames.DataFrame, DataFrames.names!

##############################################################################
##
## Load YAML file
##
##############################################################################

const REGEXES = YAML.load(open(joinpath(dirname(@__FILE__), "..", "regexes.yaml")));

##############################################################################
##
## Create custom types to hold parsed YAML output
##
##############################################################################

# helper function used by constructors
_check_void_string(s::AbstractString) = String(s)
_check_void_string(::Void) = nothing

struct UserAgentParser
    user_agent_re::Regex
    family_replacement::Union{String, Void}
    v1_replacement::Union{String, Void}
    v2_replacement::Union{String, Void}

    function UserAgentParser(user_agent_re::Regex, family_replacement::Union{AbstractString, Void},
                             v1_replacement::Union{AbstractString, Void},
                             v2_replacement::Union{AbstractString, Void})
        new(user_agent_re, _check_void_string(family_replacement),
            _check_void_string(v1_replacement), _check_void_string(v2_replacement))
    end
end

struct OSParser
    user_agent_re::Regex
    os_replacement::Union{String, Void}
    os_v1_replacement::Union{String, Void}
    os_v2_replacement::Union{String, Void}

    function OSParser(user_agent_re::Regex, os_replacement::Union{AbstractString, Void},
                      os_v1_replacement::Union{AbstractString, Void},
                      os_v2_replacement::Union{AbstractString, Void})
        new(user_agent_re, _check_void_string(os_replacement), _check_void_string(os_v1_replacement),
            _check_void_string(os_v2_replacement))
    end
end

struct DeviceParser
    user_agent_re::Regex
    device_replacement::Union{String, Void}
    brand_replacement::Union{String, Void}
    model_replacement::Union{String, Void}

    function DeviceParser(user_agent_re::Regex, device_replacement::Union{AbstractString, Void},
                          brand_replacement::Union{AbstractString, Void},
                          model_replacement::Union{AbstractString, Void})
        new(user_agent_re, _check_void_string(device_replacement),
            _check_void_string(brand_replacement), _check_void_string(model_replacement))
    end
end

##############################################################################
##
## Create custom types to hold function results
##
##############################################################################

struct DeviceResult
    family::String
    brand::Union{String, Void}
    model::Union{String, Void}

    function DeviceResult(family::AbstractString, brand::Union{AbstractString, Void},
                          model::Union{AbstractString, Void})
        new(string(family), _check_void_string(brand), _check_void_string(model))
    end
end

struct UAResult
    family::String
    major::Union{String, Void}
    minor::Union{String, Void}
    patch::Union{String, Void}

    function UAResult(family::AbstractString, major::Union{AbstractString, Void},
                      minor::Union{AbstractString, Void}, patch::Union{AbstractString, Void})
        new(string(family), _check_void_string(major), _check_void_string(minor),
            _check_void_string(patch))
    end
end

struct OSResult
    family::String
    major::Union{String, Void}
    minor::Union{String, Void}
    patch::Union{String, Void}
    patch_minor::Union{String, Void}

    function OSResult(family::AbstractString, major::Union{AbstractString, Void},
                      minor::Union{AbstractString, Void}, patch::Union{AbstractString, Void},
                      patch_minor::Union{AbstractString, Void})
        new(string(family), _check_void_string(major), _check_void_string(minor),
            _check_void_string(patch), _check_void_string(patch_minor))
    end
end

##############################################################################
##
## Create USER_AGENT_PARSERS, OS_PARSERS, and DEVICE_PARSERS arrays
##
##############################################################################

function loadua()
  #Create empty array to hold user-agent information
  temp = []

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
  temp = []

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
  temp = []

  #Loop over entire set of device_parsers, add to DEVICE_PARSERS
  for _device_parser in REGEXES["device_parsers"]
      _user_agent_re = Regex(_device_parser["regex"])
      _device_replacement = get(_device_parser, "device_replacement", nothing)
      _brand_replacement = get(_device_parser, "brand_replacement", nothing)
      _model_replacement = get(_device_parser, "model_replacement", nothing)

    #Add values to array
      push!(temp, DeviceParser(_user_agent_re, _device_replacement, _brand_replacement,
                               _model_replacement))
  end
  return temp
end #End loaddevice

const DEVICE_PARSERS = loaddevice()

##############################################################################
##
## Functions for parsing user agent strings
##
##############################################################################

# helper function for parsedevice
function _inner_replace(str::AbstractString, group)
    # TODO this rather dangerously assumes that strings are $ followed by ints
    idx = parse(Int, str[2:end])
    if idx ≤ length(group) && group[idx] ≠ nothing
        group[idx]
    else
        ""
    end
end

# helper function for parsedevice
function _multireplace(str::AbstractString, mtch::RegexMatch)
    _str = replace(str, r"\$(\d)", m -> _inner_replace(m, mtch.captures))
    _str = replace(_str, r"^\s+|\s+$", "")
    length(_str) == 0 ? nothing : _str
end


function parsedevice(user_agent_string::AbstractString)
    for value in DEVICE_PARSERS
        if ismatch(value.user_agent_re, user_agent_string)

            # TODO, this is probably really inefficient, should be one call with ismatch
            _match = match(value.user_agent_re, user_agent_string)

            # family
            if value.device_replacement ≠ nothing
                device = _multireplace(value.device_replacement, _match)
            else
                device = _match.captures[1]
            end

            # brand
            if value.brand_replacement ≠ nothing
                brand = _multireplace(value.brand_replacement, _match)
            elseif length(_match.captures) > 1
                brand = match_vals[2]
            else
                brand = nothing
            end

            # model
            if value.model_replacement ≠ nothing
                model = _multireplace(value.model_replacement, _match)
            elseif length(_match.captures) > 2
                model = match_vals[3]
            else
                model = nothing
            end

            return DeviceResult(device, brand, model)
        end
    end
    DeviceResult("Other",nothing,nothing)  #Fail-safe for no match
end # parsedevice


function parseuseragent(user_agent_string::AbstractString)
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


function parseos(user_agent_string::AbstractString)
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


##############################################################################
##
## Extend DataFrames to include UAParser methods
##
##############################################################################

#Convenience function to take nothing type to String of length 0
#This is a hack for sure
function nothing_to_emptystr(x::Union{AbstractString, Void})
  if x == nothing
    x = ""
  else
    x = convert(String, x)
  end
end

#DeviceResult to DataFrame method
function DataFrame(x::Array{DeviceResult, 1})
    temp = DataFrame(String, size(x, 1), 3)
    names!(temp, ["device", "brand", "model"])

    temp["device"] = String[ξ.family for ξ ∈ x]

    temp["brand"] = String[nothing_to_emptystr(ξ.brand) for ξ ∈ x]

    temp["model"] = String[nothing_to_emptystr(ξ.model) for ξ ∈ x]

    temp
end

#OSResult to DataFrame method
function DataFrame(x::Array{OSResult, 1})
    #Pre-allocate size of DataFrame based on array passed in
    temp = DataFrame(String, size(x, 1), 5)
    names!(temp, ["os_family", "os_major", "os_minor", "os_patch", "os_patch_minor"])

    #Family - Can use comprehension since family always String
    temp["os_family"] = String[element.family for element in x]

    #Major
    temp["os_major"] = String[nothing_to_emptystr(element.major) for element in x]

    #Minor
    temp["os_minor"] = String[nothing_to_emptystr(element.minor) for element in x]

    #Patch
    temp["os_patch"] = String[nothing_to_emptystr(element.patch) for element in x]

    #Patch_Minor
    temp["os_patch_minor"] = String[nothing_to_emptystr(element.patch_minor) for element in x]

    temp
end

#UAResult to DataFrame method
function DataFrame(x::Array{UAResult, 1})
  #Pre-allocate size of DataFrame based on array passed in
  temp = DataFrame(String, size(x, 1), 4)
  names!(temp, ["browser_family", "browser_major", "browser_minor", "browser_patch"])

  #Family - Can use comprehension since family always String
  temp["browser_family"] = String[element.family for element in x]

  #Major
  temp["browser_major"] = String[nothing_to_emptystr(element.major) for element in x]

  #Minor
  temp["browser_minor"] = String[nothing_to_emptystr(element.minor) for element in x]

  #Patch
  temp["browser_patch"] = String[nothing_to_emptystr(element.patch) for element in x]

  return temp
end

end # module
