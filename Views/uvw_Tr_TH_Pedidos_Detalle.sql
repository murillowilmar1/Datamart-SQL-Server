USE Staging
GO

CREATE OR ALTER VIEW dbo.uvw_Tr_TH_Pedidos_Detalle

AS

SELECT        
	ISNULL(Ex_Pedidos.IdPedido,-99) AS CodPedido, 
	ISNULL(CAST(Ex_Pedidos.IdCliente AS nvarchar(10)),'-99') AS CodCliente, 
	ISNULL(CAST(Ex_Pedidos.IdEmpleado AS nvarchar(10)),'-99') AS CodEmpleado, 
	ISNULL(CAST(Ex_Pedidos.IdDespachador AS nvarchar(10)),'-99') AS CodDespachador, 
	ISNULL(Ex_Pedidos_Detalles.IdProducto,-99) AS CodProducto, 
	Ex_Pedidos.FPedido AS CodTiempo, 
	CHECKSUM(
		ISNULL(LTRIM(UPPER(Ex_Pedidos.EntregaCiudad)),'_Sin Ciudad'),
		ISNULL(LTRIM(UPPER(Ex_Pedidos.EntregaRegion)),'_Sin Region'),
		ISNULL(LTRIM(UPPER(Ex_Pedidos.EntregaPais)),'_Sin Pais')
	) AS CodGeografia,
	--M�tricas
	--Naturales
	ISNULL(Ex_Pedidos_Detalles.PrecioUnd,0) AS PrecioUnd, 
	ISNULL(Ex_Pedidos_Detalles.Cantidad,0) AS Cantidad, 
	ISNULL(Ex_Pedidos_Detalles.Descuento,0) AS PrcDcto, 
	--Artificiales
	--Bruto
	ISNULL(Ex_Pedidos_Detalles.PrecioUnd,0) *
	ISNULL(Ex_Pedidos_Detalles.Cantidad,0) AS _Vlr_Bruto, 
	--Valor Descuento
	ISNULL(Ex_Pedidos_Detalles.PrecioUnd,0) *
	ISNULL(Ex_Pedidos_Detalles.Cantidad,0) *
	ISNULL(Ex_Pedidos_Detalles.Descuento,0) AS _Vlr_Dscto, 
	--Valor Neto
	(ISNULL(Ex_Pedidos_Detalles.PrecioUnd,0) *
	ISNULL(Ex_Pedidos_Detalles.Cantidad,0)) *
	(1-ISNULL(Ex_Pedidos_Detalles.Descuento,0)) AS _Vlr_Neto, 
	Ex_Pedidos_Detalles.BI_Control_Extraccion,
	GETDATE() AS BI_Control_Transformacion
FROM Ex_Pedidos 
		LEFT OUTER JOIN Ex_Pedidos_Detalles 
			ON Ex_Pedidos.IdPedido = Ex_Pedidos_Detalles.IdPedido


GO