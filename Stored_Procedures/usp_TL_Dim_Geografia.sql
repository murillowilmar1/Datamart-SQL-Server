USE Staging
GO

CREATE OR ALTER PROC dbo.usp_TL_Dim_Geografia

AS

/*

Pasos:
1. Creación o validación del registro Dummy (Completitud)
2. Actualización de Datos Existentes (Join) entre Staging y Datamart
3. Inserción de Datos Nuevos (Left Join) entre Staging y Datamart
4. (Vista) Contiene las transformaciones
*/
--Paso 1 --> Creación o validación del registro Dummy (Completitud)
IF NOT EXISTS (SELECT IdGeografia FROM [Datamart_EIA].[dbo].[Dim_Geografia]
					WHERE IdGeografia = -99)
BEGIN
	--Apague el Identity
	SET IDENTITY_INSERT [Datamart_EIA].[dbo].[Dim_Geografia] ON 

		INSERT INTO [Datamart_EIA].[dbo].[Dim_Geografia]
				   (IdGeografia
				   ,[CodGeografia]
				   ,[CodCiudad]
				   ,[Ciudad_Nombre]
				   ,[CodRegion]
				   ,[Region_Nombre]
				   ,[CodPais]
				   ,[Pais_Nombre]
				   ,[BI_Control_Extraccion]
				   ,[BI_Control_Transformacion])
			 VALUES
				   (-99
				   ,-99
				   ,-99
				   ,'_Sin Ciudad'
				   ,-99
				   ,'_Sin Region'
				   ,-99
				   ,'_Sin Pais'
				   ,GETDATE()
				   ,GETDATE())
	--Encienda el Identity
	SET IDENTITY_INSERT [Datamart_EIA].[dbo].[Dim_Geografia] OFF 

END

--Paso 2 --> Actualización de Datos Existentes (Join) entre Staging y Datamart
-- NO APLICA

--Paso 3 --> Inserción de Datos Nuevos (Left Join) entre Staging y Datamart
-- En este paso y en "tiempo de desarrollo" se crea la dimensión en el 
-- Datamart
INSERT INTO [Datamart_EIA].[dbo].[Dim_Geografia]
           ([CodGeografia]
           ,[CodCiudad]
           ,[Ciudad_Nombre]
           ,[CodRegion]
           ,[Region_Nombre]
           ,[CodPais]
           ,[Pais_Nombre]
           ,[BI_Control_Extraccion]
           ,[BI_Control_Transformacion])

(SELECT Stg.[CodGeografia]
      ,Stg.[CodCiudad]
      ,Stg.[Ciudad_Nombre]
      ,Stg.[CodRegion]
      ,Stg.[Region_Nombre]
      ,Stg.[CodPais]
      ,Stg.[Pais_Nombre]
      ,Stg.[BI_Control_Extraccion]
      ,Stg.[BI_Control_Transformacion]
	  --INTO [Datamart_EIA].dbo.Dim_Geografia
	  -- La sentencia INTO em tiempo de Desarrollo me permite crear
	  -- la dimensión en el Datamart...
	  -- La sentencia debe ser documentada para la entrega final
  FROM [Staging].[dbo].[uvw_Tr_Dim_Geografia] AS Stg
	LEFT JOIN [Datamart_EIA].dbo.Dim_Geografia AS Dtm
		-- Comparo por llaves de negocio
		ON Stg.CodGeografia = Dtm.CodGeografia
	--Pregunto si el dato es nulo en la dimensión, significa que esta en Staging y 
	--No en Datamart
	WHERE Dtm.CodGeografia IS NULL)
GO
