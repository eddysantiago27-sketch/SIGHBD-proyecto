USE SIGHC;

--TABLA 01: Pacientes (Entidad Principal)
CREATE TABLE Pacientes (
IdPaciente INT IDENTITY(1,1) PRIMARY KEY,
NroHistoriaClinica VARCHAR(15) UNIQUE NOT NULL,
Nombres NVARCHAR(80) NOT NULL,
Apellidos NVARCHAR(80) NOT NULL,
DNI VARCHAR(8) UNIQUE NOT NULL,
FechaNacimiento DATE NOT NULL,
Sexo CHAR(1) NOT NULL CHECK (Sexo IN ('M','F')),
GrupoSanguineo VARCHAR(5),
Direccion NVARCHAR(200),
Telefono VARCHAR(15),
Email VARCHAR(100),
AntecedentesFamiliares NVARCHAR(MAX),
AntecedentesPersonales NVARCHAR(MAX),
Alergias NVARCHAR(MAX),
FechaRegistro DATETIME2 DEFAULT SYSDATETIME() NOT NULL,
Estado CHAR(1) DEFAULT 'A' CHECK (Estado IN ('A','I','F')),
UsuarioRegistro INT NOT NULL
);

GO
--Comentarios de documentación
EXEC sys.sp_addextendedproperty
@name=N'MS_Description',
@value=N'Tabla principal que almacena datos demográficos y clínicos de pacientes',
@level0type=N'SCHEMA', @level0name=N'dbo',
@level1type=N'TABLE',@level1name=N'Pacientes';
GO

--TABLA 02: Especialidades (Catálogo)
CREATE TABLE Especialidades (
IdEspecialidad INT IDENTITY(1,1) PRIMARY KEY,
NombreEspecialidad NVARCHAR(100) UNIQUE NOT NULL,
Descripcion NVARCHAR(500),
Estado CHAR(1) DEFAULT 'A' CHECK (Estado IN ('A','I'))
);

--TABLA 03: Medicos (Personal Médico)
CREATE TABLE Medicos (
IdMedico INT IDENTITY(1,1) PRIMARY KEY,
Nombres NVARCHAR(80) NOT NULL,
Apellidos NVARCHAR(80) NOT NULL,
DNI VARCHAR(8) UNIQUE NOT NULL,
CMP VARCHAR(10) UNIQUE NOT NULL,
RNE VARCHAR(10),
IdEspecialidad INT NOT NULL,
Telefono VARCHAR(15),
Email VARCHAR(100) NOT NULL,
FechaIngreso DATE NOT NULL,
Estado CHAR(1) DEFAULT 'A' CHECK (Estado IN ('A','I','S','R')
),
CONSTRAINT FK_Medicos_Especialidades
FOREIGN KEY (IdEspecialidad)
REFERENCES Especialidades(IdEspecialidad)
);
GO

--TABLA 04: Citas (Agenda MÉdica)
CREATE TABLE Citas (
 IdCita INT IDENTITY(1,1) PRIMARY KEY,
 CodigoCita VARCHAR(20) UNIQUE NOT NULL,
 IdPaciente INT NOT NULL,
 IdMedico INT NOT NULL,
 FechaCita DATE NOT NULL,
 HoraInicio TIME NOT NULL,
 HoraFin TIME NOT NULL,
 MotivoConsulta NVARCHAR(500) NOT NULL,
 TipoCita VARCHAR(20) NOT NULL
 CHECK (TipoCita IN ('PrimeraVez','Control','Emergencia')),
 Estado VARCHAR(20) DEFAULT 'Programada' NOT NULL
 CHECK (Estado IN ('Programada','Confirmada','Atendida','Cancelada','Reprogramada')),
 MotivoCancelacion NVARCHAR(200),
 FechaRegistro DATETIME2 DEFAULT SYSDATETIME() NOT NULL,
 UsuarioRegistro INT NOT NULL,
 CONSTRAINT FK_Citas_Pacientes
 FOREIGN KEY (IdPaciente) REFERENCES Pacientes(IdPaciente),
 CONSTRAINT FK_Citas_Medicos
 FOREIGN KEY (IdMedico) REFERENCES Medicos(IdMedico)
);
GO

--TABLA 05: Consultas (Atención Médica)
CREATE TABLE Consultas (
 IdConsulta INT IDENTITY(1,1) PRIMARY KEY,
 IdCita INT NOT NULL UNIQUE,
 IdPaciente INT NOT NULL,
 IdMedico INT NOT NULL,
 FechaConsulta DATETIME2 DEFAULT SYSDATETIME() NOT NULL,
 --Signos Vitales
 PresionArterial VARCHAR(10),
 Temperatura DECIMAL(4,1),
 FrecuenciaCardiaca INT,
 FrecuenciaRespiratoria INT,
 Peso DECIMAL(5,2),
 Talla DECIMAL(5,2),
 IMC AS (
 CASE 
 WHEN Talla > 0 
 THEN Peso / (Talla * Talla) 
 ELSE NULL 
 END) PERSISTED,
 SaturacionO2 INT,
 --Anamnesis
 MotivoConsulta NVARCHAR(MAX) NOT NULL,
 TiempoEnfermedad NVARCHAR(200),
 RelatoCronico NVARCHAR(MAX),
 ExamenFisico NVARCHAR(MAX),
 PlanTrabajo NVARCHAR(MAX),
 CONSTRAINT FK_Consultas_Citas
 FOREIGN KEY (IdCita) REFERENCES Citas(IdCita),
 CONSTRAINT FK_Consultas_Pacientes
 FOREIGN KEY (IdPaciente) REFERENCES Pacientes(IdPaciente),
 CONSTRAINT FK_Consultas_Medicos
 FOREIGN KEY (IdMedico) REFERENCES Medicos(IdMedico)
 );
 GO

