using UAParser, YAML
#Incorporate Base.Test at later date
#https://github.com/tobie/ua-parser/blob/master/test_resources/

#Tests look a little funky, because YAML reads in file as Dict
#UAParser uses composite type; tests build Dict for comparison


#Test 1: Validation of parsedevice
test_device = YAML.load(open(Pkg.dir("UAParser", "test", "data", "test_device.yaml")));

for test_case in test_device["test_cases"]
  match = test_case["family"] == parsedevice(test_case["user_agent_string"]).family
  if match
    println("PASS")
  else
    println("FAIL: ", "User Agent: ", test_case["user_agent_string"])
  end
end

#Test 2: Validation of parseos
test_os = YAML.load(open(Pkg.dir("UAParser", "test", "data", "test_user_agent_parser_os.yaml")));

for value in test_os["test_cases"]
  if {"major" => value["major"], 
      "minor" => value["minor"], 
      "patch" => value["patch"], 
      "patch_minor" => value["patch_minor"], 
      "family" => value["family"]} == 
      {"major" => parseos(value["user_agent_string"]).major,
       "minor" => parseos(value["user_agent_string"]).minor,
       "patch" => parseos(value["user_agent_string"]).patch,
       "patch_minor" => parseos(value["user_agent_string"]).patch_minor,
       "family" => parseos(value["user_agent_string"]).family}
      println("PASS")
  else
      println("FAIL: ", value["user_agent_string"])
  end
end

#Test 3: Additional validation of parseos
test_os_2 = YAML.load(open(Pkg.dir("UAParser", "test", "data", "additional_os_tests.yaml")));

for value in test_os_2["test_cases"]
  if {"major" => value["major"], "minor" => value["minor"], "patch" => value["patch"], "patch_minor" => value["patch_minor"], "family" => value["family"]} == 
     {"major" => parseos(value["user_agent_string"]).major,
       "minor" => parseos(value["user_agent_string"]).minor,
       "patch" => parseos(value["user_agent_string"]).patch,
       "patch_minor" => parseos(value["user_agent_string"]).patch_minor,
       "family" => parseos(value["user_agent_string"]).family}
      println("PASS")
  else
      println("FAIL: ", value["user_agent_string"])
  end
end

#Test 4: Validation of parseuseragent
test_ua = YAML.load(open(Pkg.dir("UAParser", "test", "data", "test_user_agent_parser.yaml")));

for value in test_ua["test_cases"]
  if {"major" => value["major"], "minor" => value["minor"], "patch" => value["patch"], "family" => value["family"]} == 
    {"major" => parseuseragent(value["user_agent_string"]).major,
     "minor" => parseuseragent(value["user_agent_string"]).minor,
     "patch" => parseuseragent(value["user_agent_string"]).patch,
     "family" => parseuseragent(value["user_agent_string"]).family}
    println("PASS")
  else
    println("FAIL: ", value["user_agent_string"])
  end
end

#Test 5: Additional validation of parseuseragent
test_ua_2 = YAML.load(open(Pkg.dir("UAParser", "test", "data", "firefox_user_agent_strings.yaml")));

for value in test_ua_2["test_cases"]
  if {"major" => value["major"], "minor" => value["minor"], "patch" => value["patch"], "family" => value["family"]} == 
     {"major" => parseuseragent(value["user_agent_string"]).major,
     "minor" => parseuseragent(value["user_agent_string"]).minor,
     "patch" => parseuseragent(value["user_agent_string"]).patch,
     "family" => parseuseragent(value["user_agent_string"]).family}
    println("PASS")
  else
    println("FAIL: ", value["user_agent_string"])
  end
end
