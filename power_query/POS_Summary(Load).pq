let
    Source = POS_Summary_Transform,
    // Use _Data_Documentation workbook to create column select list
    #"Select Columns" = Source
   
in
    #"Select Columns"