--TABLA 06: CIE10 (Catálogo de Enfermedades)
CREATE TABLE CIE10 (
 CodigoCIE10 VARCHAR(10) PRIMARY KEY,
 Descripcion NVARCHAR(500) NOT NULL,
 Capitulo VARCHAR(10) NOT NULL,
 DescripcionCapitulo NVARCHAR(200) NOT NULL,
 Sexo CHAR(1) CHECK (Sexo IN ('M','F')),
 EdadMinima INT,
 EdadMaxima INT,
 NotificacionObligatoria BIT DEFAULT 0,
 Estado CHAR(1) DEFAULT 'A' CHECK (Estado IN ('A','I'))
 );
 GO
--Índice FULLTEXT para búsquedas rápidas
CREATE FULLTEXT CATALOG CatalogoCIE10 AS DEFAULT;
GO
 
CREATE FULLTEXT INDEX ON CIE10(Descripcion)
KEY INDEX PK__CIE10__D3E9319E60EFF86F ON CatalogoCIE10;
GO

--TABLA 07: Diagnosticos (Diagnósticos Médicos)
CREATE TABLE Diagnosticos (
 IdDiagnostico INT IDENTITY(1,1) PRIMARY KEY,
 IdConsulta INT NOT NULL,
 CodigoCIE10 VARCHAR(10) NOT NULL,
 DescripcionDiagnostico NVARCHAR(500) NOT NULL,
 TipoDiagnostico VARCHAR(20) NOT NULL
 CHECK (TipoDiagnostico IN ('Presuntivo','Definitivo')),
 Clasificacion VARCHAR(20) NOT NULL
 CHECK (Clasificacion IN ('Principal','Secundario','Complicacion')),
 FechaRegistro DATETIME2 DEFAULT SYSDATETIME() NOT NULL,
 CONSTRAINT FK_Diagnosticos_Consultas
 FOREIGN KEY (IdConsulta) REFERENCES Consultas(IdConsulta),
 CONSTRAINT FK_Diagnosticos_CIE10
 FOREIGN KEY (CodigoCIE10) REFERENCES CIE10(CodigoCIE10)
 );
GO

--TABLA 08: Medicamentos (Cat logo)
CREATE TABLE Medicamentos (
 IdMedicamento INT IDENTITY(1,1) PRIMARY KEY,
 CodigoMedicamento VARCHAR(20) UNIQUE NOT NULL,
 NombreGenerico NVARCHAR(200) NOT NULL,
 NombreComercial NVARCHAR(200),
 Presentacion NVARCHAR(100) NOT NULL,
 Concentracion NVARCHAR(50),
 FormaFarmaceutica VARCHAR(50) NOT NULL,
 UnidadMedida VARCHAR(20) NOT NULL,
 StockMinimo INT DEFAULT 10,
 tockActual INT DEFAULT 0,
 PrecioUnitario DECIMAL(10,2),
 RequiereReceta BIT DEFAULT 1,
 Estado CHAR(1) DEFAULT 'A' CHECK (Estado IN ('A','I'))
);
GO

--TABLA 09: Tratamientos (Prescripciones)
CREATE TABLE Tratamientos (
 IdTratamiento INT IDENTITY(1,1) PRIMARY KEY,
 IdDiagnostico INT NOT NULL,
 IdMedicamento INT NOT NULL,
 Dosis NVARCHAR(100) NOT NULL,
 Frecuencia NVARCHAR(100) NOT NULL,
 ViaAdministracion VARCHAR(50) NOT NULL
 CHECK (ViaAdministracion IN ('Oral','Endovenosa','Intramuscular','Topica','Sublingual','Rectal')),
 Duracion INT NOT NULL,
 IndicacionesEspeciales NVARCHAR(500),
 FechaInicio DATE NOT NULL,
 FechaFin AS DATEADD(DAY, Duracion, FechaInicio) PERSISTED,
 CONSTRAINT FK_Tratamientos_Diagnosticos
 FOREIGN KEY (IdDiagnostico) REFERENCES Diagnosticos(IdDiagnostico),
 CONSTRAINT FK_Tratamientos_Medicamentos
 FOREIGN KEY (IdMedicamento) REFERENCES Medicamentos(IdMedicamento)
);
GO

