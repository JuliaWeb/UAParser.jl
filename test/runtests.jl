using UAParser, YAML, Base.Test

#Tests look a little funky, because YAML reads in file as Dict
#UAParser uses composite type; tests build Dict for comparison
#Test files where tests are commented out due to not implementing jsParseBits from ua-parser Python library
#These user-agents look to be older, may not still be out in wild


#Test 1: Validation of parsedevice
test_device = YAML.load(open(joinpath(dirname(@__FILE__), "data", "test_device.yaml")));


for test_case in test_device["test_cases"]
  @test test_case["family"] == parsedevice(test_case["user_agent_string"]).family
end

#Test 2: Validation of parseos
test_os = YAML.load(open(joinpath(dirname(@__FILE__), "data", "test_user_agent_parser_os.yaml")));

for value in test_os["test_cases"]
    @test Dict{Any, Any}("major" => value["major"],
                         "minor" => value["minor"],
                         "patch" => value["patch"],
                         "patch_minor" => value["patch_minor"],
                         "family" => value["family"]) ==
          Dict{Any, Any}("major" => parseos(value["user_agent_string"]).major,
                         "minor" => parseos(value["user_agent_string"]).minor,
                         "patch" => parseos(value["user_agent_string"]).patch,
                         "patch_minor" => parseos(value["user_agent_string"]).patch_minor,
                         "family" => parseos(value["user_agent_string"]).family)
end

#Test 3: Additional validation of parseos
test_os_2 = YAML.load(open(joinpath(dirname(@__FILE__), "data", "additional_os_tests.yaml")));

for value in test_os_2["test_cases"]
@test Dict{Any, Any}("major" => value["major"], "minor" => value["minor"], "patch" => value["patch"], "patch_minor" => value["patch_minor"], "family" => value["family"]) ==
     Dict{Any, Any}("major" => parseos(value["user_agent_string"]).major,
       "minor" => parseos(value["user_agent_string"]).minor,
       "patch" => parseos(value["user_agent_string"]).patch,
       "patch_minor" => parseos(value["user_agent_string"]).patch_minor,
       "family" => parseos(value["user_agent_string"]).family)
end

#Test 4: Validation of parseuseragent
test_ua = YAML.load(open(joinpath(dirname(@__FILE__), "data", "test_user_agent_parser.yaml")));

for value in test_ua["test_cases"]
@test Dict{Any, Any}("major" => value["major"], "minor" => value["minor"], "patch" => value["patch"], "family" => value["family"]) ==
    Dict{Any, Any}("major" => parseuseragent(value["user_agent_string"]).major,
     "minor" => parseuseragent(value["user_agent_string"]).minor,
     "patch" => parseuseragent(value["user_agent_string"]).patch,
     "family" => parseuseragent(value["user_agent_string"]).family)
end

#Test 5: Additional validation of parseuseragent
test_ua_2 = YAML.load(open(joinpath(dirname(@__FILE__), "data", "firefox_user_agent_strings.yaml")));

for value in test_ua_2["test_cases"]
@test Dict{Any, Any}("major" => value["major"], "minor" => value["minor"], "patch" => value["patch"], "family" => value["family"]) ==
     Dict{Any, Any}("major" => parseuseragent(value["user_agent_string"]).major,
     "minor" => parseuseragent(value["user_agent_string"]).minor,
     "patch" => parseuseragent(value["user_agent_string"]).patch,
     "family" => parseuseragent(value["user_agent_string"]).family)

end
