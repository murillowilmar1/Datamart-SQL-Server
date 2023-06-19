USE Staging
GO

CREATE OR ALTER PROC dbo.usp_TL_Dim_Productos


AS

/*

Pasos:
1. Creación o validación del registro Dummy (Completitud)
2. Actualización de Datos Existentes (Join) entre Staging y Datamart
3. Inserción de Datos Nuevos (Left Join) entre Staging y Datamart
4. (Vista) Contiene las transformaciones
*/
--Paso 1 --> Creación o validación del registro Dummy (Completitud)
IF NOT EXISTS (SELECT IdProducto FROM [Datamart_EIA].[dbo].[Dim_Productos]
					WHERE IdProducto = -99)
BEGIN
	--Apague el Identity
	SET IDENTITY_INSERT [Datamart_EIA].[dbo].[Dim_Productos] ON 

		INSERT INTO [Datamart_EIA].[dbo].[Dim_Productos]
				   (IdProducto
				   ,[CodProducto]
				   ,[Nombre_Producto]
				   ,[CodCategoria]
				   ,[Nombre_Categoria]
				   ,[Descontinuado]
				   ,[BI_Control_Extraccion]
				   ,[BI_Control_Transformacion])
			 VALUES
				   (-99
				   ,-99
				   ,'_Sin Nombre Producto'
				   ,-99
				   ,'_Sin Nombre Categoria'
				   ,'Inconsistente'
				   ,GETDATE()
				   ,GETDATE())
	--Encienda el Identity
	SET IDENTITY_INSERT [Datamart_EIA].[dbo].[Dim_Productos] OFF 

END

--Paso 2 --> Actualización de Datos Existentes (Join) entre Staging y Datamart
UPDATE Dtm
SET
       Dtm.[Nombre_Producto]			= Stg.[Nombre_Producto]
      ,Dtm.[CodCategoria]				= Stg.[CodCategoria]
      ,Dtm.[Nombre_Categoria]			= Stg.[Nombre_Categoria]
      ,Dtm.[Descontinuado]				= Stg.[Descontinuado]
      ,Dtm.[BI_Control_Extraccion]		= Stg.[BI_Control_Extraccion]
      ,Dtm.[BI_Control_Transformacion]	= Stg.[BI_Control_Transformacion]
  FROM [Staging].[dbo].[uvw_Tr_Dim_Productos] AS Stg
	INNER JOIN [Datamart_EIA].dbo.Dim_Productos AS Dtm
		-- Comparo por llaves de negocio
		ON Stg.CodProducto = Dtm.CodProducto

--Paso 3 --> Inserción de Datos Nuevos (Left Join) entre Staging y Datamart
-- En este paso y en "tiempo de desarrollo" se crea la dimensión en el 
-- Datamart
INSERT INTO [Datamart_EIA].[dbo].[Dim_Productos]
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
      ,Stg.[BI_Control_Extraccion]
      ,Stg.[BI_Control_Transformacion]
	  --INTO [Datamart_EIA].dbo.Dim_Productos
	  -- La sentencia INTO em tiempo de Desarrollo me permite crear
	  -- la dimensión en el Datamart...
	  -- La sentencia debe ser documentada para la entrega final
  FROM [Staging].[dbo].[uvw_Tr_Dim_Productos] AS Stg
	LEFT JOIN [Datamart_EIA].dbo.Dim_Productos AS Dtm
		-- Comparo por llaves de negocio
		ON Stg.CodProducto = Dtm.CodProducto
	--Pregunto si el dato es nulo en la dimensión, significa que esta en Staging y 
	--No en Datamart
	WHERE Dtm.CodProducto IS NULL)

GO