--TABLA 10: Usuarios (Seguridad)
CREATE TABLE Usuarios (
 IdUsuario INT IDENTITY(1,1) PRIMARY KEY,
 NombreUsuario VARCHAR(50) UNIQUE NOT NULL,
 PasswordHash VARBINARY(64) NOT NULL,
 PasswordSalt VARBINARY(32) NOT NULL,
 NombreCompleto NVARCHAR(150) NOT NULL,
 Email VARCHAR(100) UNIQUE NOT NULL,
 IdRol INT NOT NULL,
 UltimoAcceso DATETIME2,
 CambioPasswordObligatorio BIT DEFAULT 1,
 IntentosAccesoFallido INT DEFAULT 0,
 CuentaBloqueada BIT DEFAULT 0,
 FechaCreacion DATETIME2 DEFAULT SYSDATETIME() NOT NULL,
 Estado CHAR(1) DEFAULT 'A' CHECK (Estado IN ('A','I'))
);
GO

--TABLA 11: Roles (RBAC)
CREATE TABLE Roles (
 IdRol INT IDENTITY(1,1) PRIMARY KEY,
 NombreRol VARCHAR(50) UNIQUE NOT NULL,
 Descripcion NVARCHAR(200),
 Nivel INT NOT NULL,
 Estado CHAR(1) DEFAULT 'A' CHECK (Estado IN ('A','I'))
);
GO

ALTER TABLE Usuarios ADD CONSTRAINT FK_Usuarios_Roles
FOREIGN KEY (IdRol) REFERENCES Roles(IdRol);
GO

--TABLA 12: AuditLog (Auditor a Inmutable)
CREATE TABLE AuditLog (
 IdAudit BIGINT IDENTITY(1,1) PRIMARY KEY,
 TablaAfectada VARCHAR(100) NOT NULL,
 Operacion VARCHAR(10) NOT NULL CHECK (Operacion IN ('INSERT','UPDATE','DELETE')),
 IdRegistro INT NOT NULL,
 UsuarioID INT NOT NULL,
 UsuarioNombre NVARCHAR(100) NOT NULL,
 FechaHora DATETIME2 DEFAULT SYSDATETIME() NOT NULL,
 ValoresAnteriores NVARCHAR(MAX),
 ValoresNuevos NVARCHAR(MAX),
 DireccionIP VARCHAR(50),
 NombrePC VARCHAR(100)
);
GO

--Índice optimizado para consultas de auditoría
CREATE NONCLUSTERED INDEX IX_AuditLog_Tabla_Fecha
ON AuditLog(TablaAfectada, FechaHora DESC)
INCLUDE (Operacion, UsuarioNombre);
GO
--========================================
--INSERCIÓN DE DATOS INICIALES
--========================================
--Especialidades médicas
INSERT INTO Especialidades (NombreEspecialidad, Descripcion)
 VALUES
 ('Medicina General', 'Atención médica integral para adultos'),
 ('Pediatría', 'Atención especializada de niños y adolescentes'),
 ('Cardiología', 'Enfermedades del corazón y sistema cardiovascular'),
 ('Ginecología', 'Salud reproductiva femenina'),
 ('Traumatología', 'Lesiones del sistema musculoesquelético'),
 ('Neurología', 'Enfermedades del sistema nervioso'),
 ('Oftalmología', 'Enfermedades de los ojos'),
 ('Dermatología', 'Enfermedades de la piel');
GO

--Roles del sistema
INSERT INTO Roles (NombreRol, Descripcion, Nivel) VALUES
 ('Administrador', 'Acceso total al sistema', 1),
 ('Médico', 'Acceso a consultas y diagnósticos', 2),
 ('Enfermera', 'Acceso a citas y signos vitales', 3),
 ('Recepcionista', 'Registro de pacientes y citas', 4),
 ('Farmacia', 'Acceso a inventario y prescripciones', 5),
 ('Auditor', 'Consulta de logs y reportes', 6);
GO

--========================================
--ÍNDICES DE OPTIMIZACI N
--========================================
--Índices en Pacientes
CREATE NONCLUSTERED INDEX IX_Pacientes_DNI ON Pacientes(DNI);
CREATE NONCLUSTERED INDEX IX_Pacientes_Nombres ON Pacientes(Nombres, Apellidos);
CREATE NONCLUSTERED INDEX IX_Pacientes_Estado ON Pacientes(Estado) WHERE Estado = 'A';

--Índices en Citas
CREATE NONCLUSTERED INDEX IX_Citas_Paciente_Fecha
ON Citas(IdPaciente, FechaCita DESC);
CREATE NONCLUSTERED INDEX IX_Citas_Medico_Fecha
ON Citas(IdMedico, FechaCita, HoraInicio);
CREATE NONCLUSTERED INDEX IX_Citas_Estado
ON Citas(Estado, FechaCita);

--Índices en Consultas
CREATE NONCLUSTERED INDEX IX_Consultas_Paciente
ON Consultas(IdPaciente, FechaConsulta DESC);

CREATE NONCLUSTERED INDEX IX_Consultas_Medico
ON Consultas(IdMedico, FechaConsulta DESC);

--Índices en Diagn sticos
CREATE NONCLUSTERED INDEX IX_Diagnosticos_Consulta
ON Diagnosticos(IdConsulta);

CREATE NONCLUSTERED INDEX IX_Diagnosticos_CIE10
ON Diagnosticos(CodigoCIE10, FechaRegistro DESC);

--Índices en Medicamentos
CREATE NONCLUSTERED INDEX IX_Medicamentos_Nombre
ON Medicamentos(NombreGenerico);

