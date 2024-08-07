module App
using GenieFramework
using Genie
using DataFrames
using CSV
@genietools
import Genie.Renderer.Html: normal_element, register_normal_element
register_normal_element("q__tr", context = @__MODULE__)
register_normal_element("q__td", context = @__MODULE__)

function update_dataframe!(df, table)
    for name in names(df)
        if name in names(table.data)
            df[:,name] = table.data[:,name]
        end
    end
end

function add_midterm(df)
    return df.Midtermtest .* df.MidtermWeight
end

function add_final(df)
    return df.FinalPercentage .* df.FinalWeight
end

studentDF = CSV.read("./testdata/gradesWfinaltest.csv", DataFrame);

@app begin
    # studentDF = CSV.read("./testdata/gradesWfinalSept.csv", DataFrame);
    @in table = DataTable(studentDF)
    @in TableSearch_dfilter = ""
    @in Button_process = false
    @in Button_Midterm = false
    @in Button_Final = false
    @in Button_save = false
    @in midtermWeight = 0.2
    @in finalWeight = 0.3

    @onbutton Button_Midterm begin
        update_dataframe!(studentDF, table)
        if "MidtermWeight" in names(studentDF)
            studentDF.MidtermWeight .= midtermWeight 
        else
            insertcols!(studentDF, :MidtermWeight => midtermWeight)
        end
        table = DataTable(studentDF)
        @info "Midterm was added"
        notify(__model__, "Midterm was processed")
    end

    @onbutton Button_Final begin
        update_dataframe!(studentDF, table)
        if "FinalWeight" in names(studentDF)
            studentDF.FinalWeight .= finalWeight 
        else
            insertcols!(studentDF, :FinalWeight => finalWeight)
        end
        table = DataTable(studentDF)
        @info "Final was added"
        notify(__model__, "Final was processed")
    end

    @onbutton Button_process begin
        update_dataframe!(studentDF, table)
        if "MidtermMark" in names(studentDF)
            studentDF.MidtermMark = round.(add_midterm(studentDF), digits=2)
        else
            insertcols!(studentDF, :MidtermMark => add_midterm(studentDF))
        end

        if "FinalMark" in names(studentDF)
            studentDF.FinalMark = round.(add_final(studentDF), digits=2)
        else
            insertcols!(studentDF, :FinalMark => add_final(studentDF))
        end
        list_of_assignments = [x for x in names(studentDF) if (occursin("assignment",x) || occursin("Assignment",x))]
        studentDF.homework = sum(eachcol(studentDF[:,list_of_assignments]))
        studentDF.Grade = round.(studentDF.MidtermMark .+ studentDF.FinalMark .+ studentDF.homework .+ studentDF.Finalproject)
        table = DataTable(studentDF)
        @info "Grades were calculated"
        notify(__model__, "Grades were calculated")
    end

    @onbutton Button_save begin
        update_dataframe!(studentDF, table)
        CSV.write("./testdata/gradesWfinaltest.csv",studentDF)
        @info "File was saved"
        notify(__model__, "Fila was saved")
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