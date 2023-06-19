USE Staging
GO

CREATE OR ALTER VIEW dbo.uvw_Tr_Dim_Productos

AS

SELECT        
	ISNULL(Ex_Productos.IdProducto,-99) AS CodProducto, 
	ISNULL(LTRIM(UPPER(Ex_Productos.Nombre)),'_Sin Nombre Producto') AS Nombre_Producto, 
	ISNULL(Ex_Productos.IdCategoria,-99) AS CodCategoria, 
	ISNULL(LTRIM(UPPER(Ex_Categorias.Nombre)),'_Sin Nombre Categoria') AS Nombre_Categoria, 
	CASE 
		WHEN Ex_Productos.Descontinuado = 0 THEN 'Activo'
		WHEN Ex_Productos.Descontinuado = 1 THEN 'Inactivo'
		ELSE 'Inconsistente'
	END AS Descontinuado, 
	Ex_Productos.BI_Control_Extraccion,
	GETDATE() AS BI_Control_Transformacion
FROM Ex_Productos 
		LEFT OUTER JOIN Ex_Categorias 
			ON Ex_Productos.IdCategoria = Ex_Categorias.IdCategoria

GO