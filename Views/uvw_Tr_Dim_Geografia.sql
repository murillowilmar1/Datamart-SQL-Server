USE Staging
GO

CREATE OR ALTER VIEW dbo.uvw_Tr_Dim_Geografia

AS

SELECT  DISTINCT 
	CHECKSUM(
		ISNULL(LTRIM(UPPER(EntregaCiudad)),'_Sin Ciudad'),
		ISNULL(LTRIM(UPPER(EntregaRegion)),'_Sin Region'),
		ISNULL(LTRIM(UPPER(EntregaPais)),'_Sin Pais')
	) AS CodGeografia,
	CHECKSUM(ISNULL(LTRIM(UPPER(EntregaCiudad)),'_Sin Ciudad')) AS	CodCiudad,
	ISNULL(LTRIM(UPPER(EntregaCiudad)),'_Sin Ciudad') AS Ciudad_Nombre,  
	CHECKSUM(ISNULL(LTRIM(UPPER(EntregaRegion)),'_Sin Region')) as CodRegion,
	ISNULL(LTRIM(UPPER(EntregaRegion)),'_Sin Region') AS Region_Nombre, 
	CHECKSUM(ISNULL(LTRIM(UPPER(EntregaPais)),'_Sin Pais')) as CodPais,
	ISNULL(LTRIM(UPPER(EntregaPais)),'_Sin Pais') AS Pais_Nombre, 
	BI_Control_Extraccion,
	GETDATE() as BI_Control_Transformacion
FROM Ex_Pedidos
GO