CREATE NONCLUSTERED INDEX IX_Medicamentos_Stock
ON Medicamentos(StockActual) Where StockActual < 10;
GO


--========================================
--SP_RegistrarPaciente
--Registra un nuevo paciente generando historia clínico
--========================================
CREATE PROCEDURE SP_RegistrarPaciente
 @DNI VARCHAR(8),
 @Nombres NVARCHAR(80),
 @Apellidos NVARCHAR(80),
 @FechaNacimiento DATE,
 @Sexo CHAR(1),
 @Direccion NVARCHAR(200),
 @Telefono VARCHAR(15),
 @Email VARCHAR(100),
 @GrupoSanguineo VARCHAR(5),
 @UsuarioRegistro INT,
 @IdPacienteOut INT OUTPUT,
 @NroHistoriaOut VARCHAR(15) OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Anio VARCHAR(4) = YEAR(GETDATE());
  DECLARE @Correlativo INT;
  BEGIN TRY
   BEGIN TRANSACTION;
   --Verificar DNI duplicado
   IF EXISTS (SELECT 1 FROM Pacientes WHERE DNI = @DNI)
   BEGIN
    RAISERROR('El DNI ya está registrado en el sistema', 16, 1);
	RETURN;
   END
   --Obtener siguiente correlativo
   SELECT @Correlativo = ISNULL(MAX(CAST(RIGHT(NroHistoriaClinica, 5) AS INT)), 0) + 1
   FROM Pacientes
   WHERE NroHistoriaClinica LIKE 'HC-' + @Anio + '-%';
   --Generar número de historia clínica
   SET @NroHistoriaOut = 'HC-' + @Anio + '-' + RIGHT('00000' + CAST(@Correlativo AS VARCHAR), 5);
   --Insertar paciente
   INSERT INTO Pacientes (
    NroHistoriaClinica, Nombres, Apellidos, DNI, FechaNacimiento,
	Sexo, Direccion, Telefono, Email, GrupoSanguineo, UsuarioRegistro) 
	VALUES (
	@NroHistoriaOut, @Nombres, @Apellidos, @DNI, @FechaNacimiento,
	@Sexo, @Direccion, @Telefono, @Email, @GrupoSanguineo, @UsuarioRegistro);
	
	SET @IdPacienteOut = SCOPE_IDENTITY();

    COMMIT TRANSACTION;
	PRINT 'Paciente registrado exitosamente: ' + @NroHistoriaOut;
   END TRY
   BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	
	DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
	RAISERROR(@ErrorMsg, 16, 1);
	END CATCH
END;
GO

--========================================
--SP_ProgramarCita
--Programa una nueva cita validando disponibilidad
--========================================
CREATE PROCEDURE SP_ProgramarCita
 @IdPaciente INT,
 @IdMedico INT,
 @FechaCita DATE,
 @HoraInicio TIME,
 @MotivoConsulta NVARCHAR(500),
 @TipoCita VARCHAR(20),
 @UsuarioRegistro INT,
 @IdCitaOut INT OUTPUT,
 @CodigoCitaOut VARCHAR(20) OUTPUT
 AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE @HoraFin TIME = DATEADD(MINUTE, 30, @HoraInicio);
  
  BEGIN TRY
   BEGIN TRANSACTION;
    --Validar que paciente existe y está activo
	IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE IdPaciente= @IdPaciente AND Estado = 'A')
	BEGIN
	 RAISERROR('El paciente no existe o está inactivo',16, 1);
	 RETURN;
	END
	--Validar que médico existe y está activo
	IF NOT EXISTS (SELECT 1 FROM Medicos WHERE IdMedico =@IdMedico AND Estado = 'A')
	BEGIN
	 RAISERROR('El médico no existe o est inactivo',16, 1);
	  RETURN;
	END
	--Validar disponibilidad horaria (no existe cruce)
	IF EXISTS (
	 SELECT 1 FROM Citas
	 WHERE IdMedico = @IdMedico
	 AND FechaCita = @FechaCita
	 AND Estado NOT IN ('Cancelada', 'Reprogramada')
	 AND (
	  (@HoraInicio >= HoraInicio AND @HoraInicio <HoraFin) OR
	  (@HoraFin > HoraInicio AND @HoraFin <= HoraFin)
	 )
	)
	BEGIN
	 RAISERROR('El médico ya tiene una cita en ese horario', 16, 1);
	 RETURN;
	END
	--Generar código de cita
	DECLARE @Correlativo INT;
	SELECT @Correlativo = ISNULL(MAX(CAST(RIGHT(CodigoCita,6) AS INT)), 0) + 1
	FROM Citas
	WHERE CodigoCita LIKE 'CITA-' + CAST(YEAR(@FechaCita) AS VARCHAR) + '-%';
	SET @CodigoCitaOut = 'CITA-' + CAST(YEAR(@FechaCita) AS VARCHAR) + '-' + RIGHT('000000' + CAST(@Correlativo AS VARCHAR), 6);
	
	--Insertar cita
	INSERT INTO Citas (
	CodigoCita, IdPaciente, IdMedico, FechaCita, HoraInicio, HoraFin, MotivoConsulta, TipoCita, UsuarioRegistro) 
	VALUES (
	@CodigoCitaOut, @IdPaciente, @IdMedico, @FechaCita, @HoraInicio, @HoraFin, @MotivoConsulta, @TipoCita, @UsuarioRegistro);
	
	SET @IdCitaOut = SCOPE_IDENTITY();
	COMMIT TRANSACTION;
	PRINT 'Cita programada exitosamente: ' + @CodigoCitaOut;
   END TRY
   BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	
	DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
	RAISERROR(@ErrorMsg, 16, 1);
   END CATCH
