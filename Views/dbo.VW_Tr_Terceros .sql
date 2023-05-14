CREATE OR ALTER VIEW dbo.VW_Tr_Terceros 

AS 


-----  Clientes 

SELECT ISNULL(C.[IdCliente], '-99') AS CodTercero
      ,ISNULL(LTRIM(UPPER(C.[Compania])),'_Sin Nombre Tercero') AS Nombre_Tercero
      ,ISNULL(LTRIM(UPPER(C.[Direccion])), '_Sin Nombre Direccion') AS Nombre_Direccion
	  ,ISNULL(LTRIM(UPPER(C.[Ciudad])), '_Sin Nombre Ciudad') AS Nombre_Ciudad
	  ,ISNULL(LTRIM(UPPER(C.[Region])), '_Sin Nombre Region') AS Nombre_Region
	  ,ISNULL(LTRIM(UPPER(C.[Pais])), '_Sin Nombre Pais') AS Nombre_Pais
      ,ISNULL(LTRIM(UPPER(C.[Telefono])), '_Sin Nombre Telefono') AS Nombre_Telefono
	  ,'_Sin Jefe Tercero' AS Jefe_Tecero
	  ,1 AS Es_Cliente 
	  ,0 AS Es_Empleado
	  ,0 AS Es_Despachador
      ,[BI_Control_Extraccion ]
	  ,GETDATE()AS BI_Control_Transformacion
  FROM [dbo].[Ex_DIM_Clientes] C 


---- Despachadores 
  UNION ALL 

SELECT 
       ISNULL(D.[IdDespachador], '-99') 
	  ,ISNULL(LTRIM(UPPER(D.[Compania])),'_Sin Nombre Tercero') AS Nombre_Tercero
	  ,'_Sin Direccion Tercero' 
	  ,'_Sin Ciudad Tercero'
	  ,'_Sin Region Tercero' 
	  ,'_Sin Pais Tercero' 
      ,ISNULL(LTRIM(UPPER(D.[Telefono])),'_Sin Nombre Telefono') AS Nombre_Telefono
	  ,'_Sin Jefe Tercero'
	  ,0 AS Es_Cliente 
	  ,0 AS Es_Empleado
	  ,1 AS Es_Despachador
      ,D.[BI_Control_Extraccion ]
	  ,GETDATE()AS BI_Control_Transformacion
  FROM [dbo].[Ex_DIM_Despachadores] D 


  ----- Empleados 

UNION ALL 


SELECT 
       ISNULL(E.[IdEmpleado], '-99')
	  ,ISNULL(UPPER(LTRIM(CONCAT(E.Apellidos, '', E.Nombres))),'_Sin Nombre Tercero')
      ,ISNULL(LTRIM(UPPER(E.[Direccion])), '_Sin Nombre Direccion') AS Nombre_Direccion
	  ,ISNULL(LTRIM(UPPER(E.[Ciudad])), '_Sin Nombre Ciudad') AS Nombre_Ciudad
	  ,ISNULL(LTRIM(UPPER(E.[Region])), '_Sin Nombre Region') AS Nombre_Region
	  ,ISNULL(LTRIM(UPPER(E.[Pais])), '_Sin Nombre Pais') AS Nombre_Pais
      ,ISNULL(LTRIM(UPPER(E.[TelCasa])), '_Sin Nombre Telefono') AS Nombre_Telefono
	  ,ISNULL(UPPER(LTRIM((J.[Apellidos]+''+J.[Nombres]))),'_Sin Jefe Tercero')
	  ,0 as Es_Cliente
	  ,1 as Es_Empleado
	  ,0 as Es_Despachador
      ,E.[BI_Control_Extraccion ]
	  ,GETDATE()AS BI_Control_Transformacion
  FROM [dbo].[EX_DIM_Empleados] E
       LEFT JOIN 
	   dbo.EX_DIM_Empleados J 
	   ON E.Reporta_A = J.IdEmpleado 

GO



