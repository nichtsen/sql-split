# sql-split
Having trouble with pages split when your application retrive rows from SQL Server?
Here provide you a solution for range split of single source table. 

## Example
```sql
DECLARE @ROW INT,
        @PAGE INT
EXECUTE sp_PageSplit 'MyTable','*','SortingFields','id > 0',10,1,@ROW OUTPUT,@PAGE OUTPUT
SELECT @ROW AS Total_Row,
       @PAGE as Total_Page
``` 
When you calling the stored procedure like that, the de facto sql be running should like this:
```sql
SELECT * FROM 
	(SELECT ROW_NUMBER() OVER(ORDER BY SortingFields) AS ROWID,* 
	 FROM MyTable WHERE id > 0) AS T 
	 WHERE ROWID BETWEEN 1 AND 10 OPTION(RECOMPILE)
``` 