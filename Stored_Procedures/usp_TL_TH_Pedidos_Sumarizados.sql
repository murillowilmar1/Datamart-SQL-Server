USE Staging
GO

CREATE OR ALTER PROC dbo.usp_TL_TH_Pedidos_Sumarizados


AS

/*

Pasos:
1. Control de Llaves Huérfanas (Existen en la Tabla de Hechos pero no en las Dimensiones)
2. Manejo de la Dimensión de Tiempo
3. Inserción de Datos Nuevos (Left Join) entre Staging y Datamart
4. Control Deltas
5. (Vista) Contiene las transformaciones
*/

--3. Inserción de Datos Nuevos (Left Join) entre Staging y Datamart
INSERT INTO [Datamart_EIA].[dbo].[TH_Pedidos_Sum]
           ([CodPedido]
           ,[IdCliente]
           ,[IdEmpleado]
           ,[IdDespachador]
           ,[IdTiempo]
           ,[IdGeografia]
           ,[_Sum_Vlr_Bruto]
           ,[_Sum_Vlr_Dscto]
           ,[_Sum_Vlr_Neto]
           ,[_Avg_Vlr_Neto]
           ,[_Avg_Cantidad]
           ,[BI_Control_Extraccion]
           ,[BI_Control_Transformacion])

(
SELECT 
      Stg.[CodPedido]
      ,C.IdTercero AS IdCliente		--[CodCliente]
      ,E.IdTercero AS IdEmpleado	--[CodEmpleado]
      ,D.IdTercero AS IdDespachador	--Stg.[CodDespachador]
      ,T.IdTiempo					--Stg.[CodTiempo]
      ,G.IdGeografia				--Stg.[CodGeografia]      ,[Flete]
      ,Stg.[_Sum_Vlr_Bruto]
      ,Stg.[_Sum_Vlr_Dscto]
      ,Stg.[_Sum_Vlr_Neto]
      ,Stg.[_Avg_Vlr_Neto]
      ,Stg.[_Avg_Cantidad]
      ,Stg.[BI_Control_Extraccion]
      ,Stg.[BI_Control_Transformacion]
	  --INTO [Datamart_EIA].dbo.TH_Pedidos_Sum
  FROM [Staging].[dbo].[uvw_Tr_TH_Pedidos_Sum] Stg
	--Obtenemos las llaves sustitutas, o subrogadas... (Nuevas)
	--Geografia
		LEFT JOIN Datamart_EIA.dbo.Dim_Geografia G
			ON Stg.CodGeografia = G.CodGeografia
	--Tiempo
		LEFT JOIN Datamart_EIA.dbo.Dim_Tiempo T
			ON Stg.CodTiempo = T.Fecha
	--Clientes
		LEFT JOIN Datamart_EIA.dbo.Dim_Terceros C
			ON Stg.CodCliente = C.CodTercero
			AND C.Es_Cliente = 1
	--Empleados
		LEFT JOIN Datamart_EIA.dbo.Dim_Terceros E
			ON Stg.CodEmpleado = E.CodTercero
			AND E.Es_Empleado = 1
	--Despachadores
		LEFT JOIN Datamart_EIA.dbo.Dim_Terceros D
			ON Stg.CodDespachador = D.CodTercero
			AND D.Es_Despachador = 1
)

GO

