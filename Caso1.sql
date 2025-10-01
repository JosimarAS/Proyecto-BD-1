-- -----------------------------------------------------
-- Table `mydb`.`mk_buildings` (EDIFICIOS)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_buildings` (
  `BuildingId` INT NOT NULL AUTO_INCREMENT,
  `BuildingName` VARCHAR(100) NOT NULL,
  `Address` VARCHAR(255) NOT NULL,
  `TotalInvestment` DECIMAL(15,2) DEFAULT 0.00,
  `ConstructionDate` DATE NULL,
  `Mk_Address_AddressId` INT NOT NULL,
  PRIMARY KEY (`BuildingId`),
  INDEX `fk_Mk_Buildings_Mk_Address1_idx` (`Mk_Address_AddressId` ASC),
  CONSTRAINT `fk_Mk_Buildings_Mk_Address`
    FOREIGN KEY (`Mk_Address_AddressId`)
    REFERENCES `mydb`.`mk_address` (`AddressId`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `mydb`.`mk_spaces` (ESPACIOS/LOCALES)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_spaces` (
  `SpaceId` INT NOT NULL AUTO_INCREMENT,
  `SpaceName` VARCHAR(100) NOT NULL,
  `Size` DECIMAL(8,2) NOT NULL,
  `SpaceType` ENUM('GASTRONOMIC', 'RETAIL') NOT NULL,
  `Status` ENUM('AVAILABLE', 'OCCUPIED', 'UNDER_RENOVATION') DEFAULT 'AVAILABLE',
  `BaseRent` DECIMAL(10,2) NOT NULL,
  `Mk_Buildings_BuildingId` INT NOT NULL,
  PRIMARY KEY (`SpaceId`),
  INDEX `fk_Mk_Spaces_Mk_Buildings1_idx` (`Mk_Buildings_BuildingId` ASC),
  CONSTRAINT `fk_Mk_Spaces_Mk_Buildings`
    FOREIGN KEY (`Mk_Buildings_BuildingId`)
    REFERENCES `mydb`.`mk_buildings` (`BuildingId`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `mydb`.`mk_contracts` (CONTRATOS)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_contracts` (
  `ContractId` INT NOT NULL AUTO_INCREMENT,
  `StartDate` DATE NOT NULL,
  `EndDate` DATE NOT NULL,
  `BaseMonthlyRent` DECIMAL(10,2) NOT NULL,
  `SalesPercentageFee` DECIMAL(5,2) NOT NULL,
  `MonthlySettlementDay` INT NOT NULL CHECK (MonthlySettlementDay BETWEEN 1 AND 28),
  `Status` ENUM('ACTIVE', 'EXPIRED', 'TERMINATED') DEFAULT 'ACTIVE',
  `Mk_Spaces_SpaceId` INT NOT NULL,
  `Mk_Commerces_CommerceId` INT NOT NULL,
  PRIMARY KEY (`ContractId`),
  INDEX `fk_Mk_Contracts_Mk_Spaces1_idx` (`Mk_Spaces_SpaceId` ASC),
  INDEX `fk_Mk_Contracts_Mk_Commerces1_idx` (`Mk_Commerces_CommerceId` ASC),
  CONSTRAINT `fk_Mk_Contracts_Mk_Spaces`
    FOREIGN KEY (`Mk_Spaces_SpaceId`)
    REFERENCES `mydb`.`mk_spaces` (`SpaceId`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Mk_Contracts_Mk_Commerces`
    FOREIGN KEY (`Mk_Commerces_CommerceId`)
    REFERENCES `mydb`.`mk_commerces` (`CommerceId`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `mydb`.`mk_operational_expenses` (GASTOS OPERATIVOS)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_operational_expenses` (
  `ExpenseId` INT NOT NULL AUTO_INCREMENT,
  `ExpenseDate` DATE NOT NULL,
  `Amount` DECIMAL(10,2) NOT NULL,
  `Category` ENUM('UTILITIES', 'SECURITY', 'CLEANING', 'MARKETING', 'MAINTENANCE') NOT NULL,
  `Description` VARCHAR(255) NULL,
  `InvoiceNumber` VARCHAR(50) NULL,
  `Mk_Buildings_BuildingId` INT NOT NULL,
  PRIMARY KEY (`ExpenseId`),
  INDEX `fk_Mk_Operational_Expenses_Mk_Buildings1_idx` (`Mk_Buildings_BuildingId` ASC),
  CONSTRAINT `fk_Mk_Operational_Expenses_Mk_Buildings`
    FOREIGN KEY (`Mk_Buildings_BuildingId`)
    REFERENCES `mydb`.`mk_buildings` (`BuildingId`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `mydb`.`mk_monthly_settlements` (LIQUIDACIONES MENSUALES)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_monthly_settlements` (
  `SettlementId` INT NOT NULL AUTO_INCREMENT,
  `SettlementMonth` DATE NOT NULL, -- Primer día del mes liquidado
  `TotalSales` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `CalculatedFee` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `BaseRent` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `TotalAmount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `SettlementDate` DATETIME NULL,
  `Status` ENUM('PENDING', 'PAID', 'OVERDUE') DEFAULT 'PENDING',
  `Mk_Contracts_ContractId` INT NOT NULL,
  PRIMARY KEY (`SettlementId`),
  INDEX `fk_Mk_Monthly_Settlements_Mk_Contracts1_idx` (`Mk_Contracts_ContractId` ASC),
  UNIQUE INDEX `unique_settlement_per_month` (`SettlementMonth` ASC, `Mk_Contracts_ContractId` ASC),
  CONSTRAINT `fk_Mk_Monthly_Settlements_Mk_Contracts`
    FOREIGN KEY (`Mk_Contracts_ContractId`)
    REFERENCES `mydb`.`mk_contracts` (`ContractId`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `mydb`.`mk_user_roles` (ROLES DE USUARIO)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_user_roles` (
  `UserRoleId` INT NOT NULL AUTO_INCREMENT,
  `RoleType` ENUM('ADMINISTRATOR', 'TENANT') NOT NULL,
  `Mk_Users_UserID` INT NOT NULL,
  `Mk_Commerces_CommerceId` INT NULL, -- NULL para administradores
  PRIMARY KEY (`UserRoleId`),
  INDEX `fk_Mk_User_Roles_Mk_Users1_idx` (`Mk_Users_UserID` ASC),
  INDEX `fk_Mk_User_Roles_Mk_Commerces1_idx` (`Mk_Commerces_CommerceId` ASC),
  CONSTRAINT `fk_Mk_User_Roles_Mk_Users`
    FOREIGN KEY (`Mk_Users_UserID`)
    REFERENCES `mydb`.`mk_users` (`UserID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Mk_User_Roles_Mk_Commerces`
    FOREIGN KEY (`Mk_Commerces_CommerceId`)
    REFERENCES `mydb`.`mk_commerces` (`CommerceId`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `mydb`.`mk_sales_payments` (PAGOS DE VENTAS)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_sales_payments` (
  `PaymentId` INT NOT NULL AUTO_INCREMENT,
  `PaymentMethod` VARCHAR(50) NOT NULL,
  `PaymentConfirmations` VARCHAR(255) NULL,
  `ReferenceNumbers` VARCHAR(255) NULL,
  `AppliedDiscounts` DECIMAL(10,2) DEFAULT 0.00,
  `CustomerName` VARCHAR(100) NULL,
  `MK_Facturas_FacturaID` INT NOT NULL,
  PRIMARY KEY (`PaymentId`),
  INDEX `fk_Mk_Sales_Payments_MK_Facturas1_idx` (`MK_Facturas_FacturaID` ASC),
  CONSTRAINT `fk_Mk_Sales_Payments_MK_Facturas`
    FOREIGN KEY (`MK_Facturas_FacturaID`)
    REFERENCES `mydb`.`mk_facturas` (`FacturaID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Tabla DIRECCIONES (mk_address)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_address` (
  `AddressId` INT NOT NULL AUTO_INCREMENT,
  `Street` VARCHAR(100) NOT NULL,
  `City` VARCHAR(50) NOT NULL,
  `Province` VARCHAR(50) NOT NULL,
  `PostalCode` VARCHAR(20) NULL,
  PRIMARY KEY (`AddressId`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Tabla COMERCIOS (mk_commerces)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_commerces` (
  `CommerceId` INT NOT NULL AUTO_INCREMENT,
  `CommerceName` VARCHAR(100) NOT NULL,
  `Category` ENUM('GASTRONOMIC','RETAIL') NOT NULL,
  `OwnerName` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`CommerceId`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Tabla USUARIOS (mk_users)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_users` (
  `UserID` INT NOT NULL AUTO_INCREMENT,
  `Username` VARCHAR(50) NOT NULL UNIQUE,
  `PasswordHash` VARCHAR(255) NOT NULL,
  `Email` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`UserID`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Tabla PRODUCTOS (mk_products)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_products` (
  `ProductID` INT NOT NULL AUTO_INCREMENT,
  `ProductName` VARCHAR(100) NOT NULL,
  `Description` VARCHAR(255) NULL,
  `Price` DECIMAL(10,2) NOT NULL,
  `Cantidad` INT NOT NULL,
  `MK_Commerces_CommerceId` INT NOT NULL,
  PRIMARY KEY (`ProductID`),
  INDEX `fk_Mk_Products_Mk_Commerces_idx` (`MK_Commerces_CommerceId` ASC),
  CONSTRAINT `fk_Mk_Products_Mk_Commerces`
    FOREIGN KEY (`MK_Commerces_CommerceId`)
    REFERENCES `mydb`.`mk_commerces` (`CommerceId`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Tabla FACTURAS (mk_facturas)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_facturas` (
  `FacturaID` INT NOT NULL AUTO_INCREMENT,
  `Fecha` DATETIME NOT NULL,
  `Total` DECIMAL(10,2) NOT NULL,
  `Mk_Users_UserID` INT NOT NULL,
  `MK_Commerces_CommerceId` INT NOT NULL,
  PRIMARY KEY (`FacturaID`),
  INDEX `fk_Mk_Facturas_Mk_Users_idx` (`Mk_Users_UserID` ASC),
  INDEX `fk_Mk_Facturas_Mk_Commerces_idx` (`MK_Commerces_CommerceId` ASC),
  CONSTRAINT `fk_Mk_Facturas_Mk_Users`
    FOREIGN KEY (`Mk_Users_UserID`)
    REFERENCES `mydb`.`mk_users` (`UserID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Mk_Facturas_Mk_Commerces`
    FOREIGN KEY (`MK_Commerces_CommerceId`)
    REFERENCES `mydb`.`mk_commerces` (`CommerceId`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Tabla DETALLE FACTURAS (mk_detallefacturas)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_detallefacturas` (
  `DetalleFacturaID` INT NOT NULL AUTO_INCREMENT,
  `Cantidad` INT NOT NULL,
  `PrecioUnitario` DECIMAL(10,2) NOT NULL,
  `Subtotal` DECIMAL(10,2) NOT NULL,
  `MK_Facturas_FacturaID` INT NOT NULL,
  `MK_Products_ProductID` INT NOT NULL,
  PRIMARY KEY (`DetalleFacturaID`),
  INDEX `fk_Mk_DetalleFacturas_Facturas_idx` (`MK_Facturas_FacturaID` ASC),
  INDEX `fk_Mk_DetalleFacturas_Products_idx` (`MK_Products_ProductID` ASC),
  CONSTRAINT `fk_Mk_DetalleFacturas_Facturas`
    FOREIGN KEY (`MK_Facturas_FacturaID`)
    REFERENCES `mydb`.`mk_facturas` (`FacturaID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Mk_DetalleFacturas_Products`
    FOREIGN KEY (`MK_Products_ProductID`)
    REFERENCES `mydb`.`mk_products` (`ProductID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Tabla LOGS (mk_logs)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_logs` (
  `LogId` INT NOT NULL AUTO_INCREMENT,
  `descrption` VARCHAR(255) NOT NULL,
  `Mk_Users_UserID` INT NOT NULL,
  `postTime` DATETIME NOT NULL,
  `username` VARCHAR(50) NOT NULL,
  `Trace` VARCHAR(100) NOT NULL,
  `referenceId1` INT NULL,
  `referenceId2` INT NULL,
  `value1` VARCHAR(100) NULL,
  `value2` VARCHAR(100) NULL,
  `Checksum` INT NOT NULL,
  `Mk_logType_LogTypeId` INT NOT NULL,
  `Mk_Traduccion_TraduccionId` INT NOT NULL,
  PRIMARY KEY (`LogId`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;