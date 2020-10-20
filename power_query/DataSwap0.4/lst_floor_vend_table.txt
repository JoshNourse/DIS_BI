let
     Source = _Production_Data_Select,
    // Filter the files to include in the correct data source
    
	file_name = "_lists",
	table_sheet_name = "lst_floor_vend",
	// table_sheet_name = "lst_gl_accts",
	// table_sheet_name = "lst_makes",
	// table_sheet_name = "lst_sales_code",
	
	// file_name = "_aae_zip_county_Tables",
	// table_sheet_name = "tbl_county",
	// table_sheet_name = "tbl_zip_codes",
	
    table_kind = "Table",  // "Table" for an Excel Table, "Sheet" for everything else
    #"Filtered Files" = 
        Table.Buffer(
            Table.SelectRows(Source, each 
            Text.Contains([Name], file_name) 
            )
        ),
    // Conditionally create table(and promote headers) from each file based upon file type
    #"Extract Table From File" = Table.AddColumn(#"Filtered Files", "Data", each 
        if table_kind = "Table"
        then Excel.Workbook([Content]){[Item=table_sheet_name,Kind="Table"]}[Data]
        else if Text.Contains([Extension], "xls") 
        then Table.PromoteHeaders(
                Excel.Workbook([Content]){[Item=table_sheet_name,Kind="Sheet"]}[Data]
            , [PromoteAllScalars=true])
        else if Text.Contains([Extension], "csv") 
        then Table.PromoteHeaders(
                Csv.Document([Content],[Delimiter=",", Encoding=1252, QuoteStyle=QuoteStyle.None])
            , [PromoteAllScalars=true])
        else "Need to specify extraction method"),
    // expand the extracted table of each file into single table
    #"Expanded Data" = Table.ExpandTableColumn(#"Extract Table From File", 
        "Data", 
        // Column name to extract were hard coded, changed below to read columns from first table in file selections
        Table.ColumnNames(#"Extract Table From File"[#"Data"]{0})
        ),
    // Remove columns added by folder table
    #"Removed Columns" = Table.RemoveColumns( 
        #"Expanded Data",
        Table.ColumnNames(#"Filtered Files")
        ),
    //_______TRANSFROM_______________
    #"Changed Type" = Table.TransformColumnTypes(#"Removed Columns",
        {{"Flooring Vendor#", type text}, {"Flooring Name", type text}}
        )

	lst_floor_vend_types = {{"Flooring Vendor#", type text}, {"Flooring Name", type text}}
	lst_gl_acct_types = {{"Inventory Acct #", type text}, {"Description", type text}, {"InvGroup", type text}}
	lst_makes_types = {{"Make", type text}, {"Make Name", type text}}
	lst_sales_code_types = {{"Sales POS Sales Code", type text}, {"Name", type text}, {"Department", type text}}
	tbl_county_types = {"ID", Int64.Type}, {"Country", type text}, {"State", type text}, {"CountyShort", type text}, {"CountyLong", type text}, {"IsActive", type logical}, {"DateStart", type date}, {"DateEnd", type date}, {"Memo", type text}, {"StateCounty", type text}, {"aae_rings", type text}, {"StateCountyLong", type text}}
	tbl_zip_codes_types = {{"PostalCode", type text}, {"State", type text}, {"Type", type text}, {"County", type text}, {"PrimaryCity", type text}, {"AcceptableCities", type text}, {"UnacceptableCities", type text}, {"TimeZone", type text}, {"AreaCodes", type text}, {"Latitude", type number}, {"Longitude", type number}, {"WorldRegion", type text}, {"Country", type text}, {"Decommissioned", type logical}, {"EstimatedPolulation", Int64.Type}, {"Notes", type text}, {"State-County", type text}}
in
    #"Changed Type"