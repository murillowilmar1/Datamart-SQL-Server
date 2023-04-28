
USE Staging_Norte
GO 



CREATE OR ALTER VIEW dbo.VW_Tr_Geografia 
AS 




SELECT  DISTINCT --  Obtener valores unicos 
       CHECKSUM (   --- Para calcular codigos unicos apartir de columnas 
       ISNULL(LTRIM(UPPER([EntregaCiudad])),'_Sin Ciudad')
      ,ISNULL(LTRIM(UPPER([EntregaRegion])),'_Sin Region')
      ,ISNULL(LTRIM(UPPER([EntregaPais])),'_Sin Pais')
	   ) AS CodGeografia
	  ,CHECKSUM(ISNULL(LTRIM(UPPER([EntregaCiudad])),'_Sin Ciudad'))AS CodCiudad
      ,ISNULL(LTRIM(UPPER([EntregaCiudad])),'_Sin Ciudad')AS Ciudad_Nombre
	  ,CHECKSUM(ISNULL(LTRIM(UPPER([EntregaRegion])),'_Sin Region'))AS CodRegion
      ,ISNULL(LTRIM(UPPER([EntregaRegion])),'_Sin Region') AS Region_Nombre
	  ,CHECKSUM(ISNULL(LTRIM(UPPER([EntregaPais])),'_Sin Pais'))AS CodPais
      ,ISNULL(LTRIM(UPPER([EntregaPais])),'_Sin Pais') AS Pais_Nombre 
      ,[BI_Control_Extraccion ]
	  ,GETDATE() AS BI_Control_Transformacion

  FROM [dbo].[Ex_DIM_Pedidos]

GO


