CREATE OR ALTER PROC dbo.usp_TL_DIM_Terceros
AS











SELECT Stg.[CodTercero]
      ,Stg.[Nombre_Tercero]
      ,Stg.[Nombre_Direccion]
      ,Stg.[Nombre_Ciudad]
      ,Stg.[Nombre_Region]
      ,Stg.[Nombre_Pais]
      ,Stg.[Nombre_Telefono]
      ,Stg.[Jefe_Tecero]
      ,Stg.[Es_Cliente]
      ,Stg.[Es_Empleado]
      ,Stg.[Es_Despachador]
      ,Stg.[BI_Control_Extraccion ]
      ,Stg.[BI_Control_Transformacion]

	  INTO [Datamart_Norte].dbo.DIM_Terceros
  FROM [Staging_Norte].[dbo].[VW_Tr_Terceros] Stg 

GO

