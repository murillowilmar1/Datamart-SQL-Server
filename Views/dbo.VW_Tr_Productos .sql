----- Creamos vista de productos y Categorias 


----Realizando transformaciones  


USE Staging_Norte
GO 



CREATE OR ALTER VIEW dbo.VW_Tr_Productos 
AS 


SELECT  --Columna Porductos

        ISNULL(P.IdProducto, -99) AS CodProducto, 
		 ISNULL(LTRIM(UPPER(P.Nombre)),'_Sin NombreProducto') AS Nombre_Producto,  

		ISNULL(C.IdCategoria,-99) AS CodCategoria, 
		ISNULL(LTRIM(UPPER(C.Nombre)),'_Sin NombreCategoria') AS Nombre_Categoria,

		CASE 
		WHEN P.Descontinuado = 0 THEN 'Inactivo' 
		WHEN P.Descontinuado = 1 THEN 'Activo' 
		ELSE 'Inconsistente'
	    END AS Descontinuado, 

		P.[BI_Control_Extraccion ], 
		GETDATE()AS BI_Control_Transoformacion ---- Creamos columna nueva para ver la fecha de transformación
	
	   


FROM     Ex_DIM_Productos P
         LEFT JOIN 
         Ex_DIM_Categorias C 
		 --Llave del negocio 
		 ON P.IdCategoria = C.IdCategoria


GO 


