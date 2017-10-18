__precompile__(true)
module UAParser

export parsedevice, parseuseragent, parseos, DeviceResult, OSResult, UAResult, DataFrame


##############################################################################
##
## Dependencies
##
##############################################################################

using YAML, DataFrames, Nulls
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
_check_null_string(s::AbstractString) = String(s)
_check_null_string(::Null) = null
_check_null_string(::Void) = null
_check_null_string(x) = ArgumentError("Invalid string or null passed: $x")

struct UserAgentParser
    user_agent_re::Regex
    family_replacement::Union{String, Null}
    v1_replacement::Union{String, Null}
    v2_replacement::Union{String, Null}

    function UserAgentParser(user_agent_re::Regex, family_replacement, v1_replacement,
                             v2_replacement)
        new(user_agent_re, _check_null_string(family_replacement),
            _check_null_string(v1_replacement), _check_null_string(v2_replacement))
    end
end

struct OSParser
    user_agent_re::Regex
    os_replacement::Union{String, Null}
    os_v1_replacement::Union{String, Null}
    os_v2_replacement::Union{String, Null}

    function OSParser(user_agent_re::Regex, os_replacement, os_v1_replacement, os_v2_replacement)
        new(user_agent_re, _check_null_string(os_replacement), _check_null_string(os_v1_replacement),
            _check_null_string(os_v2_replacement))
    end
end

struct DeviceParser
    user_agent_re::Regex
    device_replacement::Union{String, Null}
    brand_replacement::Union{String, Null}
    model_replacement::Union{String, Null}

    function DeviceParser(user_agent_re::Regex, device_replacement, brand_replacement,
                          model_replacement)
        new(user_agent_re, _check_null_string(device_replacement),
            _check_null_string(brand_replacement), _check_null_string(model_replacement))
    end
end

##############################################################################
##
## Create custom types to hold function results
##
##############################################################################

struct DeviceResult
    family::String
    brand::Union{String, Null}
    model::Union{String, Null}

    function DeviceResult(family::AbstractString, brand, model)
        new(string(family), _check_null_string(brand), _check_null_string(model))
    end
end

struct UAResult
    family::String
    major::Union{String, Null}
    minor::Union{String, Null}
    patch::Union{String, Null}

    function UAResult(family::AbstractString, major, minor, patch)
        new(string(family), _check_null_string(major), _check_null_string(minor),
            _check_null_string(patch))
    end
end

struct OSResult
    family::String
    major::Union{String, Null}
    minor::Union{String, Null}
    patch::Union{String, Null}
    patch_minor::Union{String, Null}

    function OSResult(family::AbstractString, major, minor, patch, patch_minor)
        new(string(family), _check_null_string(major), _check_null_string(minor),
            _check_null_string(patch), _check_null_string(patch_minor))
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
      _family_replacement = get(_ua_parser, "family_replacement", null)
      _v1_replacement = get(_ua_parser, "v1_replacement", null)
      _v2_replacement = get(_ua_parser, "v2_replacement", null)

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
    _os_replacement = get(_os_parser, "os_replacement", null)
    _os_v1_replacement = get(_os_parser, "os_v1_replacement", null)
    _os_v2_replacement = get(_os_parser, "os_v2_replacement", null)

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
      _device_replacement = get(_device_parser, "device_replacement", null)
      _brand_replacement = get(_device_parser, "brand_replacement", null)
      _model_replacement = get(_device_parser, "model_replacement", null)

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
    length(_str) == 0 ? null : _str
end


function parsedevice(user_agent_string::AbstractString)
    for value in DEVICE_PARSERS
        if ismatch(value.user_agent_re, user_agent_string)

            # TODO, this is probably really inefficient, should be one call with ismatch
            _match = match(value.user_agent_re, user_agent_string)

            # family
            if !isnull(value.device_replacement)
                device = _multireplace(value.device_replacement, _match)
            else
                device = _match.captures[1]
            end

            # brand
            if !isnull(value.brand_replacement)
                brand = _multireplace(value.brand_replacement, _match)
            elseif length(_match.captures) > 1
                brand = match_vals[2]
            else
                brand = null
            end

            # model
            if !isnull(value.model_replacement)
                model = _multireplace(value.model_replacement, _match)
            elseif length(_match.captures) > 2
                model = match_vals[3]
            else
                model = null
            end

            return DeviceResult(device, brand, model)
        end
    end
    DeviceResult("Other",null,null)  #Fail-safe for no match
