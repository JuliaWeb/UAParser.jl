using UAParser, YAML
#Incorporate Base.Test at later date

#https://github.com/tobie/ua-parser/blob/master/test_resources/


#Test 1: Validation of parsedevice() against test file
test_device = YAML.load(open(Pkg.dir("UAParser", "test", "data", "test_device.yaml")));

for test_case in test_device["test_cases"]
  match = test_case["family"] == parsedevice(test_case["user_agent_string"])["family"]
  if match
    println("PASS: ", "User Agent: ", test_case["user_agent_string"])
  else
    println("FAIL: ", "User Agent: ", test_case["user_agent_string"])
  end
end

#Test 2: Validation of parseos against test files 

test_os = YAML.load(open(Pkg.dir("UAParser", "test", "data", "test_user_agent_parser_os.yaml")));

for value in test_os["test_cases"]
  if {"major" => value["major"], "minor" => value["minor"], "patch" => value["patch"], "patch_minor" => value["patch_minor"], "family" => value["family"]} == parseos(value["user_agent_string"]) 
      println("PASS")
  else
      println("FAIL: ", value["user_agent_string"])
  end
end

#Test 3
for value in test_os_2["test_cases"]
  if {"major" => value["major"], "minor" => value["minor"], "patch" => value["patch"], "patch_minor" => value["patch_minor"], "family" => value["family"]} == parseos(value["user_agent_string"]) 
      println("PASS")
  else
      println("FAIL: ", value["user_agent_string"])
  end
end

#Test 4: Validation of parseuseragent

test_ua = YAML.load(open(Pkg.dir("UAParser", "test", "data", "test_user_agent_parser.yaml")));

for value in test_ua["test_cases"]
  if {"major" => value["major"], "minor" => value["minor"], "patch" => value["patch"], "family" => value["family"]} == parseuseragent(value["user_agent_string"])
    println("PASS")
  else
    println("FAIL: ", value["user_agent_string"])
  end
end

#Test 5:

test_ua_2 = YAML.load(open(Pkg.dir("UAParser", "test", "data", "firefox_user_agent_strings.yaml")));

for value in test_ua_2["test_cases"]
  if {"major" => value["major"], "minor" => value["minor"], "patch" => value["patch"], "family" => value["family"]} == parseuseragent(value["user_agent_string"])
    println("PASS")
  else
    println("FAIL: ", value["user_agent_string"])
  end
end
