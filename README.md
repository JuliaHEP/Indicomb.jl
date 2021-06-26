# Indicomb

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Moelf.github.io/Indicomb.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Moelf.github.io/Indicomb.jl/dev)
[![Build Status](https://github.com/Moelf/Indicomb.jl/workflows/CI/badge.svg)](https://github.com/Moelf/Indicomb.jl/actions)

# Quick Start

At the most top level, this pkg export a single function `get_events_cat_name`, that can be used to get (detailed) Indico events within
a category number, by events' `:title`:
```
julia> t = get_events_catnum_name("https://indico.cern.ch", 1X3X, "XXXXX"; from="2021-06-10", to="2021-06-30", apikey=".....", secretkey="....");

julia> t[1]
JSON3.Object{Vector{UInt8}, SubArray{UInt64, 1, Vector{UInt64}, Tuple{UnitRange{Int64}}, true}} with 29 entries:
  :_type            => "Conference"
  :id               => "10521XX"
  :title            => "XXXXX group meeting"
  :description      => ""
  :startDate        => {…
  :timezone         => "Europe/Zurich"
  :endDate          => {…
  :room             => ""
  :location         => ""
  :address          => ""
  :type             => "meeting"
  :references       => Union{}[]
  :_fossil          => "conferenceMetadataWithSubContribs"
  :categoryId       => 1X3X
  :category         => "Harvard University"
  :note             => {…
  :roomFullname     => ""
  :url              => "https://indico.cern.ch/event/10521XX/"
  :creationDate     => {…
  :creator          => {…
  :hasAnyProtection => true
  :roomMapURL       => nothing
  :folders          => JSON3.Object[{…
  :chairs           => Union{}[]
  :material         => JSON3.Object[{…
  :keywords         => Union{}[]
  :visibility       => {…
  :allowed          => {…
  :contributions    => JSON3.Object[{…
```

There are lower level stuff (more like utility functons I guess) in case you want to hack around. Feel free to raise quality of life improvement feature request.
```
julia> Indicomb.get_indico_page("https://indico.cern.ch/", "/export/categ/1135.json";apikey=".....", secret_key="xxxxxx", from="2021-06-01", to="2030-06-01")
HTTP.Messages.Response:
"""
HTTP/1.1 200 OK
```

# TODO
[ ] Ship a HTML page generation script and a CSS
