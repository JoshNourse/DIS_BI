let
    // Input is a list of files selected based upon data_source parameter
    Source = _Production_Data_Select,
    // Filter the files to include in the data
     #"Filtered Files" = 
        
            Table.SelectRows(Source, each 
                Text.Contains([File_Name], "Detail_Current") 
                or Text.Contains([File_Name], "Detail_Posted") 
                and Text.Contains([File_Name], "csv") // Need to ignore the "Detail_Posted*.xls until legacy workbooks retired and these files removed
                and Number.FromText([year_posted]) >= date_year_posted_start // Dont want to touch these big old files if we dont need to
            ),
    // create a list of columns to remove from expanded table
    folder_columns = List.Buffer(Table.ColumnNames(#"Filtered Files")),
 /*   #"Filtered Files" = *****TRY: Remove Table.Buffer: Probably does not work: Chris Webb "Buffers are shallow********
        Table.Buffer(
            Table.SelectRows(Source, each 
                Text.Contains([File_Name], "Detail_Current") 
                or Text.Contains([File_Name], "Detail_Posted") 
                and Text.Contains([File_Name], "csv") // Need to ignore the "Detail_Posted*.xls until legacy workbooks retired and these files removed
                and Number.FromText([year_posted]) >= date_year_posted_start // Dont want to touch these big old files if we dont need to
            )
        ),*/
    // Conditionally create table(and promote headers) from each file based upon file type
    #"Extract Table From File" = Table.AddColumn(#"Filtered Files", "Data", each 
        if Text.Contains([Extension], "xls") 
            then Table.PromoteHeaders(
				Excel.Workbook([Content]){[Item="Sheet1",Kind="Sheet"]}[Data]
                , [PromoteAllScalars=true])
        else if Text.Contains([Extension], "csv") 
            then Table.PromoteHeaders(
                    Csv.Document([Content],[Delimiter=",", Encoding=1252, QuoteStyle=QuoteStyle.None])
                , [PromoteAllScalars=true])
        else "Need to specify extraction method"),
    // Combine the table from each file
    #"Expanded Data" = Table.ExpandTableColumn(#"Extract Table From File", 
        "Data", 
        Table.ColumnNames(#"Extract Table From File"[#"Data"]{0})
        ),
        // Remove extra ccoluns from folder access
    #"Removed Columns" = Table.RemoveColumns( //PBI 1:35 seconds on this step, #Filtered Files was Table.Buffer, took out
        #"Expanded Data",
        folder_columns),
    //Create Composit key of Customer and Order number
    #"Insert Key_Cust_Doc" = Table.AddColumn(#"Removed Columns", "Key_Cust_Doc", each Text.Combine({[#"Address#/Stock#"], [#"Document#"]}, "-"), type text),
    // TODO Promote to index?


    //__________FILTERS____GOAL: Filter by records in POS_Summary which alreay has been filtered by parameters_______
        
    //********1st Method******** Use an inner join to POS_Summary, Dont like that it basically adds a column of tables
    // TODO try Table.buffer here
    //#"Filter by inner join to POS_Summary" = Table.NestedJoin(#"Insert Key_Cust_Doc", {"Key_Cust_Doc"}, POS_Summary_Load, {"Key_Cust_Doc"}, "POS_Summary", JoinKind.Inner),
    // This can be removed, only used for testing
    // #"Join only key" = Table.ExpandTableColumn(#"Filter by inner join to POS_Summary", "POS_Summary", {"Key_Cust_Doc"}, {"Key_Cust_Doc"}),

    //********2nd Method, Using List.Contains on a list of Keys from POS_Summary (THIS SEEMS FAST (After adding buffer)
    // Create a list of the keys in POS_Summary
    summary_keys_list = List.Buffer(POS_Summary_Extract_Filter[Key_Cust_Doc]),
    // Use List.Contains to filter the POS_Detail Table
    #"Filter with POS_Summary Key List" = Table.SelectRows(#"Insert Key_Cust_Doc", each List.Contains(summary_keys_list,[Key_Cust_Doc]))

    // ******** LAST RESORT*****
    // // Just filter using parameters identical to POS_Summary but maintain same code in two places,
    // Although probably good for performance without extra call to POS Summary.
    // Possibly turn filter into function to be called by both
    // // Filter on Date Posted to be >= the Parameter date_year_posted_Start and include open documents
    // // Filter Document Division by parameter doc_division
    // // Filter Document Code by parameter doc_code
    // // Filter Document Type by parameter doc_type
    // // Filter Document Status by parameter doc_status
    // 

in
    #"Filter with POS_Summary Key List"


