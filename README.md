# DIS_BI
Model Files for DIS Project



# Parameters

## Query Filters

Many reports will need the same high level filters applied to all Pivots globally, these can be set in the 

## Data Source

| data_source          | text | List {Local, SharePoint} | Can Easily add more data sources if needed |
| -------------------- | ---- | ------------------------ | ------------------------------------------ |
| data_path_sharepoint | text |                          |                                            |
| data_path_local      | text |                          |                                            |
|                      |      |                          |                                            |



# Imporant

Files must contain "" in path name for code to be reusable







# Version History

0.3 Finished POS_Summary and and POS_Detail refactor for performance.  Going to increment the version number so I can go back and compare after adding other tables.  Performance was good, the Production Data Select was set to load to Model, seem like it slowed down when I turned that off.  The WB size increased to about 250MG with this query loading to model.