end # parsedevice
parsedevice(::Null) = null


function parseuseragent(user_agent_string::AbstractString)
  for value in USER_AGENT_PARSERS
    if ismatch(value.user_agent_re, user_agent_string)

      match_vals = match(value.user_agent_re, user_agent_string).captures

      #family
      if !isnull(value.family_replacement)
        if ismatch(r"\$1", value.family_replacement)
          family = replace(value.family_replacement, "\$1", match_vals[1])
        else
          family = value.family_replacement
        end
      else
        family = match_vals[1]
      end

      #major
      if !isnull(value.v1_replacement)
        v1 = value.v1_replacement
      elseif length(match_vals) > 1
        v1 = match_vals[2]
      else
        v1 = null
      end

      #minor
      if !isnull(value.v2_replacement)
        v2 = value.v2_replacement
      elseif length(match_vals) > 2
        v2 = match_vals[3]
      else
        v2 = null
      end

      #patch
      if length(match_vals) > 3
        v3 = match_vals[4]
      else
        v3 = null
      end

      return UAResult(family, v1, v2, v3)

    end
  end

return UAResult("Other", null, null, null) #Fail-safe for no match
end #End parseuseragent
parseuseragent(::Null) = null


function parseos(user_agent_string::AbstractString)
    for value in OS_PARSERS
        if ismatch(value.user_agent_re, user_agent_string)
            match_vals = match(value.user_agent_re, user_agent_string).captures

            #os
            if !isnull(value.os_replacement)
                os = value.os_replacement
            else
                os = match_vals[1]
            end

            #os_v1
            if !isnull(value.os_v1_replacement)
                os_v1 = value.os_v1_replacement
            elseif length(match_vals) > 1
                os_v1 = match_vals[2]
            else
                os_v1 = null
            end

            #os_v2
            if !isnull(value.os_v2_replacement)
                os_v2 = value.os_v2_replacement
            elseif length(match_vals) > 2
                os_v2 = match_vals[3]
            else
                os_v2 = null
            end

            #os_v3
            if length(match_vals) > 3
                os_v3 = match_vals[4]
            else
                os_v3 = null
            end

            #os_v4
            if length(match_vals) > 4
                os_v4 = match_vals[5]
            else
                os_v4 = null
            end

            return OSResult(os, os_v1, os_v2, os_v3, os_v4)

        end
    end

return OSResult("Other", null, null, null, null) #Fail-safe if no match
end #End parseos
parseos(::Null) = null


##############################################################################
##
## Extend DataFrames to include UAParser methods
##
##############################################################################

#DeviceResult to DataFrame method
function DataFrame(x::Array{DeviceResult, 1})
    temp = DataFrame()

    temp["device"] = String[element.family for element ∈ x]

    temp["brand"] = Union{String,Null}[element.brand for element ∈ x]

    temp["model"] = Union{String,Null}[element.model for element ∈ x]

    temp
end

#OSResult to DataFrame method
function DataFrame(x::Array{OSResult, 1})
    temp = DataFrame()

    #Family - Can use comprehension since family always String
    temp["os_family"] = String[element.family for element in x]

    #Major
    temp["os_major"] = Union{String,Null}[element.major for element in x]

    #Minor
    temp["os_minor"] = Union{String,Null}[element.minor for element in x]

    #Patch
    temp["os_patch"] = Union{String,Null}[element.patch for element in x]

    #Patch_Minor
    temp["os_patch_minor"] = Union{String,Null}[element.patch_minor for element in x]

    temp
end

#UAResult to DataFrame method
function DataFrame(x::Array{UAResult, 1})
  #Pre-allocate size of DataFrame based on array passed in
  temp = DataFrame()

  #Family - Can use comprehension since family always String
  temp["browser_family"] = String[element.family for element in x]

  #Major
  temp["browser_major"] = Union{String,Null}[element.major for element in x]

  #Minor
  temp["browser_minor"] = Union{String,Null}[element.minor for element in x]

  #Patch
  temp["browser_patch"] = Union{String,Null}[element.patch for element in x]

  return temp
end

end # module
