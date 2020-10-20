let
    Source = POS_Detail,
    #"Removed Other Columns" = Table.SelectColumns(Source,{"Key_Cust_Doc", "Detail: Line Sales code", "Detail: Line Sales code Description", "Detail: Note Line"}),
    #"Filtered Rows1" = Table.SelectRows(#"Removed Other Columns", each [#"Detail: Note Line"] <> null and [#"Detail: Note Line"] <> ""),
    #"Grouped Rows" = Table.Group(#"Filtered Rows1", {"Key_Cust_Doc", "Detail: Line Sales code", "Detail: Line Sales code Description"}, {{"Note Concat Table", each _, type table [Key_Cust_Doc=nullable text, #"Detail: Line Sales code"=nullable text, #"Detail: Line Sales code Description"=nullable text, #"Detail: Note Line"=nullable text]}}),
    #"Added Custom" = Table.AddColumn(#"Grouped Rows", "Note Concat List", each Table.Column([Note Concat Table], "Detail: Note Line")),
    #"Extracted Values" = Table.TransformColumns(#"Added Custom", {"Note Concat List", each Text.Combine(List.Transform(_, Text.From), ", "), type text}),
    #"Removed Columns" = Table.RemoveColumns(#"Extracted Values",{"Detail: Line Sales code Description", "Note Concat Table"})
in
    #"Removed Columns"



let
    Source = POS_Detail_Notes_By_Code,
    #"Grouped Rows" = Table.Group(Source, {"Key_Cust_Doc"}, {{"Note Concat Table", each _, type table [Key_Cust_Doc=nullable text, #"Note Concat List"= nullable text]}}),
    #"Added Custom" = Table.AddColumn(#"Grouped Rows", "Note Concat List", each Table.Column([Note Concat Table], "Note Concat List")),
    #"Extracted Values" = Table.TransformColumns(#"Added Custom", {"Note Concat List", each Text.Combine(List.Transform(_, Text.From), ", "), type text}),
    #"Removed Columns" = Table.RemoveColumns(#"Extracted Values",{"Note Concat Table"})
in
    #"Removed Columns"