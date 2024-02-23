module App
using GenieFramework
using DataFrames
using CSV
@genietools

studentDF = CSV.read("./testdata/gradesWfinalSept.csv", DataFrame);

@app begin
    # studentDF = CSV.read("./testdata/gradesWfinalSept.csv", DataFrame);
    @out table = DataTable(studentDF)
    @in TableSearch_dfilter = ""
end

@page("/", "app.jl.html")


end