using UAParser, YAML, Test

#These user-agents look to be older, may not still be out in wild


# a helper macro for creating tests
macro testparseval(obj::Symbol, valname::String, outputname::Symbol)
    valsymb = Symbol(valname)
    esc(quote
        if $obj[$valname] == nothing
            @test ismissing($outputname.$valsymb)
        else
            @test $obj[$valname] == $outputname.$valsymb
        end
    end)
end



@testset "parse_device" begin
    #Test 1: Validation of parsedevice
    test_device = YAML.load(open(joinpath(dirname(@__FILE__), "data", "test_device.yaml")));

    for test_case in test_device["test_cases"]
        @test test_case["family"] == parsedevice(test_case["user_agent_string"]).family
    end
end

@testset "parse_os" begin
    #Test 2: Validation of parseos
    test_os = YAML.load(open(joinpath(dirname(@__FILE__), "data", "test_os.yaml")));

    for value in test_os["test_cases"]
        os = parseos(value["user_agent_string"])
        @test value["family"] == os.family
        @testparseval value "major" os
        @testparseval value "minor" os
        @testparseval value "patch_minor" os
    end
end

@testset "parse_ua" begin
    #Test 4: Validation of parseuseragent
    test_ua = YAML.load(open(joinpath(dirname(@__FILE__), "data", "test_ua.yaml")));

    for value in test_ua["test_cases"]
        ua = parseuseragent(value["user_agent_string"])
        @test value["family"] == ua.family
        @testparseval value "major" ua
        @testparseval value "minor" ua
        @testparseval value "patch" ua
    end
end
