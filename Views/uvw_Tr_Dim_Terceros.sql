USE Staging
GO
CREATE OR ALTER VIEW dbo.uvw_Tr_Dim_Terceros
AS
--Clientes
SELECT 
	   ISNULL(C.[IdCliente],'-99') as CodTercero
      ,ISNULL(LTRIM(UPPER(C.[Compania])),'_Sin Nombre Tercero') AS Nombre_Tercero
      ,ISNULL(LTRIM(UPPER(C.[Telefono])),'_Sin Telefono Tercero') AS Telefono_Tercero
      ,ISNULL(LTRIM(UPPER(C.[Direccion])),'_Sin Direccion Tercero') AS Direccion_Tercero
      ,ISNULL(LTRIM(UPPER(C.[Ciudad])),'_Sin Ciudad Tercero') AS Ciudad_Tercero
      ,ISNULL(LTRIM(UPPER(C.[Region])),'_Sin Region Tercero') AS Region_Tercero
      ,ISNULL(LTRIM(UPPER(C.[Pais])),'_Sin Pais Tercero') AS Pais_Tercero
	  ,'_Sin Jefe Tercero' as Jefe_Tercero
	  ,1 as Es_Cliente
	  ,0 as Es_Empleado
	  ,0 as Es_Despachador
      ,C.[BI_Control_Extraccion]
	  ,GETDATE() as BI_Control_Transformacion
  FROM [Staging].[dbo].[Ex_Clientes] C
UNION ALL
--Empleados
SELECT 
	   ISNULL(CAST(E.[IdEmpleado] AS NVARCHAR(10)),'-99')
      ,ISNULL(UPPER(LTRIM(CONCAT(E.[Apellidos],'',E.[Nombres]))),'_Sin Nombre Tercero')
	  ,ISNULL(LTRIM(UPPER(E.[TelCasa])),'_Sin Telefono Tercero') 
      ,ISNULL(LTRIM(UPPER(E.[Direccion])),'_Sin Direccion Tercero')
      ,ISNULL(LTRIM(UPPER(E.[Ciudad])),'_Sin Ciudad Tercero') 
      ,ISNULL(LTRIM(UPPER(E.[Region])),'_Sin Region Tercero') 
	  ,ISNULL(LTRIM(UPPER(E.[Pais])),'_Sin Pais Tercero') 
      ,ISNULL(UPPER(LTRIM((J.[Apellidos]+''+J.[Nombres]))),'_Sin Jefe Tercero')
	  ,0 as Es_Cliente
	  ,1 as Es_Empleado
	  ,0 as Es_Despachador
      ,E.[BI_Control_Extraccion]
	  ,GETDATE() as BI_Control_Transformacion
  FROM [Staging].[dbo].[Ex_Empleados] E
		LEFT JOIN [Staging].[dbo].[Ex_Empleados] J
			ON E.[Reporta_A] = J.IdEmpleado
--Despachadores
UNION ALL
SELECT
	  ISNULL(CAST(D.[IdDespachador]AS NVARCHAR(10)),'-99')
      ,ISNULL(LTRIM(UPPER(D.[Compania])),'_Sin Nombre Tercero') AS Nombre_Tercero
      ,ISNULL(LTRIM(UPPER(D.[Telefono])),'_Sin Telefono Tercero') AS Telefono_Tercero
      ,'_Sin Direccion Tercero'
      ,'_Sin Ciudad Tercero' 
      ,'_Sin Region Tercero' 
	  ,'_Sin Pais Tercero' 
      ,'_Sin Jefe Tercero'
	  ,0 as Es_Cliente
	  ,0 as Es_Empleado
	  ,1 as Es_Despachador
      ,D.[BI_Control_Extraccion]
	  ,GETDATE() as BI_Control_Transformacion
  FROM [Staging].[dbo].[Ex_Despachadores] D
GO
