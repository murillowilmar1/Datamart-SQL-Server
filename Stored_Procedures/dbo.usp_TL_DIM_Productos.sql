CREATE OR ALTER PROC dbo.usp_TL_DIM_Productos
AS 
--- Dummy 
IF NOT EXISTS (SELECT IdProducto FROM [Datamart_Norte].[dbo].[DIM_Productos]
   				WHERE IdProducto = -99)
BEGIN
	--Apague el Identity
	SET IDENTITY_INSERT [Datamart_Norte].[dbo].[DIM_Productos] ON 

			INSERT INTO [dbo].[DIM_Productos]
					   (
					    [IdProducto]
					   ,[CodProducto]
					   ,[Nombre_Producto]
					   ,[CodCategoria]
					   ,[Nombre_Categoria]
					   ,[Descontinuado]
					   ,[BI_Control_Extraccion ]
					   ,[BI_Control_Transformacion])
				 VALUES
					   (-99
					   ,-99 
					   ,'_Sin NombreProducto'
					   ,-99
					   ,'_Sin NombreCategoria'
					   ,'Inconsistente'
					   ,GETDATE()
					   ,GETDATE())
---Encienda el Identity
	SET IDENTITY_INSERT[Datamart_Norte].[dbo].[DIM_Productos] OFF 

END

---UPDATE 


UPDATE Dtm
SET
       Dtm.[Nombre_Producto]               =              Stg.[Nombre_Producto]
      ,Dtm.[CodCategoria]                  =              Stg.[CodCategoria]
      ,Dtm.[Nombre_Categoria]              =              Stg.[Nombre_Categoria]
      ,Dtm.[Descontinuado]                 =              Stg.[Descontinuado]
      ,Dtm.[BI_Control_Extraccion ]        =              Stg.[BI_Control_Extraccion]
      ,Dtm.[BI_Control_Transformacion]    =              Stg.[BI_Control_Transformacion]
          FROM [Staging].[dbo].[uvw_Tr_Dim_Productos] AS Stg
	     INNER JOIN [Datamart_Norte].[dbo].[DIM_Productos]  AS Dtm
		-- Comparo por llaves de negocio
		  ON Stg.CodProducto = Dtm.CodProducto 

----INSERT TO 


INSERT INTO[Datamart_Norte].[dbo].[DIM_Productos]
           ([CodProducto]
           ,[Nombre_Producto]
           ,[CodCategoria]
           ,[Nombre_Categoria]
           ,[Descontinuado]
           ,[BI_Control_Extraccion]
           ,[BI_Control_Transformacion])

(SELECT Stg.[CodProducto]
      ,Stg.[Nombre_Producto]
      ,Stg.[CodCategoria]
      ,Stg.[Nombre_Categoria]
      ,Stg.[Descontinuado]
      ,Stg.[BI_Control_Extraccion ]
      ,Stg.[BI_Control_Transformacion]
	 -- INTO Datamart_Norte.dbo.DIM_Productos
  FROM [Staging_Norte].[dbo].[VW_Tr_Productos] AS Stg 
       LEFT JOIN [Datamart_Norte].[dbo].[DIM_Productos] AS Dtm 
       ON Stg.CodProducto = Dtm.CodProducto
	   WHERE Dtm.CodProducto IS NULL ) 
 GO 
  




