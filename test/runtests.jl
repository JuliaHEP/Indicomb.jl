using Indicomb
using Test, JSON3

@testset "Indico main function" begin
    t = get_events_catnum_name("https://indico.cern.ch", 6725, r"."; from="2021-06-01", to="2021-06-15")
    @test length(t) == 14
    t = get_events_catnum_name("https://indico.cern.ch", 6725, "Edition"; from="2021-06-01", to="2021-06-15")
    @test length(t) == 1
    @test contains(t[1][:title], "Edition of the Large")
end

@testset "Indico utility functions" begin
    re = Indicomb.indico_request("cern.ch/"; p = 3)
    @test re == "cern.ch/?p=3"

    t = Indicomb.get_indico_page(
        "https://indico.cern.ch",
        "/export/categ/6725.json";
        from="2021-06-01",
        to="2021-06-15",
    )
    @test t[:count] == 14
    @test t[:results][1][:_type] == "Conference"
    @test contains(t[:results][1][:title], "Edition of the Large")
end
