module App
using GenieFramework
using Genie
using DataFrames
using CSV
@genietools
import Genie.Renderer.Html: normal_element, register_normal_element
register_normal_element("q__tr", context = @__MODULE__)
register_normal_element("q__td", context = @__MODULE__)

studentDF = CSV.read("./testdata/gradesWfinalFeb.csv", DataFrame);

@app begin
    # studentDF = CSV.read("./testdata/gradesWfinalSept.csv", DataFrame);
    @in table = DataTable(studentDF)
    @in TableSearch_dfilter = ""
    @in Button_process = false

    @onbutton Button_process begin
        insertcols!(studentDF, :z => 1)
        table = DataTable(studentDF)
    end

    @in selected_student = ""
    @out student_info = studentDF.Student
    @out columns_info = []

    @out List_of_info = []

    @onchange table begin
        # CSV.write("./testdata/gradesWfinaltest.csv",table.data)
    end

    @onchange selected_student begin
        if selected_student != ""
            List_of_info = [values(studentDF[studentDF.Student .== selected_student, Not(:Student)][1,:])...]
            columns_info = names(studentDF[:, Not(:Student)])
        end
    end
end

@page("/", "app.jl.html")


end