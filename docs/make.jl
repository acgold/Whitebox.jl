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
        "Getting Started" => "getting_started.md",
        "How it Works" => "how_it_works.md",
        "Reference" => "reference.md"
    ],
)

deploydocs(;
    repo="github.com/acgold/Whitebox.jl",
    devbranch="main",
)
