let
    // Input is a list of files selected based upon data_source parameter
    Source = _Production_Data_Select,
    // Filter the files to include in the data
    #"Filtered Files" = Table.SelectRows(Source, each 
        Text.Contains([Name], "Summary"     ) 
    and Text.Contains([Name], "Current.xls" ) 
    or  Text.Contains([Name], "History.csv" )
    ),
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
    #"Expanded Data" = Table.ExpandTableColumn(#"Extract Table From File", "Data",
        // TODO can this hard coded list of column names be generated dynamically from reading headers? 
        {"Division", "Addrs/Stk flag (A/S)", "Address#/Stock#", "Customer Name", "Customer Name (Extended)", "Customer Street Address", "Customer Street Address (Extended)", "Customer City/State/Province", "Customer Postal Code", "Customer Phone-1 Area Code", "Customer Phone-2 PreFix", "Customer Phone-3 Base Number", "Customer Default EMAIL address", "Customer Default Tax Code (Standard: 1 character)", "Customer Default Tax Code (Advanced: 3 character)", "Customer Default Tax Type", "Customer Default Tax Number", "Customer Marketing Sort Code: 01", "Customer Marketing Sort Code: 02", "Customer Marketing Sort Code: 03", "Customer Marketing Sort Code: 04", "Customer Marketing Sort Code: 05", "Customer Marketing Sort Code: 06", "Customer Marketing Sort Code: 07", "Customer Marketing Sort Code: 08", "Customer Marketing Sort Code: 09", "Customer Marketing Sort Code: 10", "Stock# Status", "Stock# Make (Short)", "Stock# Make (Long)", "Stock# Model (Short)", "Stock# Model (Long)", "Stock# Description", "Stock# Serial Number", "Document#", "Document Last Print Counter", "Document Code", "Document Type (W/S/Q)", "Document Status (O/R/C/k=Cancelled)", "Document Posted? (P or ' ')", "Document (Charge=R / Cash=S)", "Document Credit Card", "Document Credit Card Amount", "Document Credit Card Expires (CCYYMM)", "Document Credit Card Plan Number", "Document Credit Card Tranx Date (CCYYMMDD)", "Document Credit Card Tranx Date", "Document Credit Card Tranx Time (HHMMSS)", "Document Credit Card Tranx Auth#", "Document Credit Card Tranx Auth. Status", "Document Credit Card Tranx Settled (Y/N)", "Document Credit Card Tranx Ref#", "Date Opened (CCYYMMDD)", "Date Opened", "Days since Opened (Today-Opened)", "Date Closed/Printed (CCYYMMDD)", "Date Closed/Printed", "Days to Close (Closed-Opened)", "Days since Closed (Today-Closed)", "Date Posted (CCYYMMDD)", "Date Posted", "Days to Post (Posted-Opened)", "Days since Posted (Today-Posted)", "Document Sold By Address#", "Document Sold By Name", "Document PO#", "Document Amount (Parts)", "Document Amount (Labor)", "Document Amount (Other)", "Document Amount (Total)", "WIP Reason Open Code", "WIP Reason Open Code Descr.", "WIP Service Bay", "WIP Labor Minimum Amount", "WIP Labor Minimum Sales Code", "WIP Labor Maximum Amount", "WIP Labor Maximum Sales Code", "WIP Non-Revenue? (Y=Yes)", "WIP Last Note Date (CCYYMMDD)", "WIP Last Note Date", "WIP Last Note Time (HHMM)", "WIP Last Note", "WIP Followup Date (CCYYMMDD)", "WIP Followup Date", "WIP Start Date (CCYYMMDD)", "WIP Start Date", "WIP Est. Complete Date (CCYYMMDD)", "WIP Est Complete Date", "WIP Last Punch Date (CCYYMMDD)", "WIP Last Punch Date", "WIP Last Punch Days to Close (Closed - Last Punch)", "WIP First Punch Days to Open (First Punch - Open Date)", "Total Reported Hrs (HHMMSS)", "Total Billed Hrs (HHMMSS)", "Document Tax Number", "Document GST Code", "Overide Debit Acct (custom)", "Document Transfer Out flag", "Document Group/Van Code", "Document Ship By", "Document ShipTo: Name", "Document ShipTo: Name (Ext)", "Document ShipTo: Address", "Document ShipTo: Address (Ext)", "Document ShipTo: City, State", "Document ShipTo: Zip Code", "Document Rent Interval (I/M/W)", "Document Rent Frequency", "Document Rent Date (CCYYMMDD)", "Document Rent Date", "Work Order: ThermoKing SVC ", "Work Order: ThermoKing Warr ", "Work Order: Warranty Code", "Work Order: Make (Short)", "Work Order: Make (Long)", "Work Order: Model (Short)", "Work Order: Model (Long)", "Work Order: Serial Number", "Work Order: Hour Meter", "Work Order: Unit Year (CCYY)", "Work Order: Int. flag (A/S)", "Work Order: Int. Addrs#/Stk#", "Work Order: Int. Cust. Name", "Work Order: Int. Stk# Make (Short)", "Work Order: Int. Stk# Make (Long)", "Work Order: Int. Stk# Model (Short)", "Work Order: Int. Stk# Model (Long)", "Work Order: Int. Stk# Descr.", "Work Order: Int. Stk# Serial#", "Work Order: Warr. Addrs#", "Work Order: Warr. Name", "Work Order: Customer Unit#", "Work Order: Fleet Svc flag", "Work Order: Flt Svc (CCYYMMDD)", "Work Order: Flt Svc Date"}, {"Division", "Addrs/Stk flag (A/S)", "Address#/Stock#", "Customer Name", "Customer Name (Extended)", "Customer Street Address", "Customer Street Address (Extended)", "Customer City/State/Province", "Customer Postal Code", "Customer Phone-1 Area Code", "Customer Phone-2 PreFix", "Customer Phone-3 Base Number", "Customer Default EMAIL address", "Customer Default Tax Code (Standard: 1 character)", "Customer Default Tax Code (Advanced: 3 character)", "Customer Default Tax Type", "Customer Default Tax Number", "Customer Marketing Sort Code: 01", "Customer Marketing Sort Code: 02", "Customer Marketing Sort Code: 03", "Customer Marketing Sort Code: 04", "Customer Marketing Sort Code: 05", "Customer Marketing Sort Code: 06", "Customer Marketing Sort Code: 07", "Customer Marketing Sort Code: 08", "Customer Marketing Sort Code: 09", "Customer Marketing Sort Code: 10", "Stock# Status", "Stock# Make (Short)", "Stock# Make (Long)", "Stock# Model (Short)", "Stock# Model (Long)", "Stock# Description", "Stock# Serial Number", "Document#", "Document Last Print Counter", "Document Code", "Document Type (W/S/Q)", "Document Status (O/R/C/k=Cancelled)", "Document Posted? (P or ' ')", "Document (Charge=R / Cash=S)", "Document Credit Card", "Document Credit Card Amount", "Document Credit Card Expires (CCYYMM)", "Document Credit Card Plan Number", "Document Credit Card Tranx Date (CCYYMMDD)", "Document Credit Card Tranx Date", "Document Credit Card Tranx Time (HHMMSS)", "Document Credit Card Tranx Auth#", "Document Credit Card Tranx Auth. Status", "Document Credit Card Tranx Settled (Y/N)", "Document Credit Card Tranx Ref#", "Date Opened (CCYYMMDD)", "Date Opened", "Days since Opened (Today-Opened)", "Date Closed/Printed (CCYYMMDD)", "Date Closed/Printed", "Days to Close (Closed-Opened)", "Days since Closed (Today-Closed)", "Date Posted (CCYYMMDD)", "Date Posted", "Days to Post (Posted-Opened)", "Days since Posted (Today-Posted)", "Document Sold By Address#", "Document Sold By Name", "Document PO#", "Document Amount (Parts)", "Document Amount (Labor)", "Document Amount (Other)", "Document Amount (Total)", "WIP Reason Open Code", "WIP Reason Open Code Descr.", "WIP Service Bay", "WIP Labor Minimum Amount", "WIP Labor Minimum Sales Code", "WIP Labor Maximum Amount", "WIP Labor Maximum Sales Code", "WIP Non-Revenue? (Y=Yes)", "WIP Last Note Date (CCYYMMDD)", "WIP Last Note Date", "WIP Last Note Time (HHMM)", "WIP Last Note", "WIP Followup Date (CCYYMMDD)", "WIP Followup Date", "WIP Start Date (CCYYMMDD)", "WIP Start Date", "WIP Est. Complete Date (CCYYMMDD)", "WIP Est Complete Date", "WIP Last Punch Date (CCYYMMDD)", "WIP Last Punch Date", "WIP Last Punch Days to Close (Closed - Last Punch)", "WIP First Punch Days to Open (First Punch - Open Date)", "Total Reported Hrs (HHMMSS)", "Total Billed Hrs (HHMMSS)", "Document Tax Number", "Document GST Code", "Overide Debit Acct (custom)", "Document Transfer Out flag", "Document Group/Van Code", "Document Ship By", "Document ShipTo: Name", "Document ShipTo: Name (Ext)", "Document ShipTo: Address", "Document ShipTo: Address (Ext)", "Document ShipTo: City, State", "Document ShipTo: Zip Code", "Document Rent Interval (I/M/W)", "Document Rent Frequency", "Document Rent Date (CCYYMMDD)", "Document Rent Date", "Work Order: ThermoKing SVC ", "Work Order: ThermoKing Warr ", "Work Order: Warranty Code", "Work Order: Make (Short)", "Work Order: Make (Long)", "Work Order: Model (Short)", "Work Order: Model (Long)", "Work Order: Serial Number", "Work Order: Hour Meter", "Work Order: Unit Year (CCYY)", "Work Order: Int. flag (A/S)", "Work Order: Int. Addrs#/Stk#", "Work Order: Int. Cust. Name", "Work Order: Int. Stk# Make (Short)", "Work Order: Int. Stk# Make (Long)", "Work Order: Int. Stk# Model (Short)", "Work Order: Int. Stk# Model (Long)", "Work Order: Int. Stk# Descr.", "Work Order: Int. Stk# Serial#", "Work Order: Warr. Addrs#", "Work Order: Warr. Name", "Work Order: Customer Unit#", "Work Order: Fleet Svc flag", "Work Order: Flt Svc (CCYYMMDD)", "Work Order: Flt Svc Date"}
    ),
    
    //__________FILTERS___________
    // Cant use date filter on text
    #"Changed Type Date Posted" = Table.TransformColumnTypes(#"Expanded Data",{{"Date Posted", type date}}),
    // Filter on Date Posted to be >= the Parameter date_year_posted_Start and include open documents
    #"Filter Dates" = Table.SelectRows(#"Changed Type Date Posted", each 
        Date.Year([Date Posted])>=date_year_posted_start
    or  [Date Posted] = "null"
    or  [Date Posted] = null
    ),
    // Filter Document Division by parameter doc_division
    #"Filter Doc Division" = 
        if   doc_division = "All" 
        then #"Filter Dates"
        else Table.SelectRows(#"Filter Dates", each ([Division] = doc_division)),
    // Filter Document Code by parameter doc_code
    #"Filter Doc Code" =  
        if   doc_code = "All"
        then #"Filter Doc Division"
        else Table.SelectRows(#"Filter Doc Division", each ([Document Code] = doc_division)),
    // Filter Document Type by parameter doc_type
    #"Filter Doc Type" = 
        if   doc_type = "All"
        then #"Filter Doc Code"
        else Table.SelectRows(#"Filter Doc Code", each ([#"Document Type (W/S/Q)"] = "W")),
    // Filter Document Status by parameter doc_status
    #"Filter Doc Staus" = 
        if   doc_status = "Open" 
        then Table.SelectRows(#"Filter Doc Type", each (
                [#"Document Status (O/R/C/k=Cancelled)"] = "O" 
            or  [#"Document Status (O/R/C/k=Cancelled)"] = "R")
        )
        else if   doc_status = "Closed"
		then Table.SelectRows(#"Filter Doc Type", each (
				[#"Document Status (O/R/C/k=Cancelled)"] = "C" 
			or  [#"Document Status (O/R/C/k=Cancelled)"] = "k")
        )
        else #"Filter Dates",
    // Remove columns added by folder table
    #"Removed Columns" = Table.RemoveColumns(#"Filter Doc Staus",{"Content", "Name", "Extension", "Date accessed", "Date modified", "Date created", "Attributes", "Folder Path"})
in
    #"Removed Columns"