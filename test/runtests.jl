using UAParser, YAML, Missings, Base.Test

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
    test_os = YAML.load(open(joinpath(dirname(@__FILE__), "data", "test_user_agent_parser_os.yaml")));

    for value in test_os["test_cases"]
        os = parseos(value["user_agent_string"])
        @test value["family"] == os.family
        @testparseval value "major" os
        @testparseval value "minor" os
        @testparseval value "patch_minor" os
    end
    
    #Test 3: Additional validation of parseos
    test_os_2 = YAML.load(open(joinpath(dirname(@__FILE__), "data", "additional_os_tests.yaml")));
    
    for value in test_os_2["test_cases"]
        os = parseos(value["user_agent_string"])
        @test value["family"] == os.family
        @testparseval value "major" os
        @testparseval value "minor" os
        @testparseval value "patch_minor" os
    end
end

@testset "parse_ua" begin
    #Test 4: Validation of parseuseragent
    test_ua = YAML.load(open(joinpath(dirname(@__FILE__), "data", "test_user_agent_parser.yaml")));
    
    for value in test_ua["test_cases"]
        ua = parseuseragent(value["user_agent_string"])
        @test value["family"] == ua.family
        @testparseval value "major" ua
        @testparseval value "minor" ua
        @testparseval value "patch" ua
    end
    
    #Test 5: Additional validation of parseuseragent
    test_ua_2 = YAML.load(open(joinpath(dirname(@__FILE__), "data", "firefox_user_agent_strings.yaml")));
    
    for value in test_ua_2["test_cases"]
        ua = parseuseragent(value["user_agent_string"])
        @test value["family"] == ua.family
        @testparseval value "major" ua
        @testparseval value "minor" ua
        @testparseval value "patch" ua
    end
end
