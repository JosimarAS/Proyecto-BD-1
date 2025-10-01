-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8mb3 ;
USE `mydb` ;


-- -----------------------------------------------------
-- Table `mydb`.`mk_buildings`
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
-- Table `mydb`.`mk_spaces`
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
-- Table `mydb`.`mk_contracts`
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
-- Table `mydb`.`mk_operational_expenses`
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
-- Table `mydb`.`mk_monthly_settlements` 
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
-- Table `mydb`.`mk_user_roles` 
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
-- Table `mydb`.`mk_sales_payments` 
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
-- Table `mydb`.`mk_address`
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
-- Table `mydb`.`mk_commerces`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_commerces` (
  `CommerceId` INT NOT NULL AUTO_INCREMENT,
  `CommerceName` VARCHAR(100) NOT NULL,
  `Category` ENUM('GASTRONOMIC','RETAIL') NOT NULL,
  `OwnerName` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`CommerceId`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `mydb`.`mk_users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mk_users` (
  `UserID` INT NOT NULL AUTO_INCREMENT,
  `Username` VARCHAR(50) NOT NULL UNIQUE,
  `PasswordHash` VARCHAR(255) NOT NULL,
  `Email` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`UserID`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `mydb`.`mk_products`
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
-- Table `mydb`.`mk_facturas`
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
-- Table `mydb`.`mk_detallefacturas`
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
-- Table `mydb`.`mk_logs`
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






-- RegisterSale:

DELIMITER $$
CREATE PROCEDURE registerSale(
    IN p_product_name VARCHAR(100),
    IN p_store_name VARCHAR(100),
    IN p_quantity INT,
    IN p_amount_paid DECIMAL(10,2),
    IN p_payment_method VARCHAR(50),
    IN p_payment_confirmations VARCHAR(255),
    IN p_reference_numbers VARCHAR(255),
    IN p_invoice_number VARCHAR(50),
    IN p_customer VARCHAR(100),
    IN p_applied_discounts DECIMAL(10,2),
    IN p_computer VARCHAR(100),
    IN p_username VARCHAR(50)
)
BEGIN
    DECLARE v_product_id INT;
    DECLARE v_commerce_id INT;
    DECLARE v_current_inventory INT;
    DECLARE v_factura_id INT;
    DECLARE v_checksum INT;

    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Obtener IDs del producto y comercio
    SELECT p.ProductID, p.MK_Commerces_CommerceId
    INTO v_product_id, v_commerce_id
    FROM mk_products p
    JOIN mk_commerces c ON p.MK_Commerces_CommerceId = c.CommerceId
    WHERE p.ProductName = p_product_name
      AND c.CommerceName = p_store_name;

    IF v_product_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto o comercio no encontrado';
    END IF;

    -- Verificar inventario
    SELECT Cantidad INTO v_current_inventory
    FROM mk_products
    WHERE ProductID = v_product_id;

    IF v_current_inventory < p_quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventario insuficiente';
    END IF;

    -- Crear factura
    INSERT INTO mk_facturas (Fecha, Total, Mk_Users_UserID, MK_Commerces_CommerceId)
    VALUES (NOW(), p_amount_paid, 1, v_commerce_id);

    SET v_factura_id = LAST_INSERT_ID();

    -- Detalle de factura
    INSERT INTO mk_detallefacturas (Cantidad, PrecioUnitario, Subtotal, MK_Facturas_FacturaID, MK_Products_ProductID)
    VALUES (p_quantity, p_amount_paid/p_quantity, p_amount_paid, v_factura_id, v_product_id);

    -- Registrar pago
    INSERT INTO mk_sales_payments (PaymentMethod, PaymentConfirmations, ReferenceNumbers, AppliedDiscounts, CustomerName, MK_Facturas_FacturaID)
    VALUES (p_payment_method, p_payment_confirmations, p_reference_numbers, p_applied_discounts, p_customer, v_factura_id);

    -- Actualizar inventario
    UPDATE mk_products
    SET Cantidad = Cantidad - p_quantity
    WHERE ProductID = v_product_id;

    -- Log simple de la operación
    SET v_checksum = CRC32(CONCAT(v_product_id, v_commerce_id, p_quantity, p_amount_paid));

    INSERT INTO mk_logs (descrption, Mk_Users_UserID, postTime, username, Trace, referenceId1, referenceId2, value1, value2, Checksum, Mk_logType_LogTypeId, Mk_Traduccion_TraduccionId)
    VALUES ('Venta registrada', 1, CURDATE(), p_username, 'registerSale', v_factura_id, v_product_id, p_product_name, p_store_name, v_checksum, 1, 1);

    COMMIT;
END$$
DELIMITER ;







-- SettleCommerce:

DELIMITER $$
CREATE PROCEDURE settleCommerce(
    IN p_commerce_name VARCHAR(100),
    IN p_space_name VARCHAR(100),
    IN p_computer VARCHAR(100),
    IN p_username VARCHAR(50)
)
BEGIN
    DECLARE v_commerce_id INT;
    DECLARE v_space_id INT;
    DECLARE v_contract_id INT;
    DECLARE v_current_month DATE;
    DECLARE v_sales_percentage DECIMAL(5,2);
    DECLARE v_base_rent DECIMAL(10,2);
    DECLARE v_total_sales DECIMAL(12,2);
    DECLARE v_calculated_fee DECIMAL(10,2);
    DECLARE v_total_amount DECIMAL(10,2);
    DECLARE v_existing_settlement INT;
    DECLARE v_checksum INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SET v_current_month = DATE_FORMAT(CURDATE(), '%Y-%m-01');

    -- Obtener datos del contrato y IDs
    SELECT c.ContractId, c.SalesPercentageFee, c.BaseMonthlyRent, com.CommerceId, s.SpaceId
    INTO v_contract_id, v_sales_percentage, v_base_rent, v_commerce_id, v_space_id
    FROM mk_contracts c
    JOIN mk_commerces com ON c.Mk_Commerces_CommerceId = com.CommerceId
    JOIN mk_spaces s ON c.Mk_Spaces_SpaceId = s.SpaceId
    WHERE com.CommerceName = p_commerce_name
      AND s.SpaceName = p_space_name
      AND c.Status = 'ACTIVE';

    IF v_contract_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contrato activo no encontrado';
    END IF;

    -- Verificar si ya hay liquidación de este mes
    SELECT COUNT(*) INTO v_existing_settlement
    FROM mk_monthly_settlements
    WHERE Mk_Contracts_ContractId = v_contract_id
      AND SettlementMonth = v_current_month;

    IF v_existing_settlement > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya se liquidó este comercio este mes';
    END IF;

    -- Calcular ventas totales
    SELECT COALESCE(SUM(f.Total),0) INTO v_total_sales
    FROM mk_facturas f
    WHERE f.MK_Commerces_CommerceId = v_commerce_id
      AND YEAR(f.Fecha) = YEAR(CURDATE())
      AND MONTH(f.Fecha) = MONTH(CURDATE());

    -- Calcular comisión y total
    SET v_calculated_fee = v_total_sales * (v_sales_percentage/100);
    SET v_total_amount = v_base_rent + v_calculated_fee;

    -- Insertar liquidación
    INSERT INTO mk_monthly_settlements (SettlementMonth, TotalSales, CalculatedFee, BaseRent, TotalAmount, SettlementDate, Status, Mk_Contracts_ContractId)
    VALUES (v_current_month, v_total_sales, v_calculated_fee, v_base_rent, v_total_amount, NOW(), 'PENDING', v_contract_id);

    -- Log de la operación
    SET v_checksum = CRC32(CONCAT(v_contract_id, v_total_sales, v_total_amount));

    INSERT INTO mk_logs (descrption, Mk_Users_UserID, postTime, username, Trace, referenceId1, referenceId2, value1, value2, Checksum, Mk_logType_LogTypeId, Mk_Traduccion_TraduccionId)
    VALUES ('Liquidación mensual', 1, CURDATE(), p_username, 'settleCommerce', v_contract_id, LAST_INSERT_ID(), p_commerce_name, p_space_name, v_checksum, 1, 1);

    COMMIT;
END$$
DELIMITER ;







-- VISTA:
CREATE VIEW business_monthly_report AS
SELECT 
    c.CommerceName AS Business_Name,
    s.SpaceName AS Store_Space_Name,
    b.BuildingName AS Building_Name,
    MIN(f.Fecha) AS First_Sale_Date,
    MAX(f.Fecha) AS Last_Sale_Date,
    SUM(df.Cantidad) AS Items_Sold,
    SUM(f.Total) AS Total_Sales_Amount,
    con.SalesPercentageFee AS Fee_Percentage,
    (SUM(f.Total)*con.SalesPercentageFee/100) AS Fee_Amount,
    con.BaseMonthlyRent AS Monthly_Rent
FROM mk_commerces c
JOIN mk_contracts con ON c.CommerceId = con.Mk_Commerces_CommerceId
JOIN mk_spaces s ON con.Mk_Spaces_SpaceId = s.SpaceId
JOIN mk_buildings b ON s.Mk_Buildings_BuildingId = b.BuildingId
LEFT JOIN mk_facturas f ON c.CommerceId = f.MK_Commerces_CommerceId
      AND YEAR(f.Fecha)=YEAR(CURDATE())
      AND MONTH(f.Fecha)=MONTH(CURDATE())
LEFT JOIN mk_detallefacturas df ON f.FacturaID = df.MK_Facturas_FacturaID
WHERE con.Status='ACTIVE'
GROUP BY c.CommerceId, s.SpaceId, b.BuildingId, con.SalesPercentageFee, con.BaseMonthlyRent;