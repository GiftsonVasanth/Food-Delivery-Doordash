create table Customer
(
    CustomerId   integer not null,
    Email        varchar(50),
    Passcode     varchar(20) not null,
    FirstName    varchar(30) not null,
    LastName     varchar(30),
    CountryCode  number(2) DEFAULT 0,
    MobileNumber number(10) not null,
    DashPass     varchar(10) DEFAULT 'InActive',
    PRIMARY KEY (CustomerId)
);


create table ZipCode
(
    Zipcode   number(6),
    City      varchar(20) NOT NULL,
    StateName varchar(20),
    PRIMARY KEY (Zipcode)
);


create table Address
(
    AddressId  integer,
    StreetNo   integer,
    StreetName  varchar(50) NOT NULL,
    Zipcode    number(6) NOT NULL,
    CustomerId integer,
    PRIMARY KEY (AddressId),
    FOREIGN KEY (Zipcode) REFERENCES ZipCode (Zipcode) ON DELETE CASCADE,
    FOREIGN KEY (CustomerId) REFERENCES Customer (CustomerId) ON DELETE CASCADE
);

create table Restaurant
(
    RestaurantId    integer,
    RestaurantName  varchar(30) NOT NULL,
    CuisineCategory varchar(20),
    Email           varchar(50),
    ContactNo       number(10) NOT NULL,
    Rating          number (3,2),
    PRIMARY KEY (RestaurantId)
);

create table Reviews
(
    RestaurantId      integer,
    CustomerId        integer,
    ReviewDescription varchar(500),
    Rating            number(3,2) NOT NULL,
    ReviewDate        date,
    PRIMARY KEY (RestaurantId, CustomerId),
    FOREIGN KEY (RestaurantId) REFERENCES Restaurant (RestaurantId) ON DELETE CASCADE,
    FOREIGN KEY (CustomerId) REFERENCES Customer (CustomerId) ON DELETE CASCADE
);

create table Image
(
    ImageReferenceId integer,
    ImageLocation    varchar(100),
    PRIMARY KEY (ImageReferenceId)
);

create table Food
(
    FoodId           integer,
    FoodName         varchar(20) NOT NULL,
    FoodDescription  varchar(100),
    Category         varchar(20),
    Options          varchar(10),
    Price            number(8,2) NOT NULL,
    Calorie          integer,
    ImageReferenceId integer,
    RestaurantId     integer,
    PRIMARY KEY (FoodId),
    FOREIGN KEY (RestaurantId) REFERENCES Restaurant (RestaurantId) ON DELETE CASCADE,
    FOREIGN KEY (ImageReferenceId) REFERENCES Image (ImageReferenceId) ON DELETE CASCADE
);

create table OrderDetails
(
    OrderId            integer,
    OrderDate          date NOT NULL,
    OrderTime          timestamp NOT NULL,
    OrderContactNumber number(10) NOT NULL,
    Price              number(10,2) NOT NULL,
    Tax                number(10,3) DEFAULT 8.025,
    PromoCode          varchar(30) DEFAULT NULL,
    PRIMARY KEY (OrderId)
);

Create Table OrderPickUp
(
    OrderId    integer,
    CustomerId integer,
    PRIMARY KEY (OrderId, CustomerId),
    FOREIGN KEY (CustomerId) REFERENCES Customer (CustomerId) ON DELETE CASCADE,
    FOREIGN KEY (OrderId) REFERENCES OrderDetails (OrderId) ON DELETE CASCADE
);

create table DoorDasher
(
    SSN               char(9),
    DasherName        varchar(40) NOT NULL,
    DrivingLicenseId  integer NOT NULL,
    Email             varchar(50),
    ContactNumber     number(10) NOT NULL,
    Rating            number(3,2),
    OrdersFulfilled   integer DEFAULT 0,
    BankAccountNumber number(20) NOT NULL,
    PRIMARY KEY (SSN)
);

