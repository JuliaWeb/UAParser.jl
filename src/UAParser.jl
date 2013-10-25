module UAParser

##############################################################################
##
## Dependencies
##
##############################################################################

using YAML
export device_regex, user_agent_regex, os_regex


##############################################################################
##
## Load regexes.yaml, which is the basis for entire package
##
##############################################################################


function init()
	global device_regex
	global user_agent_regex
	global os_regex

	#Load the YAML file, creating a global object "regexes"
	regexes = YAML.load(open(Pkg.dir("UAParser", "regexes.yaml")));

	#Break into device, user agent, and os arrays
	device_regex = regexes["device_parsers"];
	user_agent_regex = regexes["user_agent_parsers"];
	os_regex = regexes["os_parsers"];

	return device_regex, user_agent_regex, os_regex
end









end # module
