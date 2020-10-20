let
    // Only load if need, expensive query
    Source = if notes_include = "Yes"
        then POS_Detail_Extract_Filter
        else Table.FromRows(
        {{"NoValue-WA11111", "No",10,"No Sales Code", "Would be some note text here"}},
        {"Key_Cust_Doc", "Detail: Line Sales code", "Detail: Line Number", "Detail: Line Sales code Description", "Detail: Note Line"}),
    // Only columns needed to group
    #"Removed Other Columns" = Table.SelectColumns(Source,{"Key_Cust_Doc", "Detail: Line Sales code", "Detail: Line Sales code Description", "Detail: Note Line"}),
    //Filter out rows with know notes
    #"Filtered Rows1" = Table.SelectRows(#"Removed Other Columns", each [#"Detail: Note Line"] <> null and [#"Detail: Note Line"] <> ""),
    // Create column with a table of group
    #"Grouped Rows" = Table.Group(#"Filtered Rows1", {"Key_Cust_Doc", "Detail: Line Sales code", "Detail: Line Sales code Description"}, {{"Note Concat Table", each _, type table [Key_Cust_Doc=nullable text, #"Detail: Line Sales code"=nullable text, #"Detail: Line Sales code Description"=nullable text, #"Detail: Note Line"=nullable text]}}),
    // Create list of notes to concat
    #"Added Custom" = Table.AddColumn(#"Grouped Rows", "Note Concat List", each Table.Column([Note Concat Table], "Detail: Note Line")),
    // Concat list of notes into field
    #"Extracted Values" = Table.TransformColumns(#"Added Custom", {"Note Concat List", each Text.Combine(List.Transform(_, Text.From), ", "), type text}),
    // Remove all but key and note
    #"Removed Columns" = Table.RemoveColumns(#"Extracted Values",{"Detail: Line Sales code Description", "Note Concat Table"})
in
    #"Removed Columns"