let
    Source = if data_source = "SharePoint"
        then SharePoint.Files(data_path_sharepoint, [ApiVersion = 15])
        else Table.FromRecords({
            [File = "data_source is not SharePoint", Folder Path = data_path_sharepoint&"Shared Documents/General/_Production_Data/"]
        }),
    #"Filtered Rows" = Table.SelectRows(Source, each ([Folder Path] = "https://advantageag.sharepoint.com/sites/Reporting/Shared Documents/General/_Production_Data/")) /*THIS WORKS, Filter by XLS and CSV?*/

in
    #"Filtered Rows"