/*
Original Hard Codeded columns from expand
// {"Division", "Address/Stock flag (A/S)", "Address#/Stock#", "Customer Name", "Customer Contact Notes", "Customer Tracked as Contact (Y/N)", "Customer Contact Territory Code", "Customer Contact Territory Description", "Customer Contact Sales Rep Addrs#", "Customer Contact Sales Rep First Name", "Customer Contact Sales Rep Last Name", "Stock# In Date (CCYYMMDD)", "Stock# In Date", "Stock# In Days (Today - In Date)", "Document#", "Document Code", "Document Type (W/S/Q)", "Document Status (O/R/C/k=Cancelled)", "Document Posted? (P or ' ')", "Date Opened (CCYYMMDD)", "Date Opened", "Days since Opened (Today-Opened)", "Date Closed/Printed (CCYYMMDD)", "Date Closed/Printed", "Date Posted (CCYYMMDD)", "Date Posted", "Detail: Format for Sales code", "Detail: Line Segmentation", "Detail: Line Sales code", "Detail: Line Sales code Description", "Detail: Line Number", "Detail: Int./Warr. (I/W if open,  i/w if closed)", "Detail: Line Description", "Detail: Line Tax code (Standard: 1 character)", "Detail: Line Tax code (Advanced: 3 character)", "Detail: Line Tax Type", "Detail: Line GST Rate", "Detail: Line Discount code", "Detail: Line Discount Rate", "Detail: Line Quantity", "Detail: Line Price", "Detail: Line Price[Ext] (Qty x Price)", "Detail: Line Discount (Price[Ext] x Discount Rate)", "Detail: Line Price[Dscnt] (Price[Ext] - Discount)", "Detail: Line Cost", "Detail: Line Cost[Ext] (Qty x Cost)", "Detail: Line Price[Net] (Price[Dscnt] - Cost[Ext])", "Detail: Part Profit Margin (100*Price[Net]/Price[Dscnt])", "Detail: Part Vendor Code", "Detail: Part Class Code", "Detail: Part Number", "Detail: Part Serial Number", "Detail: Part Ext Warranty", "Detail: Part Ext Warranty Memo", "Detail: Part Priority Order Code", "Detail: Part Price Code", "Detail: Part Bin Location", "Detail: Part Bin Location-2", "Detail: Part Warr flag", "Detail: Part Stocking Ind.", "Detail: Part No Demand flag", "Detail: Part Superseded flag", "Detail: Part MFR - Market Code", "Detail: Part MFR - Product Line", "Detail: Part MFR - Product Code", "Detail: Part MFR - Price Category", "Detail: Part MFR - Promo ID", "Detail: Labor Tech Number", "Detail: Labor Date (CCYYMMDD)", "Detail: Labor Date worked", "Detail: Labor TimeOut(HHMMSS)", "Detail: Labor Hrs Reported", "Detail: Labor Hrs Billed", "Detail: Labor Rate", "Detail: Labor Billed[Ext] (Billed Hours x Billed Rate)", "Detail: Labor Discount (Billed[Ext] x Discount Rate)", "Detail: Labor Billed[Net] (Billed[Ext] - Discount)", "Detail: Labor Job Code", "Detail: Labor Job (ThemoKing)", "Detail: Labor TimeClock Status Code", "Detail: Labor TimeClock Work Type", "Detail: Note Line", "Detail: WG Unit Number", "Detail: WG Unit Status (A/R/F/S)", "Detail: WG Unit Make (Short)", "Detail: WG Unit Make (Long)", "Detail: WG Unit Model (Short)", "Detail: WG Unit Model (Long)", "Detail: WG Unit Description", "Detail: WG Unit Serial Number", "Detail: WG Unit In Date (CCYYMMDD)", "Detail: WG Unit In Date", "Detail: WG Unit In Days (Today - In Date)", "Detail: WG Warr Exp(CCYYMMDD)", "Detail: WG Warr Exp Date", "Detail: WG Warr Code", "Detail: Rental Unit#", "Detail: Rental Unit Make (Short)", "Detail: Rental Unit Make (Long)", "Detail: Rental Unit Model (Short)", "Detail: Rental Unit Model (Long)", "Detail: Rental Unit Description", "Detail: Rental Unit Serial#", "Detail: Rental Status Flag (Rent=R / Unrent=U / Bypass=B)", "Detail: Rental Rate Code (custom code only)", "Detail: Rental Out(CCYYMMDD)", "Detail: Rental Out Date", "Detail: Rental In (CCYYMMDD)", "Detail: Rental In Date", "Detail: Rental Hr Meter Out", "Detail: Rental Hr Meter In"}, {"Division", "Address/Stock flag (A/S)", "Address#/Stock#", "Customer Name", "Customer Contact Notes", "Customer Tracked as Contact (Y/N)", "Customer Contact Territory Code", "Customer Contact Territory Description", "Customer Contact Sales Rep Addrs#", "Customer Contact Sales Rep First Name", "Customer Contact Sales Rep Last Name", "Stock# In Date (CCYYMMDD)", "Stock# In Date", "Stock# In Days (Today - In Date)", "Document#", "Document Code", "Document Type (W/S/Q)", "Document Status (O/R/C/k=Cancelled)", "Document Posted? (P or ' ')", "Date Opened (CCYYMMDD)", "Date Opened", "Days since Opened (Today-Opened)", "Date Closed/Printed (CCYYMMDD)", "Date Closed/Printed", "Date Posted (CCYYMMDD)", "Date Posted", "Detail: Format for Sales code", "Detail: Line Segmentation", "Detail: Line Sales code", "Detail: Line Sales code Description", "Detail: Line Number", "Detail: Int./Warr. (I/W if open,  i/w if closed)", "Detail: Line Description", "Detail: Line Tax code (Standard: 1 character)", "Detail: Line Tax code (Advanced: 3 character)", "Detail: Line Tax Type", "Detail: Line GST Rate", "Detail: Line Discount code", "Detail: Line Discount Rate", "Detail: Line Quantity", "Detail: Line Price", "Detail: Line Price[Ext] (Qty x Price)", "Detail: Line Discount (Price[Ext] x Discount Rate)", "Detail: Line Price[Dscnt] (Price[Ext] - Discount)", "Detail: Line Cost", "Detail: Line Cost[Ext] (Qty x Cost)", "Detail: Line Price[Net] (Price[Dscnt] - Cost[Ext])", "Detail: Part Profit Margin (100*Price[Net]/Price[Dscnt])", "Detail: Part Vendor Code", "Detail: Part Class Code", "Detail: Part Number", "Detail: Part Serial Number", "Detail: Part Ext Warranty", "Detail: Part Ext Warranty Memo", "Detail: Part Priority Order Code", "Detail: Part Price Code", "Detail: Part Bin Location", "Detail: Part Bin Location-2", "Detail: Part Warr flag", "Detail: Part Stocking Ind.", "Detail: Part No Demand flag", "Detail: Part Superseded flag", "Detail: Part MFR - Market Code", "Detail: Part MFR - Product Line", "Detail: Part MFR - Product Code", "Detail: Part MFR - Price Category", "Detail: Part MFR - Promo ID", "Detail: Labor Tech Number", "Detail: Labor Date (CCYYMMDD)", "Detail: Labor Date worked", "Detail: Labor TimeOut(HHMMSS)", "Detail: Labor Hrs Reported", "Detail: Labor Hrs Billed", "Detail: Labor Rate", "Detail: Labor Billed[Ext] (Billed Hours x Billed Rate)", "Detail: Labor Discount (Billed[Ext] x Discount Rate)", "Detail: Labor Billed[Net] (Billed[Ext] - Discount)", "Detail: Labor Job Code", "Detail: Labor Job (ThemoKing)", "Detail: Labor TimeClock Status Code", "Detail: Labor TimeClock Work Type", "Detail: Note Line", "Detail: WG Unit Number", "Detail: WG Unit Status (A/R/F/S)", "Detail: WG Unit Make (Short)", "Detail: WG Unit Make (Long)", "Detail: WG Unit Model (Short)", "Detail: WG Unit Model (Long)", "Detail: WG Unit Description", "Detail: WG Unit Serial Number", "Detail: WG Unit In Date (CCYYMMDD)", "Detail: WG Unit In Date", "Detail: WG Unit In Days (Today - In Date)", "Detail: WG Warr Exp(CCYYMMDD)", "Detail: WG Warr Exp Date", "Detail: WG Warr Code", "Detail: Rental Unit#", "Detail: Rental Unit Make (Short)", "Detail: Rental Unit Make (Long)", "Detail: Rental Unit Model (Short)", "Detail: Rental Unit Model (Long)", "Detail: Rental Unit Description", "Detail: Rental Unit Serial#", "Detail: Rental Status Flag (Rent=R / Unrent=U / Bypass=B)", "Detail: Rental Rate Code (custom code only)", "Detail: Rental Out(CCYYMMDD)", "Detail: Rental Out Date", "Detail: Rental In (CCYYMMDD)", "Detail: Rental In Date", "Detail: Rental Hr Meter Out", "Detail: Rental Hr Meter In"}

*/