END;
GO
--========================================
--SP_RegistrarConsulta
--Registra consulta médica con signos vitales
--========================================
CREATE PROCEDURE SP_RegistrarConsulta
 @IdCita INT,
 @PresionArterial VARCHAR(10),
 @Temperatura DECIMAL(4,1),
 @FrecuenciaCardiaca INT,
 @Peso DECIMAL(5,2),
 @Talla DECIMAL(5,2),
 @MotivoConsulta NVARCHAR(MAX),
 @ExamenFisico NVARCHAR(MAX),
 @IdConsultaOut INT OUTPUT
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @IdPaciente INT, @IdMedico INT;
 
 BEGIN TRY
  BEGIN TRANSACTION;
  
  --Obtener datos de la cita
  SELECT @IdPaciente = IdPaciente, @IdMedico = IdMedico
  FROM Citas WHERE IdCita = @IdCita AND Estado = 'Programada';
  IF @IdPaciente IS NULL
  BEGIN
   RAISERROR('La cita no existe o no está en estado Programada', 16, 1);
   RETURN;
  END
  
  --Insertar consulta
  INSERT INTO Consultas (IdCita, IdPaciente, IdMedico, PresionArterial, Temperatura, FrecuenciaCardiaca, Peso, Talla, MotivoConsulta, ExamenFisico) 
  VALUES (
  @IdCita, @IdPaciente, @IdMedico, @PresionArterial, @Temperatura,
  @FrecuenciaCardiaca, @Peso, @Talla, @MotivoConsulta, @ExamenFisico);
  SET @IdConsultaOut = SCOPE_IDENTITY();
  --Actualizar estado de cita
  UPDATE Citas SET Estado = 'Atendida' WHERE IdCita =@IdCita;
  
  COMMIT TRANSACTION;
 END TRY
 BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
  THROW;
 END CATCH
END;
GO

--========================================
--FUNCIONES DEL SISTEMA
--FN_CalcularEdad
--Calcula edad precisa en a os
--========================================
CREATE FUNCTION FN_CalcularEdad (@FechaNacimiento DATE)
RETURNS INT
 AS
 BEGIN
 DECLARE @Edad INT;
 SET @Edad = DATEDIFF(YEAR, @FechaNacimiento, GETDATE());
 --Ajustar si no ha cumplido años todavía este año
 IF (MONTH(@FechaNacimiento) > MONTH(GETDATE()) OR
 (MONTH(@FechaNacimiento) = MONTH(GETDATE()) AND DAY(@FechaNacimiento) > DAY(GETDATE())))
 BEGIN
  SET @Edad = @Edad- 1;
 END
 
 RETURN @Edad;
END;
GO

--========================================
--FN_ObtenerHistorialPaciente
--Retorna historial cl nico completo (TVF)
--========================================
CREATE FUNCTION FN_ObtenerHistorialPaciente (@IdPaciente INT)
RETURNS TABLE
AS
RETURN
(
 SELECT
  c.FechaConsulta,
  CONCAT(m.Nombres, ' ', m.Apellidos) AS NombreMedico, e.NombreEspecialidad,
  c.MotivoConsulta, d.CodigoCIE10, d.DescripcionDiagnostico, d.TipoDiagnostico,
  STRING_AGG(CONCAT(med.NombreGenerico, ' ', t.Dosis, ' ', t.Frecuencia), '; ') AS Tratamientos
 FROM Consultas c
 INNER JOIN Medicos m ON c.IdMedico = m.IdMedico
 INNER JOIN Especialidades e ON m.IdEspecialidad = e.IdEspecialidad
 LEFT JOIN Diagnosticos d ON c.IdConsulta = d.IdConsulta
 LEFT JOIN Tratamientos t ON d.IdDiagnostico = t.IdDiagnostico
 LEFT JOIN Medicamentos med ON t.IdMedicamento = med.IdMedicamento
 WHERE c.IdPaciente = @IdPaciente
 GROUP BY c.FechaConsulta, m.Nombres, m.Apellidos, e.NombreEspecialidad, c.MotivoConsulta, d.CodigoCIE10, d.
 DescripcionDiagnostico, d.TipoDiagnostico);
GO

