USE Staging
GO

CREATE OR ALTER PROC dbo.usp_TL_Dim_Terceros


AS

/*

Pasos:
1. Creación o validación del registro Dummy (Completitud)
2. Actualización de Datos Existentes (Join) entre Staging y Datamart
3. Inserción de Datos Nuevos (Left Join) entre Staging y Datamart
4. (Vista) Contiene las transformaciones
*/
--Paso 1 --> Creación o validación del registro Dummy (Completitud)
IF NOT EXISTS (SELECT IdTercero FROM [Datamart_EIA].[dbo].[Dim_Terceros]
					WHERE IdTercero = -99)
BEGIN
	--Apague el Identity
	SET IDENTITY_INSERT [Datamart_EIA].[dbo].[Dim_Terceros] ON 

		INSERT INTO [Datamart_EIA].[dbo].[Dim_Terceros]
				   (IdTercero
				   ,[CodTercero]
				   ,[Nombre_Tercero]
				   ,[Telefono_Tercero]
				   ,[Direccion_Tercero]
				   ,[Ciudad_Tercero]
				   ,[Region_Tercero]
				   ,[Pais_Tercero]
				   ,[Jefe_Tercero]
				   ,[Es_Cliente]
				   ,[Es_Empleado]
				   ,[Es_Despachador]
				   ,[BI_Control_Extraccion]
				   ,[BI_Control_Transformacion])
			 VALUES
				   (-99
				   ,'-99'
				   ,'_Sin Nombre Tercero'
				   ,'_Sin Telefono Tercero'
				   ,'_Sin Direccion Tercero'
				   ,'_Sin Ciudad Tercero'
				   ,'_Sin Region Tercero'
				   ,'_Sin Pais Tercero'
				   ,'_Sin Jefe Tercero'
				   ,0
				   ,0
				   ,0
				   ,getdate()
				   ,getdate())

	--Encienda el Identity
	SET IDENTITY_INSERT [Datamart_EIA].[dbo].[Dim_Terceros] OFF 

END

--Paso 2 --> Actualización de Datos Existentes (Join) entre Staging y Datamart
UPDATE Dtm
SET
      Dtm.[Nombre_Tercero]				= Stg.[Nombre_Tercero]
      ,Dtm.[Telefono_Tercero]			= Stg.[Telefono_Tercero]
      ,Dtm.[Direccion_Tercero]			= Stg.[Direccion_Tercero]
      ,Dtm.[Ciudad_Tercero]				= Stg.[Ciudad_Tercero]
      ,Dtm.[Region_Tercero]				= Stg.[Region_Tercero]
      ,Dtm.[Pais_Tercero]				= Stg.[Pais_Tercero]
      ,Dtm.[Jefe_Tercero]				= Stg.[Jefe_Tercero]
      ,Dtm.[BI_Control_Extraccion]		= Stg.[BI_Control_Extraccion]
      ,Dtm.[BI_Control_Transformacion]	= Stg.[BI_Control_Transformacion]
  FROM [Staging].[dbo].[uvw_Tr_Dim_Terceros] Stg
	INNER JOIN [Datamart_EIA].dbo.Dim_Terceros AS Dtm
		-- Comparo por llaves de negocio
		ON Stg.CodTercero = Dtm.CodTercero
		AND Stg.Es_Cliente = Dtm.Es_Cliente
		AND Stg.Es_Despachador = Dtm.Es_Despachador
		AND Stg.Es_Empleado = Dtm.Es_Empleado

--Paso 3 --> Inserción de Datos Nuevos (Left Join) entre Staging y Datamart
-- En este paso y en "tiempo de desarrollo" se crea la dimensión en el 
-- Datamart

INSERT INTO [Datamart_EIA].[dbo].[Dim_Terceros]
           ([CodTercero]
           ,[Nombre_Tercero]
           ,[Telefono_Tercero]
           ,[Direccion_Tercero]
           ,[Ciudad_Tercero]
           ,[Region_Tercero]
           ,[Pais_Tercero]
           ,[Jefe_Tercero]
           ,[Es_Cliente]
           ,[Es_Empleado]
           ,[Es_Despachador]
           ,[BI_Control_Extraccion]
           ,[BI_Control_Transformacion])

(SELECT Stg.[CodTercero]
      ,Stg.[Nombre_Tercero]
      ,Stg.[Telefono_Tercero]
      ,Stg.[Direccion_Tercero]
      ,Stg.[Ciudad_Tercero]
      ,Stg.[Region_Tercero]
      ,Stg.[Pais_Tercero]
      ,Stg.[Jefe_Tercero]
      ,Stg.[Es_Cliente]
      ,Stg.[Es_Empleado]
      ,Stg.[Es_Despachador]
      ,Stg.[BI_Control_Extraccion]
      ,Stg.[BI_Control_Transformacion]
	  --INTO [Datamart_EIA].dbo.Dim_Terceros
	  -- La sentencia INTO em tiempo de Desarrollo me permite crear
	  -- la dimensión en el Datamart...
	  -- La sentencia debe ser documentada para la entrega final
  FROM [Staging].[dbo].[uvw_Tr_Dim_Terceros] Stg
	LEFT JOIN [Datamart_EIA].dbo.Dim_Terceros AS Dtm
		-- Comparo por llaves de negocio
		ON Stg.CodTercero = Dtm.CodTercero
		AND Stg.Es_Cliente = Dtm.Es_Cliente
		AND Stg.Es_Despachador = Dtm.Es_Despachador
		AND Stg.Es_Empleado = Dtm.Es_Empleado
	--Pregunto si el dato es nulo en la dimensión, significa que esta en Staging y 
	--No en Datamart
	WHERE Dtm.CodTercero IS NULL)
GO


