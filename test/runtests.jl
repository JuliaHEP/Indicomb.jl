using Indicomb
using Test, JSON3

@testset "Indicomb.jl" begin
    re = Indicomb.indico_request("cern.ch/"; p = 3)
    @test re == "cern.ch/?p=3"

    t = Indicomb.get_indico_page(
        "https://indico.cern.ch",
        "/export/categ/6725.json";
        from="2021-06-01",
        to="2021-06-15",
    )
    j = JSON3.read(String(t.body))
    @test ("Content-Type" => "application/json") ∈ t.headers
    @test j[:count] == 14
    @test j[:results][1][:_type] == "Conference"
    @test contains(j[:results][1][:title], "Edition of the Large")
end