Create Table OrderDelivery
(
    OrderId           integer,
    DeliveryFee       number(6,2),
    DeliveryStatus    number(1) DEFAULT 0,
    DeliveryTip       number(6,2),
    DeliveryAddressId integer NOT NULL,
    DoorDasherSSN     char(9),
    PRIMARY KEY (OrderId),
    FOREIGN KEY (DeliveryAddressId) REFERENCES Address (AddressId),
    FOREIGN KEY (OrderId) REFERENCES OrderDetails (OrderId) ON DELETE CASCADE,
    FOREIGN KEY (DoorDasherSSN) REFERENCES DoorDasher (SSN) ON DELETE CASCADE
);

create table Payment
(
    PaymentId  integer,
    CustomerId integer,
    PRIMARY KEY (PaymentId),
    FOREIGN KEY (CustomerId) REFERENCES Customer (CustomerId) ON DELETE CASCADE
);

create table CardDetails
(
    CardNo      number(16),
    CVC         number(3) NOT NULL,
    ExpiryMonth varchar(3) NOT NULL,
    ExpiryYear  number(4) NOT NULL,
    PRIMARY KEY (CardNo)
);

create table Card
(
    PaymentId integer,
    CardNo    number(16) NOT NULL,
    PRIMARY KEY (PaymentId),
    FOREIGN KEY (PaymentId) REFERENCES Payment (PaymentId) ON DELETE CASCADE,
    FOREIGN KEY (CardNo) REFERENCES CardDetails (CardNo) ON DELETE CASCADE
);

create table Venmo
(
    PaymentId integer,
    VenmoId   varchar(30) NOT NULL,
    PRIMARY KEY (PaymentId),
    FOREIGN KEY (PaymentId) REFERENCES Payment (PaymentId) ON DELETE CASCADE
);

create table Paypal
(
    PaymentId integer,
    PayPalId  varchar(30) NOT NULL,
    PRIMARY KEY (PaymentId),
    FOREIGN KEY (PaymentId) REFERENCES Payment (PaymentId) ON DELETE CASCADE
);


create table Transaction
(
    TId       integer,
    TStatus   number(1) NOT NULL,
    TDate     date,
    Ttime     timestamp,
    OrderId   integer,
    PaymentId integer,
    PRIMARY KEY (TId),
    FOREIGN KEY (PaymentId) REFERENCES Payment (PaymentId) ON DELETE CASCADE,
    FOREIGN KEY (OrderId) REFERENCES OrderDetails (OrderId) ON DELETE CASCADE
);


create table Offer
(
    OfferId            integer,
    DiscountAmount     number(4),
    DiscountPercentage number(3) DEFAULT 0.000,
    PRIMARY KEY (OfferId),
);

create table Vehicle
(
    VehiclePlateNo number(4),
    StateCode      varchar(5) NOT NULL,
    DasherSSN      char(9),
    VehicleType    varchar(10) DEFAULT 'Car',
    PRIMARY KEY (VehiclePlateNo),
    FOREIGN KEY (DasherSSN) references DoorDasher (SSN) ON DELETE CASCADE
);

create table FoodOrder
(
    FoodId  integer,
    OrderId integer,
    PRIMARY KEY (FoodId, OrderId),
    FOREIGN KEY (FoodId) references Food (FoodId) ON DELETE CASCADE,
    FOREIGN KEY (OrderId) REFERENCES OrderDetails (OrderId) ON DELETE CASCADE
);


-- In case need to start over
DROP TABLE FOODORDER;
DROP TABLE VEHICLE;
DROP TABLE OFFER;
DROP TABLE TRANSACTION;
DROP TABLE PAYPAL;
DROP TABLE VENMO;
DROP TABLE CARD;
DROP TABLE CARDDETAILS;
DROP TABLE PAYMENT;
DROP TABLE ORDERDELIVERY;
DROP TABLE DOORDASHER;
DROP TABLE ORDERPICKUP;
DROP TABLE ORDERDETAILS;
DROP TABLE FOOD;
DROP TABLE IMAGE;
DROP TABLE REVIEWS;
DROP TABLE RESTAURANT;
DROP TABLE ADDRESS;
DROP TABLE ZIPCODE;
DROP TABLE CUSTOMER;