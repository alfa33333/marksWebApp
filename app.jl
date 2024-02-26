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

    @in selected_student = ""
    @out student_info = studentDF.Student
    @out columns_info = []

    @out List_of_info = []

    @onchange selected_student begin
        if selected_student != ""
            List_of_info = [values(studentDF[studentDF.Student .== selected_student, Not(:Student)][1,:])...]
            columns_info = names(studentDF[:, Not(:Student)])
        end
    end
end

@page("/", "app.jl.html")


end