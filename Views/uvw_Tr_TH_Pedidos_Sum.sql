USE Staging
GO

CREATE OR ALTER VIEW dbo.uvw_Tr_TH_Pedidos_Sum

AS

SELECT VwDet.[CodPedido]
      ,VwDet.[CodCliente]
      ,VwDet.[CodEmpleado]
      ,VwDet.[CodDespachador]
      ,VwDet.[CodTiempo]
      ,VwDet.[CodGeografia]
	  ,max(P.Flete) as Flete
      ,sum(VwDet.[_Vlr_Bruto]) as _Sum_Vlr_Bruto
      ,sum(VwDet.[_Vlr_Dscto]) as _Sum_Vlr_Dscto
      ,sum(VwDet.[_Vlr_Neto]) as _Sum_Vlr_Neto
	  ,avg(VwDet.[_Vlr_Neto]) as _Avg_Vlr_Neto
	  ,avg(VwDet.[Cantidad]) as _Avg_Cantidad
      ,VwDet.[BI_Control_Extraccion]
      ,VwDet.[BI_Control_Transformacion]
  FROM [Staging].[dbo].[uvw_Tr_TH_Pedidos_Detalle] VwDet
	left join [Staging].[dbo].[Ex_Pedidos]	P
		ON P.IdPedido = VwDet.CodPedido
  GROUP BY 
   VwDet.[CodPedido]
      ,VwDet.[CodCliente]
      ,VwDet.[CodEmpleado]
      ,VwDet.[CodDespachador]
      ,VwDet.[CodTiempo]
      ,VwDet.[CodGeografia]
	  ,VwDet.[BI_Control_Extraccion]
      ,VwDet.[BI_Control_Transformacion]

GO