--========================================
--TRIGGERS DE AUDITORÍA AUTOMÁTICA--
--========================================
--TRG_Auditoria_Pacientes
--Registra autom ticamente todos los cambios
CREATE TRIGGER TRG_Auditoria_Pacientes
ON Pacientes
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @Operacion VARCHAR(10);
 DECLARE @UsuarioID INT = CAST(SESSION_CONTEXT(N'UsuarioID') AS INT);
 DECLARE @UsuarioNombre NVARCHAR(100) = CAST(SESSION_CONTEXT(N'UsuarioNombre') AS NVARCHAR(100));
 --Determinar tipo de operación
 IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT *FROM deleted)
  SET @Operacion = 'UPDATE';
 ELSE IF EXISTS (SELECT * FROM inserted)
  SET @Operacion = 'INSERT';
 ELSE
  SET @Operacion = 'DELETE';
 --INSERT: Registrar valores nuevos
 IF @Operacion = 'INSERT'
 BEGIN
  INSERT INTO AuditLog (TablaAfectada, Operacion, IdRegistro, UsuarioID, UsuarioNombre, ValoresNuevos)
 SELECT
  'Pacientes',
  @Operacion,
  IdPaciente,
  @UsuarioID,
  @UsuarioNombre,
  (SELECT * FROM inserted i WHERE i.IdPaciente = inserted.IdPaciente FOR JSON PATH)
  FROM inserted;
 END
 --UPDATE: Registrar valores anteriores y nuevos
 IF @Operacion = 'UPDATE'
 BEGIN
  INSERT INTO AuditLog (TablaAfectada, Operacion, IdRegistro, UsuarioID, UsuarioNombre, ValoresAnteriores, ValoresNuevos)
  SELECT
   'Pacientes',
   @Operacion,
   i.IdPaciente,
   @UsuarioID,
   @UsuarioNombre,
   (SELECT * FROM deleted d WHERE d.IdPaciente = i.IdPaciente FOR JSON PATH),
   (SELECT * FROM inserted ins WHERE ins.IdPaciente = i.IdPaciente FOR JSON PATH)
  FROM inserted i;
 END
 
 --DELETE: Registrar valores eliminados
 IF @Operacion = 'DELETE'
 BEGIN
 INSERT INTO AuditLog (TablaAfectada, Operacion, IdRegistro, UsuarioID, UsuarioNombre, ValoresAnteriores)
 SELECT
  'Pacientes',
  @Operacion,
  IdPaciente,
  @UsuarioID,
  @UsuarioNombre,
  (SELECT * FROM deleted d WHERE d.IdPaciente = deleted.IdPaciente FOR JSON PATH)
  FROM deleted;
  END
END;
GO

--TRG_Auditoria_Diagnosticos
--Auditoría de diagnósticos (dato crítico)
CREATE TRIGGER TRG_Auditoria_Diagnosticos
ON Diagnosticos
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
 SET NOCOUNT ON;
 
 DECLARE @Operacion VARCHAR(10);
 DECLARE @UsuarioID INT = CAST(SESSION_CONTEXT(N'UsuarioID') AS INT);
 DECLARE @UsuarioNombre NVARCHAR(100) = CAST(SESSION_CONTEXT(N'UsuarioNombre') AS NVARCHAR(100));
 
 IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT *FROM deleted)
  SET @Operacion = 'UPDATE';
 ELSE IF EXISTS (SELECT * FROM inserted)
  SET @Operacion = 'INSERT';
 ELSE
  SET @Operacion = 'DELETE';
  
  --Registrar en AuditLog
  IF @Operacion = 'INSERT'
  BEGIN
   INSERT INTO AuditLog (TablaAfectada, Operacion, IdRegistro, UsuarioID, UsuarioNombre, ValoresNuevos)
   SELECT
    'Diagnosticos', @Operacion, IdDiagnostico, @UsuarioID, @UsuarioNombre,
	(SELECT * FROM inserted i WHERE i.IdDiagnostico = inserted.IdDiagnostico FOR JSON PATH)
	FROM inserted;
  END
  
  IF @Operacion = 'UPDATE'
  BEGIN
   INSERT INTO AuditLog (TablaAfectada, Operacion, IdRegistro, UsuarioID, UsuarioNombre, ValoresAnteriores, ValoresNuevos)
   SELECT
    'Diagnosticos', @Operacion, i.IdDiagnostico, @UsuarioID, @UsuarioNombre,
	(SELECT * FROM deleted d WHERE d.IdDiagnostico = i.IdDiagnostico FOR JSON PATH),
	(SELECT * FROM inserted ins WHERE ins.IdDiagnostico= i.IdDiagnostico FOR JSON PATH)
   FROM inserted i;
  END
  
  IF @Operacion = 'DELETE'
  BEGIN
  INSERT INTO AuditLog (TablaAfectada, Operacion, IdRegistro, UsuarioID, UsuarioNombre, ValoresAnteriores)
  SELECT 
   'Diagnosticos', @Operacion, IdDiagnostico,@UsuarioID, @UsuarioNombre,
   (SELECT * FROM deleted d WHERE d.IdDiagnostico = deleted.IdDiagnostico FOR JSON PATH)
  FROM deleted;
  END
END;
GO

--========================================
--VISTAS DEL SISTEMA--
--========================================

