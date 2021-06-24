# Indicomb

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Moelf.github.io/Indicomb.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Moelf.github.io/Indicomb.jl/dev)
[![Build Status](https://github.com/Moelf/Indicomb.jl/workflows/CI/badge.svg)](https://github.com/Moelf/Indicomb.jl/actions)

# Quick Start
```
julia> t = Indicomb.get_indico_page("https://indico.cern.ch/", "/export/categ/1135.json";apikey="87495248-xxxxxxx", secret_key="20980c49-xxxxxx", from="2020-06-01", to="2030-06-01")
HTTP.Messages.Response:
"""
HTTP/1.1 200 OK
```
