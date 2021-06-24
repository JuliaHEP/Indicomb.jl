using Indicomb
using Documenter

DocMeta.setdocmeta!(Indicomb, :DocTestSetup, :(using Indicomb); recursive=true)

makedocs(;
    modules=[Indicomb],
    authors="Jerry Ling <proton@jling.dev> and contributors",
    repo="https://github.com/Jerry Ling/Indicomb.jl/blob/{commit}{path}#{line}",
    sitename="Indicomb.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Jerry Ling.github.io/Indicomb.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Jerry Ling/Indicomb.jl",
)
