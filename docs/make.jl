using Whitebox
using Documenter

DocMeta.setdocmeta!(Whitebox, :DocTestSetup, :(using Whitebox); recursive=true)

makedocs(;
    modules=[Whitebox],
    authors="Adam Gold",
    repo="https://github.com/acgold/Whitebox.jl/blob/{commit}{path}#{line}",
    sitename="Whitebox.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://acgold.github.io/Whitebox.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/acgold/Whitebox.jl",
    devbranch="main",
)
