using UAParser, YAML
#Incorporate Base.Test at later date

#Validation of getdevice() against test file
#https://github.com/tobie/ua-parser/blob/master/test_resources/test_device.yaml

test_device = YAML.load(open(Pkg.dir("UAParser", "test", "data", "test_device.yaml")));

for test_case in test_device["test_cases"]
  match = test_case["family"] == getdevice(test_case["user_agent_string"])["family"]
  if match
    println("PASS: ", "User Agent: ", test_case["user_agent_string"])
  else
    println("FAIL: ", "User Agent: ", test_case["user_agent_string"])
  end
end