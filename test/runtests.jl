using UAParser, YAML, Test

# a helper macro for creating tests
macro testparseval(obj::Symbol, valname::String, outputname::Symbol)
    valsymb = Symbol(valname)
    esc(quote
        if $obj[$valname] == nothing
            ismissing($outputname.$valsymb)
        else
            $obj[$valname] == $outputname.$valsymb
        end
    end)
end

#Since parser is known not to be 100% compatible with source Python parser (see README), testing accuracy
#Accuracy stats derived from test files for v0.6 of package
#Any future changes to parsing code will be evaluated against this standard

@testset "parse_device" begin
    #Test 1: Validation of parsedevice
    test_device = YAML.load(open(joinpath(dirname(@__FILE__), "data", "test_device.yaml")))

    pass = 0
    fail = 0
    for test_case in test_device["test_cases"]
        old_fail = fail
        str = test_case["user_agent_string"]
        dev = parsedevice(str)
        test_case["family"] == dev.family ? pass += 1 : fail += 1
        fail == old_fail || @info """When parsing device for "$str", expect $test_case, but got $dev"""
    end

    @test pass/(pass + fail) >= 0.999

end

@testset "parse_os" begin
    #Test 2: Validation of parseos
    test_os = YAML.load(open(joinpath(dirname(@__FILE__), "data", "test_os.yaml")))

    pass = 0
    fail = 0

    for test_case in test_os["test_cases"]
        old_fail = fail
        str = test_case["user_agent_string"]
        os = parseos(str)
        test_case["family"] == os.family ? pass += 1 : fail += 1
        (@testparseval test_case "major" os) ? pass += 1 : fail += 1
        (@testparseval test_case "minor" os) ? pass += 1 : fail += 1
        (@testparseval test_case "patch_minor" os) ? pass += 1 : fail += 1
        fail == old_fail || @info """When parsing os for "$str", expect $test_case, but got $os"""
    end

    @test pass/(pass + fail) >= 0.999

end

@testset "parse_ua" begin
    #Test 4: Validation of parseuseragent
    test_ua = YAML.load(open(joinpath(dirname(@__FILE__), "data", "test_ua.yaml")))

    pass = 0
    fail = 0

    for test_case in test_ua["test_cases"]
        old_fail = fail
        str = test_case["user_agent_string"]
        ua = parseuseragent(str)
        test_case["family"] == ua.family ? pass += 1 : fail += 1
        (@testparseval test_case "major" ua) ? pass += 1 : fail += 1
        (@testparseval test_case "minor" ua) ? pass += 1 : fail += 1
        (@testparseval test_case "patch" ua) ? pass += 1 : fail += 1
        fail == old_fail || @info """When parsing ua for "$str", expect $test_case, but got $ua"""
    end

    @test pass/(pass + fail) >= 0.999

end
