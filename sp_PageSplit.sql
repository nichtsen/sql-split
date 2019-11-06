CREATE PROCEDURE [dbo].[sp_PageSplit]
	@TableName VARCHAR(200),		/* table's name, only single one table */ 
	@Fields VARCHAR(5000) = '*',	/* table's fields to display, star '*', as default, means all fields */ 
	@OrderField VARCHAR(5000),		/* table's fields for ordering */ 
	@sqlWhere VARCHAR(5000) = NULL,	/* where filter */ 
	@pageSize INT=10,				/* how many rows to display per page */ 
	@pageIndex INT = 1 ,			/* the current page */ 
	@TotalRecord INT OUTPUT,		/* total rows of the table */ 
	@TotalPage INT OUTPUT			/* total pages of the form */ 
AS
BEGIN
	DECLARE @Start INT   
            ,@End INT
            ,@sql NVARCHAR(4000)
    
	/* Checking the variables */  
	SET @sqlWhere = RTRIM(LTRIM(@SqlWhere))
	SET @Fields = RTRIM(LTRIM(@Fields))
	SET @OrderField = RTRIM(LTRIM(@OrderField))
	IF @OrderField = ''
		BEGIN
			PRINT 'Invalid parameter: @OrderField'
			RETURN 
		END
	IF @Fields = '' 
		SET @Fields = '*'

	BEGIN TRY
		/* get the total rows in table with read uncommited */
		SET @sql = 'SELECT @totalRecord = count(1) FROM ' + @TableName + ' WITH (NOLOCK) '
		IF ISNULL(@sqlWhere,'') != ''
			SET @sql = @sql + ' WHERE ' + @sqlWhere
	    
		EXEC sp_executesql @sql,
			 N'@totalRecord int OUTPUT',
			 @totalRecord OUTPUT

		/* caculate the total pages */ 
		SELECT @TotalPage = CEILING((@totalRecord + 0.0) / @PageSize)
	
		/* caculate the range of the current page */
		IF @PageIndex <= 0
			SET @pageIndex = 1   
		SET @Start = (@pageIndex -1) * @PageSize + 1    
		SET @End = @Start + @pageSize - 1 

		/* get the current page from table */    
		SET @sql = 'SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY ' + @OrderField + ') AS ROWID,' + @Fields + ' FROM ' + @TableName
		IF ISNULL(@SqlWhere,'') != ''
			SET @sql = @sql + ' WHERE ' + @SqlWhere 
		SET @Sql = @Sql + ') AS T WHERE ROWID BETWEEN ' + CONVERT(VARCHAR(50), @Start) + ' AND ' + CONVERT(VARCHAR(50), @End) 
		SET @sql=@sql +' OPTION(RECOMPILE)'
		PRINT @sql
		EXEC (@Sql) 
		RETURN @TotalRecord
	END TRY
	BEGIN CATCH
	    PRINT Error_Message()
    END CATCH
END