--VW_PacientesActivos
--Vista optimizada de pacientes activos
CREATE VIEW VW_PacientesActivos
AS
SELECT
 p.IdPaciente,
 p.NroHistoriaClinica,
 CONCAT(p.Nombres, ' ', p.Apellidos) AS NombreCompleto,p.DNI,
 p.FechaNacimiento, dbo.FN_CalcularEdad(p.FechaNacimiento) AS Edad, p.Sexo,
 CASE p.Sexo WHEN 'M' THEN 'Masculino' ELSE 'Femenino' END AS SexoDescripcion,
 p.GrupoSanguineo, p.Telefono, p.Email, p.Direccion, p.FechaRegistro,
 (SELECT MAX(FechaConsulta) FROM Consultas WHERE IdPaciente= p.IdPaciente) AS UltimaConsulta,
 (SELECT COUNT(*) FROM Citas WHERE IdPaciente = p.IdPaciente) AS TotalCitas,
 (SELECT COUNT(*) FROM Consultas WHERE IdPaciente = p.IdPaciente) AS TotalConsultas
FROM Pacientes p
WHERE p.Estado = 'A';
GO


--VW_AgendaMedica
--Vista de citas prégramadas para mÉdicos
CREATE VIEW VW_AgendaMedica
AS
SELECT
 c.IdCita,
 c.CodigoCita,
 c.FechaCita,
 c.HoraInicio,
 c.HoraFin,
 CONCAT(m.Nombres, ' ', m.Apellidos) AS NombreMedico, m.CMP,
 e.NombreEspecialidad AS Especialidad,
 CONCAT(p.Nombres, ' ', p.Apellidos) AS NombrePaciente, p.NroHistoriaClinica, p.DNI,
 dbo.FN_CalcularEdad(p.FechaNacimiento) AS EdadPaciente, c.TipoCita, c.MotivoConsulta, c.Estado,
 CASE c.Estado
  WHEN 'Programada' THEN 'Pendiente'
  WHEN 'Confirmada' THEN 'Confirmada'
  WHEN 'Atendida' THEN 'Finalizada'
  ELSE 'No vigente'
 END AS EstadoDescriptivo
FROM Citas c
INNER JOIN Medicos m ON c.IdMedico = m.IdMedico
INNER JOIN Especialidades e ON m.IdEspecialidad = e.IdEspecialidad
INNER JOIN Pacientes p ON c.IdPaciente = p.IdPaciente
WHERE c.Estado IN ('Programada', 'Confirmada', 'Atendida');
GO


--VW_EstadisticasDiagnosticos
--Vista para reportes epidemiológicos
CREATE VIEW VW_EstadisticasDiagnosticos
AS
SELECT
 d.CodigoCIE10,
 c10.Descripcion AS DescripcionCIE10,
 c10.Capitulo,
 c10.DescripcionCapitulo,
 COUNT(*) AS TotalCasos,
 COUNT(DISTINCT d.IdConsulta) AS TotalConsultas,
 MIN(cons.FechaConsulta) AS PrimerCaso,
 MAX(cons.FechaConsulta) AS UltimoCaso,
 YEAR(cons.FechaConsulta) AS Anio,
 MONTH(cons.FechaConsulta) AS Mes,
 DATENAME(MONTH, cons.FechaConsulta) AS NombreMes
FROM Diagnosticos d
INNER JOIN CIE10 c10 ON d.CodigoCIE10 = c10.CodigoCIE10
INNER JOIN Consultas cons ON d.IdConsulta = cons.IdConsulta
GROUP BY
 d.CodigoCIE10,
 c10.Descripcion,
 c10.Capitulo,
 c10.DescripcionCapitulo,
 YEAR(cons.FechaConsulta),
 MONTH(cons.FechaConsulta),
 DATENAME(MONTH, cons.FechaConsulta);
GO
--========================================
--CONFIGURACIÓN DE SEGURIDAD RBAC--
--========================================

--Crear roles de base de datos
CREATE ROLE RolAdministrador;
CREATE ROLE RolMedico;
CREATE ROLE RolEnfemera;
CREATE ROLE RolRecepcionista;
CREATE ROLE RolFarmacia;
CREATE ROLE RolAuditoria;
GO

--Permisos para el administrador
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO RolAdministrador;
GRANT EXECUTE ON SCHEMA::dbo TO RolAdministrador;
GRANT ALTER ANY USER TO RolAdministrador;
GO

--Permisos para Médico
GRANT SELECT ON Pacientes TO RolMedico;
GRANT SELECT ON Citas TO RolMedico;
GRANT SELECT, INSERT, UPDATE ON CONSULTAS TO RolMedico;
GRANT SELECT, INSERT, UPDATE ON Diagnosticos TO RolMedico;
GRANT SELECT, INSERT, UPDATE ON Tratamientos TO RolMedico;
GRANT SELECT ON CIE10 TO RolMedico;
GRANT SELECT ON Medicamentos TO RolMedico;
GRANT EXECUTE ON SP_RegistrarConsulta TO RolMedico;
GO

--Permisos para Enfermera
GRANT SELECT ON Tratamientos TO RolFarmacia;
GRANT SELECT, UPDATE ON Medicamentos TO RolFarmacia
GRANT SELECT ON Diagnosticos TO RolFarmacia;
GO

--Permisos para Auditor (Solo Lectura)
GRANT SELECT ON SCHEMA::dbo TO RolAuditoria;
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO RolAuditoria;
GO

USE master;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'SIHGCContraseñaMaster2025';
GO

CREATE CERTIFICATE SIGHCCertificate
WITH SUBJECT = 'SIGHC TDE Certificate';
GO

USE SIGHC
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE SIGHCCertificate;
GO

ALTER DATABASE SIGHC
SET ENCRYPTION ON;
GO

--======================================
--JOB: Backup Completo Semanal--
--======================================
USE msdb
GO

EXEC sp_add_job
 @job_name = N'SIGHC_Backup_Completo_Semanal';
GO

EXEC sp_add_jobstep
 @job_name = N'SIGHC_Backup_Completo_Semanal',
 @step_name = N'Ejecutar Backup FULL',
 @subsystem = N'TSQL',
 @command = N'
  DECLARE @BackupPath NVARCHAR(500);
  DECLARE @FileName NVARCHAR(500);
  SET @BackupPath = ''D:\U\300 par\IS-382 Gestión de entornos de bases de datos\BACKUPS\'';
  SET @FileName = @BackupPath + ''SIGHC_FULL_'' +
   CONVERT(VARCHAR, GETDATE(), 112) + ''_'' +REPLACE(CONVERT(VARCHAR, GETDATE(),
   108), '':'', '''') + ''.bak'';
  BACKUP DATABASE [SIGHC]
  TO DISK = @FileName
  WITH
  COMPRESSION,
  CHECKSUM,
  INIT,
  NAME = ''SIGHC Backup Completo'',
  DESCRIPTION = ''Backup semanal completo automatizado'';
  --Verificar integridaD
  RESTORE VERIFYONLY FROM DISK = @FileName;',
  @retry_attempts = 3,
  @retry_interval = 5;
  GO

EXEC sp_add_schedule
 @schedule_name = N'Cada_Domingo_02AM',
 @freq_type = 8,
 @freq_interval = 1,
 @freq_recurrence_factor = 1,
 @active_start_time = 020000;
GO

EXEC sp_attach_schedule
 @job_name = N'SIGHC_Backup_Completo_Semanal',
 @schedule_name = N'Cada_Domingo_02AM';
GO

EXEC sp_add_jobserver
 @job_name = N'SIGHC_Backup_Completo_Semanal';
GO

--========================================
--JOB: Backup Diferencial Diario
--========================================
EXEC sp_add_job
 @job_name = N'SIGHC_Backup_Diferencial_Diario';
GO

EXEC sp_add_jobstep
 @job_name = N'SIGHC_Backup_Diferencial_Diario',
 @step_name = N'Ejecutar Backup DIFFERENTIAL',
 @subsystem = N'TSQL',
 @command = N'
  DECLARE @BackupPath NVARCHAR(500);
  DECLARE @FileName NVARCHAR(500);
  
  SET @BackupPath = ''D:\U\300 par\IS-382 Gestión de entornos de bases de datos\BACKUPS\'';
  SET @FileName = @BackupPath + ''SIGHC_DIFF_'' +
   CONVERT(VARCHAR, GETDATE(), 112) + ''_'' +
   REPLACE(CONVERT(VARCHAR, GETDATE(),108), '':'', '''') + ''.bak'';
  BACKUP DATABASE [SIGHC]
  TO DISK = @FileName
  WITH
   DIFFERENTIAL,
   COMPRESSION,
   CHECKSUM,
   INIT;
 ',
 @retry_attempts = 3;
GO

EXEC sp_add_schedule
 @schedule_name = N'Diario_02AM',
 @freq_type = 4,
 @freq_interval = 1,
 @active_start_time = 020000;
 GO

EXEC sp_attach_schedule
 @job_name = N'SIGHC_Backup_Diferencial_Diario',
 @schedule_name = N'Diario_02AM';
GO

EXEC sp_add_jobserver
 @job_name = N'SIGHC_Backup_Diferencial_Diario';
GO

--========================================
--Backup de Transaction Log cada 15 minutos
--========================================
ALTER DATABASE SIGHC SET RECOVERY FULL;
GO

EXEC sp_add_job
@job_name = N'SIGHC_Backup_TransactionLog';
GO

EXEC sp_add_jobstep
 @job_name = N'SIGHC_Backup_TransactionLog',
 @step_name = N'Backup LOG',
 @subsystem = N'TSQL',
 @command = N'
  DECLARE @FileName NVARCHAR(500);
  SET @FileName = ''D:\U\300 par\IS-382 Gestión de entornos de bases de datos\BACKUPS\Logs\SIGHC_LOG_'' +
   CONVERT(VARCHAR, GETDATE(), 112) + ''_'' +
   REPLACE(CONVERT(VARCHAR, GETDATE(),
   ), '':'', '''') + ''.trn'';
  
  BACKUP LOG [SIGHC]
  TO DISK = @FileName
  COMPRESSION, CHECKSUM;
';
GO

EXEC sp_add_schedule 
 @schedule_name = N'Cada_15_Minutos',
 @freq_type = 4,
 @freq_interval = 1,
 @freq_subday_type = 4,
 @freq_subday_interval = 15;
GO


EXEC sp_attach_schedule 
 @job_name = N'SIGHC_Backup_TransactionLog',
 @schedule_id = 12;
GO

EXEC sp_add_jobserver
 @job_name = N'SIGHC_Backup_TransactionLog';
GO

use SIGHC
go
