#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / createdb.pl
#
############################################################################

require 'db.pl';

# use @state_array and @country_array to fill state and country tables
@state_array=(
'',
'Alabama','Alaska','Arizona','Arkansas','California','Colorado',
'Connecticut','Delaware','District of Columbia','Florida','Georgia',
'Guam','Hawaii','Idaho','Illinois','Indiana','Iowa','Kentucky',
'Louisiana','Maine','Maryland','Massachusetts', 'Michigan',
'Minnesota','Mississippi','Missouri','Montana','Nebraska',
'Nevada','New Hampshire','New Jersey','New Mexico','New York',
'North Carolina','North Dakota','Ohio','Oklahoma','Oregon',
'Pennsylvania','Puerto Rico','Rhode  Island','South Carolina',
'South Dakota','Tennessee','Texas','US Virgin Islands','Utah',
'Vermont','Virginia','Washington','West Virginia','Wisconsin',
'Wyoming');

@country_array=(
' -- Select Country -- ', 'United States',
'Albania','Algeria', 'American Samoa','Andorra','Angola','Anguilla',
'Anguilla','Argentina','Armenia','Aruba','Australia', 'Austria','Azerbaijan',
'Bahamas','Bahrain','Bangladesh', 'Barbados','Barbuda','Belarus','Belgium',
'Belize', 'Benin','Bermuda', 'Bhutan','Bolivia','Bonaire','Bosnia', 'Botswana',
'Brazil','Brunei','Bulgaria','Burkina Faso','Burundi','Cambodia', 'Cameroon',
'Canada','Cape Verde','Cayman Islands','Chad','Channel Islands','Chile','China',
'Colombia','Cook Islands','Costa Rica','Croatia','Curacao','Cyprus','Czech Republic',
'Denmark','Djibouti','Dominica','Dominican Republic','Ecuador','Egypt','El Salvador',
'Equatorial Guinea','Eritrea','Estonia','Ethiopia','Faroe Islands','Fiji','Finland',
'France','French Guiana','French Polynesia','Gabon','Gambia','Georgia','Germany',
'Ghana','Gibraltar','Greece','Greenland','Grenada','Guadeloupe','Guam','Guatemala',
'Guinea Bissau', 'Guinea','Guyana','Haiti','Honduras','Hong Kong', 'Hungary',
'Iceland','India','Indonesia','Iran', 'Iraq','Ireland','Israel','Italy','Ivory Coast',
'Jamaica','Japan','Jordan','Kazakhstan','Kenya','Korea, DPR (North)',
'Korea (South)','Kuwait','Kyrgyzstan','Latvia','Lebanon','Lesotho','Liberia',
'Libya','Liechtenstein','Lithuania','Luxembourg','Macau','Macedonia','Madagascar',
'Malawi','Malaysia','Mali','Malta','Marshall Islands','Martinique', 'Mauritania',
'Mauritius','Mexico','Micronesia','Moldova', 'Monaco','Mongolia', 'Montserrat',
'Morocco','Mozambique','Myanmar/Burma', 'Namibia','Nepal','Netherlands Antilles',
'Netherlands','New Caledonia','New Zealand','Nicaragua','Niger', 'Nigeria',
'Norway','Oman','Pakistan','Palau','Panama','Papua New Guinea','Paraguay','Peru',
'Philippines','Poland','Portugal','Puerto Rico','Qatar','Reunion', 'Romania',
'Russian Federation', 'Rwanda', 'Saba','Saipan','San Marino', 'Saudi Arabia',
'Senegal','Seychelles','Sierra Leone','Singapore','Slovak Republic','Slovenia',
'Somalia','South Africa','Spain','Sudan','Suriname','Swaziland','Sweden',
'Switzerland','Syria', 'Taiwan','Tanzania','Thailand','Togo','Tortola','Tunisia',
'Turkey','Turkmenistan','US Virgin Islands','Uganda','Ukraine','United Arab Emirates',
'United Kingdom','Uruguay','Uzbekistan','Vanuatu', 'Vatican City',
'Venezuela','Vietnam','Wallis & Futuna','Yemen', 'Zaire','Zambia','Zimbabwe');

my $message='';
print "Content-type: text/html\n\n";
print "<HTML><BODY BGCOLOR='white'>";
dbconnect();

# ATTENTION! Please comment function create() after the tables
# have been  created successfully to prevent their re-creating.


#dbdrop();
#dbcreate();

dbalter();

if ($message ne '') { print $message; }
else { print "<P><CENTER><B>Creating the tables have been executed succesfully!</B></CENTER>"; }

print "</TABLE></BODY></HTML>";

############################################################################
sub dbalter        #16.11.99 9:15
############################################################################
{


$sql="CREATE TABLE AccountType(
     Id INT NOT NULL AUTO_INCREMENT,
     Name char(50) not null,
     Status smallint(5) unsigned not null,
     Level smallint(5) unsigned not null,
     PRIMARY KEY(Id),
     INDEX(Status),
     INDEX(Level)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE Category(
     Id INT NOT NULL AUTO_INCREMENT,
     Name varchar(30) not null,
     GifFileOn varchar(30),
     GifFile varchar(30),
     Status smallint(5) unsigned not null,
     Description blob,
     PRIMARY KEY(Id),
     INDEX(Name),
     INDEX(Status)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE Country(
     Id INT NOT NULL AUTO_INCREMENT,
     Name char(50) not null,
     PRIMARY KEY(Id),
     INDEX(Name)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE CreditCard(
     Id INT NOT NULL AUTO_INCREMENT,
     Name varchar(30) not null,
     Status smallint(5) unsigned not null,
     Description blob,
     ConditionsOfSale blob,
     PRIMARY KEY(Id),
     INDEX(Name),
     INDEX(Status)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE Manufacturer(
     Id INT NOT NULL AUTO_INCREMENT,
     Name char(30) not null,
     Status smallint(5) unsigned not null,
     PRIMARY KEY(Id),
     INDEX(Name),
     INDEX(Status)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE OptionList(
     Id INT NOT NULL AUTO_INCREMENT,
     ProductId int(11) not null,
     OptionNumber varchar(30),
     OptionName varchar(250),
     OptionDescription blob,
     OptionPicture varchar(50),
     Price double(10,2) unsigned not null,
     Status int(11) not null,
     TypeOfAvailable smallint(6),
     PRIMARY KEY(Id),
     INDEX(ProductId)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE OrderList(
     Id INT NOT NULL AUTO_INCREMENT,
     code char(70) not null,
     ProductId int(11),
     ProductNumber char(30),
     ProductName char(250),
     OptionId int(11),
     OptionNumber char(30),
     OptionName char(250),
     Quantity int(10) unsigned not null,
     Price double(10,2) unsigned not null,
     TimeExpiration datetime,
     Trans int(11) not null,
     Status int(11) not null,
     PRIMARY KEY(Id),
     INDEX(code)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE OrderListCheck(
     Id INT NOT NULL AUTO_INCREMENT,
     code char(70) not null,
     IdProfile int(11) not null,
     PRIMARY KEY(Id),
     INDEX(code),
     INDEX(IdProfile)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE Passw(
     Id INT NOT NULL AUTO_INCREMENT,
     User char(20),
     Password char(20),
     Code char(50),
     Super int(11),
     PRIMARY KEY(Id)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE Product(
     Id INT NOT NULL AUTO_INCREMENT,
     StoreProductNumber varchar(30) not null,
     Category int(10) unsigned not null,
     Subcategory varchar(30) not null,
     StoreProductName varchar(250) not null,
     ManufacturerProductNumber varchar(30),
     ManufacturerName int(10) unsigned not null,
     ManufacturerProductName varchar(250),
     ProductShortDescription longblob,
     ProductSmallPicture varchar(100),
     ProductPicture varchar(100),
     Price double(10,2) unsigned not null,
     ProductDetailedDescription varchar(100),
     Status smallint(5) unsigned not null,
     Price2 double(10,2) unsigned not null,
     Price3 double(10,2) unsigned not null,
     ProductSpecialPicture varchar(30),
     SpecialBox int(11) not null,
     NewBox int(11) not null,
     TopBox int(11) not null,
     ProductTopPicture varchar(30),
     ProductNewPicture varchar(30),
     ProductDescription text,
     ProductSpecification text,
     ProductTechNotes text,
     PriceType smallint(6),
     TypeOfAvailable smallint(6),
     Bullet int(11),
     Quantity int(11),
     PRIMARY KEY(Id),
     INDEX(StoreProductNumber),
     INDEX(Category),
     INDEX(StoreProductName),
     INDEX(ManufacturerName),
     INDEX(Price),
     INDEX(Status)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE Profile(
     Id INT NOT NULL AUTO_INCREMENT,
     CustomerID varchar(20) not null,
     Password varchar(10) not null,
     CustShifr varchar(50),
     TimeExpirShifr datetime,
     FirstName varchar(40),
     LastName varchar(40),
     Email varchar(50) not null,
     Title varchar(50),
     CompanyName varchar(100) not null,
     StreetAddress varchar(100) not null,
     City varchar(50) not null,
     State varchar(30),
     Country varchar(30) not null,
     Phone varchar(30) not null,
     Fax varchar(30) not null,
     Zip varchar(10) not null,
     ShippingStreetAddress varchar(100) not null,
     ShippingCity varchar(50) not null,
     ShippingState varchar(30),
     ShippingCountry varchar(30) not null,
     ShippingPhone varchar(30) not null,
     ShippingFax varchar(30) not null,
     ShippingZip varchar(10) not null,
     TypeOfBusiness int(11),
     TypeOfBusinessSpecify varchar(100),
     CurProjShortDescription blob,
     BankReferences blob,
     TradeReferences blob,
     EstabDiscountLevel double(10,2) unsigned,
     PaymentTerms varchar(50),
     Status int(10) unsigned not null,
     Parent int(10) unsigned,
     DateCreate date,
     DateChange date,
     Perspect smallint(5) unsigned not null,
     Category varchar(100),
     Notes blob,
     Subscriber int(10) unsigned not null,
     PRIMARY KEY(Id),
     INDEX(CompanyName),
     INDEX(Status)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE Profile_Old(
     Id INT NOT NULL AUTO_INCREMENT,
     Id_Parent int(11) not null,
     CustomerID varchar(20) not null,
     Password varchar(10) not null,
     CustShifr varchar(50),
     TimeExpirShifr datetime,
     FirstName varchar(40),
     LastName varchar(40),
     Email varchar(50) not null,
     Title varchar(50),
     CompanyName varchar(100) not null,
     StreetAddress varchar(100) not null,
     City varchar(50) not null,
     State varchar(30),
     Country varchar(30) not null,
     Phone varchar(30) not null,
     Fax varchar(30) not null,
     Zip varchar(10) not null,
     ShippingStreetAddress varchar(100) not null,
     ShippingCity varchar(50) not null,
     ShippingState varchar(30),
     ShippingCountry varchar(30) not null,
     ShippingPhone varchar(30) not null,
     ShippingFax varchar(30) not null,
     ShippingZip varchar(10) not null,
     TypeOfBusiness int(11),
     TypeOfBusinessSpecify varchar(100),
     CurProjShortDescription blob,
     BankReferences blob,
     TradeReferences blob,
     EstabDiscountLevel double(10,2) unsigned,
     PaymentTerms varchar(50),
     Status int(10) unsigned not null,
     DateCreate date,
     Perspect smallint(5) unsigned not null,
     Category varchar(100),
     Notes blob,
     Subscriber int(10) unsigned not null,
     PRIMARY KEY(Id),
     INDEX(Id_Parent),
     INDEX(Status)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE Setup(
     NameStore char(25),
     NameDirector char(25),
     Address char(50),
     City char(30),
     State char(30),
     Country char(15),
     Zip char(10),
     Phone char(30),
     Fax char(30),
     Emailstore char(30),
     Emailstore2 char(30)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE State(
     Id INT NOT NULL AUTO_INCREMENT,
     Name char(50) not null,
     PRIMARY KEY(Id),
     INDEX(Name)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE SubAccountType(
     Id INT NOT NULL AUTO_INCREMENT,
     AccountType int(10) unsigned not null,
     CreditCard int(10) unsigned not null,
     Status smallint(5) unsigned not null,
     PRIMARY KEY(Id),
     INDEX(AccountType),
     INDEX(CreditCard),
     INDEX(Status)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE Subcategory(
     Id INT NOT NULL AUTO_INCREMENT,
     Name varchar(50) not null,
     Category int(10) unsigned,
     Status smallint(5) unsigned not null,
     Description blob,
     PRIMARY KEY(Id),
     INDEX(Name)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE TransOrder(
     Id INT NOT NULL AUTO_INCREMENT,
     Transactions int(10) unsigned not null,
     Product int(10) unsigned not null,
     Quantity smallint(5) unsigned not null,
     Price double(10,2) unsigned not null,
     SalesTax double(10,2) unsigned,
     PRIMARY KEY(Id),
     INDEX(Transactions),
     INDEX(Product)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE Transactions(
     Id INT NOT NULL AUTO_INCREMENT,
     Profile int(10) unsigned not null,
     PurchasingOrderNumber char(20),
     StoreOrderNumber char(10),
     FirstName char(40),
     LastName char(40),
     Email char(50) not null,
     Title char(50),
     CompanyName char(100) not null,
     StreetAddress char(100) not null,
     City char(50) not null,
     State char(30),
     Country char(30) not null,
     Phone char(30) not null,
     Fax char(30) not null,
     Zip char(10) not null,
     ShippingStreetAddress char(100) not null,
     ShippingCity char(50) not null,
     ShippingState char(30),
     ShippingCountry char(30) not null,
     ShippingPhone char(30) not null,
     ShippingFax char(30),
     ShippingZip char(10) not null,
     EstabDiscountLevel double(10,2) unsigned,
     CreditCard char(30) not null,
     DatePurchased date not null,
     DateShipped date,
     ShippedVia char(250),
     TrackingNumber char(250),
     DatePaymentDue date,
     DatePaymentReceived date,
     CreditCardType char(20),
     CreditCardNumber char(30),
     ExpirationMonth char(2),
     ExpirationYear char(2),
     SecurityCode char(30),
     NameOnCard char(150),
     code char(70) not null,
     Status int(10) unsigned not null,
     PRIMARY KEY(Id),
     INDEX(Profile),
     INDEX(Status)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE TypeOfAvailable(
     Id INT NOT NULL AUTO_INCREMENT,
     Name char(30) not null,
     Status smallint(5) unsigned not null,
     PRIMARY KEY(Id),
     INDEX(Name),
     INDEX(Status)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE TypeOfBusiness(
     Id INT NOT NULL AUTO_INCREMENT,
     Name char(50) not null,
     Status smallint(5) unsigned not null,
     PRIMARY KEY(Id),
     INDEX(Name),
     INDEX(Status)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE WishList(
     Id INT NOT NULL AUTO_INCREMENT,
     code char(70) not null,
     ProductId int(11),
     ProductNumber char(30),
     ProductName char(250),
     OptionId int(11),
     OptionNumber char(30),
     OptionName char(250),
     Quantity int(10) unsigned not null,
     Price double(10,2) unsigned not null,
     TimeExpiration datetime,
     Profile int(11) not null,
     Status int(11) not null,
     PRIMARY KEY(Id),
     INDEX(code)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE test(
     id INT NOT NULL AUTO_INCREMENT,
     name char(30),
     PRIMARY KEY(Id)
)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\AccountType.txt' from AccountType";
$sql="LOAD DATA INFILE 'D:\\AccountType.txt' INTO TABLE AccountType";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\Category.txt' from Category";
$sql="LOAD DATA INFILE 'D:\\Category.txt' INTO TABLE Category";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\Country.txt' from Country";
$sql="LOAD DATA INFILE 'D:\\Country.txt' INTO TABLE Country";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\CreditCard.txt' from CreditCard";
$sql="LOAD DATA INFILE 'D:\\CreditCard.txt' INTO TABLE CreditCard";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\Manufacturer.txt' from Manufacturer";
$sql="LOAD DATA INFILE 'D:\\Manufacturer.txt' INTO TABLE Manufacturer";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\OptionList.txt' from OptionList";
$sql="LOAD DATA INFILE 'D:\\OptionList.txt' INTO TABLE OptionList";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\OrderList.txt' from OrderList";
$sql="LOAD DATA INFILE 'D:\\OrderList.txt' INTO TABLE OrderList";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\OrderListCheck.txt' from OrderListCheck";
$sql="LOAD DATA INFILE 'D:\\OrderListCheck.txt' INTO TABLE OrderListCheck";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\Passw.txt' from Passw";
$sql="LOAD DATA INFILE 'D:\\Passw.txt' INTO TABLE Passw";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\Product.txt' from Product";
$sql="LOAD DATA INFILE 'D:\\Product.txt' INTO TABLE Product";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\Profile.txt' from Profile";
$sql="LOAD DATA INFILE 'D:\\Profile.txt' INTO TABLE Profile";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\Profile_Old.txt' from Profile_Old";
$sql="LOAD DATA INFILE 'D:\\Profile_Old.txt' INTO TABLE Profile_Old";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\Setup.txt' from Setup";
$sql="LOAD DATA INFILE 'D:\\Setup.txt' INTO TABLE Setup";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\State.txt' from State";
$sql="LOAD DATA INFILE 'D:\\State.txt' INTO TABLE State";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\SubAccountType.txt' from SubAccountType";
$sql="LOAD DATA INFILE 'D:\\SubAccountType.txt' INTO TABLE SubAccountType";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\Subcategory.txt' from Subcategory";
$sql="LOAD DATA INFILE 'D:\\Subcategory.txt' INTO TABLE Subcategory";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\TransOrder.txt' from TransOrder";
$sql="LOAD DATA INFILE 'D:\\TransOrder.txt' INTO TABLE TransOrder";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\Transactions.txt' from Transactions";
$sql="LOAD DATA INFILE 'D:\\Transactions.txt' INTO TABLE Transactions";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\TypeOfAvailable.txt' from TypeOfAvailable";
$sql="LOAD DATA INFILE 'D:\\TypeOfAvailable.txt' INTO TABLE TypeOfAvailable";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\TypeOfBusiness.txt' from TypeOfBusiness";
$sql="LOAD DATA INFILE 'D:\\TypeOfBusiness.txt' INTO TABLE TypeOfBusiness";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\WishList.txt' from WishList";
$sql="LOAD DATA INFILE 'D:\\WishList.txt' INTO TABLE WishList";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


#$sql="SELECT * INTO OUTFILE 'D:\\test.txt' from test";
$sql="LOAD DATA INFILE 'D:\\test.txt' INTO TABLE test";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";




}




############################################################################
sub dbalter2        #16.11.99 9:15
############################################################################
{


$sql="DELETE FROM AccountType WHERE Id > 3";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="UPDATE Profile SET Perspect=0";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";

$sql="UPDATE Profile_Old SET Perspect=0";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="ALTER TABLE Product
         add Quantity INT";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";

$sql="UPDATE Product SET Quantity=0";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="ALTER TABLE Product
         add Bullet INT";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";

$sql="UPDATE Product SET Bullet=Id";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";




$sql="ALTER TABLE OptionList
         add TypeOfAvailable SMALLINT";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";

$sql="UPDATE OptionList SET TypeOfAvailable=3";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="UPDATE Product SET TypeOfAvailable=3";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE TypeOfAvailable(
             Id INT NOT NULL AUTO_INCREMENT,
             Name CHAR(30) NOT NULL,
             Status SMALLINT UNSIGNED NOT NULL,# 0-alive,1-dead
             PRIMARY KEY(Id),
             INDEX(Name),
             INDEX(Status)
            )";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="ALTER TABLE Product
         add TypeOfAvailable SMALLINT";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="ALTER TABLE Transactions
      CHANGE  ShippedVia ShippedVia CHAR(250)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="UPDATE Product SET Subcategory=0 WHERE Subcategory=1";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="ALTER TABLE Product
         add PriceType SMALLINT";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";

$sql="UPDATE Product SET PriceType=1";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="ALTER TABLE Product
           CHANGE StoreProductNumber StoreProductNumber CHAR(30) NOT NULL,
           CHANGE StoreProductName StoreProductName CHAR(250) NOT NULL,
           CHANGE ManufacturerProductNumber ManufacturerProductNumber CHAR(30),
           CHANGE ManufacturerProductName ManufacturerProductName CHAR(250),
           CHANGE ProductSmallPicture ProductSmallPicture CHAR(100),
           CHANGE ProductPicture  ProductPicture CHAR(100),
           CHANGE ProductDetailedDescription ProductDetailedDescription CHAR(100)
";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="ALTER TABLE OptionList
          CHANGE OptionPicture OptionPicture CHAR(50)
";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



#$sql="ALTER TABLE Category
#       add Description BLOB";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";

#$sql="ALTER TABLE Subcategory
#       add Description BLOB";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="CREATE TABLE Profile_Old (
             Id INT NOT NULL AUTO_INCREMENT,
             Id_Parent integer NOT NULL,
             CustomerID CHAR(20) NOT NULL,
             Password CHAR(10) NOT NULL,
             CustShifr CHAR(50),      # for Profile
             TimeExpirShifr DATETIME, # for Profile
             FirstName CHAR(40),
             LastName CHAR(40),
             Email CHAR(50) NOT NULL,
             Title CHAR(50),
             CompanyName CHAR(100) NOT NULL,
             StreetAddress CHAR(100) NOT NULL,
             City CHAR(50) NOT NULL,
             State CHAR(30) ,
             Country CHAR(30) NOT NULL,
             Phone CHAR(30) NOT NULL,
             Fax CHAR(30) NOT NULL,
             Zip CHAR(10) NOT NULL,

             ShippingStreetAddress CHAR(100) NOT NULL,
             ShippingCity CHAR(50) NOT NULL,
             ShippingState CHAR(30) ,
             ShippingCountry CHAR(30) NOT NULL,
             ShippingPhone CHAR(30) NOT NULL,
             ShippingFax CHAR(30) NOT NULL,
             ShippingZip CHAR(10) NOT NULL,

             TypeOfBusiness INT ,# link to table TypeOfBusiness
             TypeOfBusinessSpecify CHAR(100),
             CurProjShortDescription CHAR(200) ,
             BankReferences CHAR(250),
             TradeReferences CHAR(250),
             EstabDiscountLevel DOUBLE(10,2) UNSIGNED,
             PaymentTerms CHAR(50) , # link to CreditCard
             Status integer unsigned NOT NULL, # 0-alive,1-dead, 2- has parent
             DateCreate DATE,
             Perspect SMALLINT UNSIGNED NOT NULL, # 0-perspective,1-cusomer, 2-competitor
             Category char(100), # Category of Products interested in
             Notes blob,
             PRIMARY KEY(Id),
             INDEX(Id_Parent),
             INDEX(Status)
            )";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="ALTER TABLE Product
         add Price2 DOUBLE(10,2) UNSIGNED NOT NULL,
         add Price3 DOUBLE(10,2) UNSIGNED NOT NULL
";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="DROP TABLE Setup";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE Setup(
           NameStore CHAR(25),
           NameDirector CHAR(25),
           Address CHAR(50),
           City CHAR(30),
           State CHAR(30),
           Country CHAR(15),
           Zip CHAR(10),
           Phone CHAR(30),
           Fax CHAR(30),
           Emailstore CHAR(30),
           Emailstore2 CHAR(30) # second email 
         )";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="INSERT INTO Setup (NameStore,Emailstore,Fax) VALUES ('Bip','bapbgin\@usa.net' ,'375-232-50-45-71')";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="ALTER TABLE Profile
         add Subscriber INT UNSIGNED NOT NULL";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";

$sql="ALTER TABLE Profile_Old
         add Subscriber INT UNSIGNED NOT NULL";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="ALTER TABLE CreditCard
       add Description BLOB";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";






$sql="ALTER TABLE Product
         add ProductSpecialPicture CHAR(30)";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


 

$sql="CREATE TABLE AccountType(
             Id INT NOT NULL AUTO_INCREMENT,
             Name CHAR(50) NOT NULL,
             Status SMALLINT UNSIGNED NOT NULL,# 0-alive,1-dead
             Level SMALLINT UNSIGNED NOT NULL,
             PRIMARY KEY(Id),
             INDEX(Level),
             INDEX(Status)
            )";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";




$sql="CREATE TABLE SubAccountType(
             Id INT NOT NULL AUTO_INCREMENT,
             AccountType INT UNSIGNED NOT NULL,
             CreditCard INT UNSIGNED NOT NULL,
             Status SMALLINT UNSIGNED NOT NULL,# 0-alive,1-dead
             PRIMARY KEY(Id),
             INDEX(AccountType),
             INDEX(CreditCard),
             INDEX(Status)
            )";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="ALTER TABLE CreditCard
       DROP COLUMN FileName1,
       DROP COLUMN FileName2,
       ADD  ConditionsOfSale BLOB";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";





$sql="DROP TABLE Transactions";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE Transactions (
             Id INT NOT NULL AUTO_INCREMENT,
             Profile INT UNSIGNED NOT NULL, #link to table Profile
             PurchasingOrderNumber CHAR(20),
             StoreOrderNumber CHAR(10),


             FirstName CHAR(40),
             LastName CHAR(40),
             Email CHAR(50) NOT NULL,
             Title CHAR(50),
             CompanyName CHAR(100) NOT NULL,
             StreetAddress CHAR(100) NOT NULL,
             City CHAR(50) NOT NULL,
             State CHAR(30),
             Country CHAR(30) NOT NULL,
             Phone CHAR(30) NOT NULL,
             Fax CHAR(30) NOT NULL,
             Zip CHAR(10) NOT NULL,


             # Shipping Address
             ShippingStreetAddress CHAR(100) NOT NULL,
             ShippingCity CHAR(50) NOT NULL,
             ShippingState CHAR(30),
             ShippingCountry CHAR(30) NOT NULL,
             ShippingPhone CHAR(30) NOT NULL,
             ShippingFax CHAR(30) ,
             ShippingZip CHAR(10) NOT NULL,

             EstabDiscountLevel DOUBLE(10,2) UNSIGNED,
             CreditCard CHAR(30) NOT NULL,
             DatePurchased DATE NOT NULL,

             DateShipped DATE,
             ShippedVia CHAR(50),
             TrackingNumber CHAR (250),
             DatePaymentDue DATE,
             DatePaymentReceived DATE,

             CreditCardType CHAR(20),
             CreditCardNumber CHAR(30),
             ExpirationMonth CHAR(2),
             ExpirationYear CHAR(2),
             SecurityCode CHAR(30),
             NameOnCard CHAR(150),

             code CHAR(70) NOT NULL,
             Status integer unsigned NOT NULL, # 0-alive,1-dead
             PRIMARY KEY(Id),
             INDEX(Profile),
             INDEX(Status)
            )";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";





$sql="DROP TABLE OptionList";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE OptionList(
          Id INT NOT NULL AUTO_INCREMENT,
          ProductId INT NOT NULL,
          OptionNumber CHAR(30),
          OptionName CHAR(250),
          OptionDescription BLOB,
          OptionPicture CHAR(50),
          Price DOUBLE(10,2) UNSIGNED NOT NULL,
          Status INT NOT NULL,
          PRIMARY KEY(Id),
          INDEX(ProductId)
         )";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="DROP TABLE OrderList";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE OrderList(
          Id INT NOT NULL AUTO_INCREMENT,
          code CHAR(70) NOT NULL,
          ProductId INT,
          ProductNumber CHAR(30),
          ProductName CHAR(250),
          OptionId INT,
          OptionNumber CHAR(30),
          OptionName CHAR(250),
          Quantity INT UNSIGNED NOT NULL,
          Price DOUBLE(10,2) UNSIGNED NOT NULL,
          TimeExpiration DATETIME,  
          Trans INT NOT NULL,
          Status INT NOT NULL,
          PRIMARY KEY(Id),
          INDEX(code)
         )";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="DROP TABLE WishList";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE WishList(
          Id INT NOT NULL AUTO_INCREMENT,
          code CHAR(70) NOT NULL,
          ProductId INT,
          ProductNumber CHAR(30),
          ProductName CHAR(250),
          OptionId INT,
          OptionNumber CHAR(30),
          OptionName CHAR(250),
          Quantity INT UNSIGNED NOT NULL,
          Price DOUBLE(10,2) UNSIGNED NOT NULL,
          TimeExpiration DATETIME,  
          Profile INT NOT NULL,
          Status INT NOT NULL,
          PRIMARY KEY(Id),
          INDEX(code)
         )";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="ALTER TABLE Product

         drop column OptionName1 ,
         drop column OptionName2 ,
         drop column OptionName3 ,
         drop column OptionName4 ,
         drop column OptionName5 ,
         drop column OptionName6 ,
         drop column OptionName7 ,
         drop column OptionName8 ,
         drop column OptionName9 ,
         drop column OptionName10 ,
         drop column OptionName11 ,
         drop column OptionName12 ,
         drop column OptionName13 ,
         drop column OptionName14 ,
         drop column OptionName15 ,

         drop column OptionDescription1 ,
         drop column OptionDescription2 ,
         drop column OptionDescription3 ,
         drop column OptionDescription4 ,
         drop column OptionDescription5 ,
         drop column OptionDescription6 ,
         drop column OptionDescription7 ,
         drop column OptionDescription8 ,
         drop column OptionDescription9 ,
         drop column OptionDescription10 ,
         drop column OptionDescription11 ,
         drop column OptionDescription12 ,
         drop column OptionDescription13 ,
         drop column OptionDescription14 ,
         drop column OptionDescription15 ,

         drop column OptionPrice1 ,
         drop column OptionPrice2 ,
         drop column OptionPrice3 ,
         drop column OptionPrice4 ,
         drop column OptionPrice5 ,
         drop column OptionPrice6 ,
         drop column OptionPrice7 ,
         drop column OptionPrice8 ,
         drop column OptionPrice9 ,
         drop column OptionPrice10 ,
         drop column OptionPrice11 ,
         drop column OptionPrice12 ,
         drop column OptionPrice13 ,
         drop column OptionPrice14 ,
         drop column  OptionPrice15

";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";





$sql="ALTER TABLE Product
         add SpecialBox INT NOT NULL,
         add NewBox INT NOT NULL,
         add TopBox INT NOT NULL,
         add ProductTopPicture CHAR(30),
         add ProductNewPicture CHAR(30)";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="UPDATE Product SET SpecialBox = 1, NewBox = 1, TopBox = 1";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";




$sql="ALTER TABLE Product
         drop column ProductDescription,
         add ProductDescription TEXT,
         add ProductSpecification TEXT,
         add ProductTechNotes TEXT
";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="ALTER TABLE Product
         drop column ProductDescription,
         add ProductDescription TEXT,
         add ProductSpecification TEXT,
         add ProductTechNotes TEXT
";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="DROP TABLE WishList";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE WishList(
          Id INT NOT NULL AUTO_INCREMENT,
          code CHAR(70) NOT NULL,
          ProductId INT,
          ProductNumber CHAR(30),
          ProductName CHAR(250),
          OptionId INT,
          OptionNumber CHAR(30),
          OptionName CHAR(250),
          Quantity INT UNSIGNED NOT NULL,
          Price DOUBLE(10,2) UNSIGNED NOT NULL,
          TimeExpiration DATETIME,  
          Profile INT NOT NULL,
          Status INT NOT NULL,
          PRIMARY KEY(Id),
          INDEX(code)
         )";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";






}




############################################################################
sub dbdrop        #16.11.99 9:15
############################################################################
{



# Use DROP TABLE if one or several tables have
# not been created in order to create them again

$sql="DROP TABLE CreditCard";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";
$sql="DROP TABLE Category";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";
$sql="DROP TABLE Subcategory";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";
$sql="DROP TABLE Manufacturer";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";
$sql="DROP TABLE TypeOfBusiness";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="DROP TABLE Product";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";

$sql="DROP TABLE Setup";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";
$sql="DROP TABLE Passw";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="DROP TABLE Profile";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";
$sql="DROP TABLE Profile_Old";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="DROP TABLE Transactions";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";
$sql="DROP TABLE OrderList";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";

$sql="DROP TABLE Country";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";
$sql="DROP TABLE State";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



}

############################################################################
sub dbcreate        #16.11.99 9:15
############################################################################
{

$sql="CREATE TABLE Product(
             Id INT NOT NULL AUTO_INCREMENT,
             StoreProductNumber CHAR(12) NOT NULL,
             Category INT UNSIGNED NOT NULL,#link to table Category
             Subcategory CHAR(30) NOT NULL,
             StoreProductName CHAR(100) NOT NULL,
             ManufacturerProductNumber CHAR(12),
             ManufacturerName INT UNSIGNED NOT NULL,#link to table Manufacturer
             ManufacturerProductName CHAR(100),
             ProductShortDescription LONGBLOB,
             ProductSmallPicture CHAR(30),
             ProductDescription CHAR(30),
             ProductPicture CHAR(30),
             Price DOUBLE(10,2) UNSIGNED NOT NULL,
             Price2 DOUBLE(10,2) UNSIGNED NOT NULL,
             Price3 DOUBLE(10,2) UNSIGNED NOT NULL,
             ProductDetailedDescription CHAR(30),
             Status SMALLINT UNSIGNED NOT NULL,# 0-alive,1-dead

             OptionName1 CHAR(20),
             OptionName2 CHAR(20),
             OptionName3 CHAR(20),
             OptionName4 CHAR(20),
             OptionName5 CHAR(20),
             OptionName6 CHAR(20),
             OptionName7 CHAR(20),
             OptionName8 CHAR(20),
             OptionName9 CHAR(20),
             OptionName10 CHAR(20),
             OptionName11 CHAR(20),
             OptionName12 CHAR(20),
             OptionName13 CHAR(20),
             OptionName14 CHAR(20),
             OptionName15 CHAR(20),

             OptionDescription1 CHAR(250),
             OptionDescription2 CHAR(250),
             OptionDescription3 CHAR(250),
             OptionDescription4 CHAR(250),
             OptionDescription5 CHAR(250),
             OptionDescription6 CHAR(250),
             OptionDescription7 CHAR(250),
             OptionDescription8 CHAR(250),
             OptionDescription9 CHAR(250),
             OptionDescription10 CHAR(250),
             OptionDescription11 CHAR(250),
             OptionDescription12 CHAR(250),
             OptionDescription13 CHAR(250),
             OptionDescription14 CHAR(250),
             OptionDescription15 CHAR(250),

             OptionPrice1 DOUBLE(10,2),
             OptionPrice2 DOUBLE(10,2),
             OptionPrice3 DOUBLE(10,2),
             OptionPrice4 DOUBLE(10,2),
             OptionPrice5 DOUBLE(10,2),
             OptionPrice6 DOUBLE(10,2),
             OptionPrice7 DOUBLE(10,2),
             OptionPrice8 DOUBLE(10,2),
             OptionPrice9 DOUBLE(10,2),

             OptionPrice10 DOUBLE(10,2),
             OptionPrice11 DOUBLE(10,2),
             OptionPrice12 DOUBLE(10,2),
             OptionPrice13 DOUBLE(10,2),
             OptionPrice14 DOUBLE(10,2),
             OptionPrice15 DOUBLE(10,2),

             PRIMARY KEY(Id),
             INDEX(StoreProductNumber),
             INDEX(Category),
             INDEX(StoreProductName),
             INDEX( ManufacturerName ),
             INDEX(Status)
            )";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="CREATE TABLE Profile (
             Id INT NOT NULL AUTO_INCREMENT,
             CustomerID CHAR(20) NOT NULL,
             Password CHAR(10) NOT NULL,
             CustShifr CHAR(50) NOT NULL,      # for Profile
             TimeExpirShifr DATETIME,          # for Profile
             FirstName CHAR(40),
             LastName CHAR(40),
             Email CHAR(50) NOT NULL,
             Title CHAR(50),
             CompanyName CHAR(100) NOT NULL,
             StreetAddress CHAR(100) NOT NULL,
             City CHAR(50) NOT NULL,
             State CHAR(30) NOT NULL,
             Country CHAR(30) NOT NULL,
             Phone CHAR(30) NOT NULL,
             Fax CHAR(30) NOT NULL,
             Zip CHAR(10) NOT NULL,

             ShippingStreetAddress CHAR(100) NOT NULL,
             ShippingCity CHAR(50) NOT NULL,
             ShippingState CHAR(30) NOT NULL,
             ShippingCountry CHAR(30) NOT NULL,
             ShippingPhone CHAR(30) NOT NULL,
             ShippingFax CHAR(30) NOT NULL,
             ShippingZip CHAR(10) NOT NULL,

             TypeOfBusiness INT ,# link to table TypeOfBusiness
             TypeOfBusinessSpecify CHAR(100),
             CurProjShortDescription CHAR(200) ,
             BankReferences CHAR(250),
             TradeReferences CHAR(250),
             EstabDiscountLevel DOUBLE(10,2) UNSIGNED,
             PaymentTerms CHAR(50) NOT NULL , # link to CreditCard
             Status integer unsigned NOT NULL, # 0-alive,1-dead, 2- has parent
             DateCreate DATE,
             Perspect SMALLINT UNSIGNED NOT NULL, # 0-perspective,1-cusomer, 2-competitor
             Category char(100), # Category of Products interested in
             Notes blob,
             PRIMARY KEY(Id),
             INDEX(CustShifr),
             INDEX(CustomerID),
             INDEX(Password),
             INDEX(State),
             INDEX(Country),
             INDEX(ShippingState),
             INDEX(ShippingCountry),
             INDEX(PaymentTerms),
             INDEX(Status)
            )";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="CREATE TABLE Profile_Old (
             Id INT NOT NULL AUTO_INCREMENT,
             Id_Parent integer NOT NULL,
             CustomerID CHAR(20) NOT NULL,
             Password CHAR(10) NOT NULL,
             CustShifr CHAR(50),      # for Profile
             TimeExpirShifr DATETIME, # for Profile
             FirstName CHAR(40),
             LastName CHAR(40),
             Email CHAR(50) NOT NULL,
             Title CHAR(50),
             CompanyName CHAR(100) NOT NULL,
             StreetAddress CHAR(100) NOT NULL,
             City CHAR(50) NOT NULL,
             State CHAR(30) ,
             Country CHAR(30) NOT NULL,
             Phone CHAR(30) NOT NULL,
             Fax CHAR(30) NOT NULL,
             Zip CHAR(10) NOT NULL,

             ShippingStreetAddress CHAR(100) NOT NULL,
             ShippingCity CHAR(50) NOT NULL,
             ShippingState CHAR(30) ,
             ShippingCountry CHAR(30) NOT NULL,
             ShippingPhone CHAR(30) NOT NULL,
             ShippingFax CHAR(30) NOT NULL,
             ShippingZip CHAR(10) NOT NULL,

             TypeOfBusiness INT ,# link to table TypeOfBusiness
             TypeOfBusinessSpecify CHAR(100),
             CurProjShortDescription CHAR(200) ,
             BankReferences CHAR(250),
             TradeReferences CHAR(250),
             EstabDiscountLevel DOUBLE(10,2) UNSIGNED,
             PaymentTerms CHAR(50) , # link to CreditCard
             Status integer unsigned NOT NULL, # 0-alive,1-dead, 2- has parent
             DateCreate DATE,
             Perspect SMALLINT UNSIGNED NOT NULL, # 0-perspective,1-cusomer, 2-competitor
             Category char(100), # Category of Products interested in
             Notes blob,
             PRIMARY KEY(Id),
             INDEX(Id_Parent),
             INDEX(Status)
            )";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE Transactions (
             Id INT NOT NULL AUTO_INCREMENT,
             Profile INT UNSIGNED NOT NULL, #link to table Profile
             PurchasingOrderNumber CHAR(20),
             StoreOrderNumber CHAR(10),


             FirstName CHAR(40),
             LastName CHAR(40),
             Email CHAR(50) NOT NULL,
             CompanyName CHAR(100) NOT NULL,
             StreetAddress CHAR(100) NOT NULL,
             City CHAR(50) NOT NULL,
             State CHAR(30),
             Country CHAR(30) NOT NULL,
             Phone CHAR(30) NOT NULL,
             Fax CHAR(30) NOT NULL,
             Zip CHAR(10) NOT NULL,


             # Shipping Address
             ShippingStreetAddress CHAR(100) NOT NULL,
             ShippingCity CHAR(50) NOT NULL,
             ShippingState CHAR(30),
             ShippingCountry CHAR(30) NOT NULL,
             ShippingPhone CHAR(30) NOT NULL,
             ShippingFax CHAR(30) ,
             ShippingZip CHAR(10) NOT NULL,

             EstabDiscountLevel DOUBLE(10,2) UNSIGNED,
             CreditCard integer NOT NULL,
             DatePurchased DATE NOT NULL,

             DateShipped DATE,
             ShippedVia CHAR(30),
             DatePaymentDue DATE,
             DatePaymentReceived DATE,

             code CHAR(70) NOT NULL,
             Status integer unsigned NOT NULL, # 0-alive,1-dead
             PRIMARY KEY(Id),
             INDEX(Profile),
             INDEX(Status)
            )";
 dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="CREATE TABLE OrderList(
          Id INT NOT NULL AUTO_INCREMENT,
          code CHAR(70) NOT NULL,
          Product CHAR(250),
          ProductOption TEXT,
          Quantity INT UNSIGNED NOT NULL,
          Price DOUBLE(10,2) UNSIGNED NOT NULL,
          Trans INT NOT NULL,
          PRIMARY KEY(Id),
          INDEX(code)
         )";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="CREATE TABLE Category(
             Id INT NOT NULL AUTO_INCREMENT,
             Name CHAR(50) NOT NULL,
             GifFileOn CHAR(30) , # NOT USED
             GifFile CHAR(30) ,   # NOT USED
             GifFileAct CHAR(30), # NOT USED
             Status SMALLINT UNSIGNED NOT NULL,# 0-alive,1-dead
             Description BLOB,
             PRIMARY KEY(Id),
             INDEX(Name),
             INDEX(Status)
            )";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE Subcategory(
             Id INT NOT NULL AUTO_INCREMENT,
             Name CHAR(50) NOT NULL,
             Category INT UNSIGNED,
             Status SMALLINT UNSIGNED NOT NULL,# 0-alive,1-dead
             Description BLOB,
             PRIMARY KEY(Id),
             INDEX(Name)
            )";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";

$sql= "INSERT INTO Subcategory (Name,Category,Status) VALUES('UNSELECTED',0,0)";
dbdo($sql);




$sql="CREATE TABLE Manufacturer(
             Id INT NOT NULL AUTO_INCREMENT,
             Name CHAR(30) NOT NULL,
             Status SMALLINT UNSIGNED NOT NULL,# 0-alive,1-dead
             PRIMARY KEY(Id),
             INDEX(Name),
             INDEX(Status)
            )";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="CREATE TABLE TypeOfBusiness(
             Id INT NOT NULL AUTO_INCREMENT,
             Name CHAR(50) NOT NULL,
             Status SMALLINT UNSIGNED NOT NULL,# 0-alive,1-dead
             PRIMARY KEY(Id),
             INDEX(Name),
             INDEX(Status)
            )";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="CREATE TABLE CreditCard(
             Id INT NOT NULL AUTO_INCREMENT,
             Name CHAR(30) NOT NULL,
             Status SMALLINT UNSIGNED NOT NULL,# 0-alive,1-dead
             PRIMARY KEY(Id),
             INDEX(Name),
             INDEX(Status)
            )";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="CREATE TABLE Country(
             Id INT NOT NULL AUTO_INCREMENT,
             Name CHAR(50) NOT NULL,
             PRIMARY KEY(Id),
             INDEX(Name)
            )";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";

foreach $country_array(@country_array) {
  $sql= "INSERT INTO Country (Name) VALUES('$country_array')";  dbdo($sql);
}



$sql="CREATE TABLE State(
             Id INT NOT NULL AUTO_INCREMENT,
             Name CHAR(50) NOT NULL,
             PRIMARY KEY(Id),
             INDEX(Name)
            )";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";

foreach $state_array(@state_array) {
  $sql= "INSERT INTO State (Name) VALUES('$state_array')";  dbdo($sql);
}


$sql="CREATE TABLE Setup(
           NameStore CHAR(25),
           NameDirector CHAR(25),
           Address CHAR(50),
           City CHAR(30),
           State CHAR(30),
           Country CHAR(15),
           Zip CHAR(10),
           Phone CHAR(30),
           Fax CHAR(30),
           Emailstore CHAR(30)
           Emailstore2 CHAR(30) # second email 
         )";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";

$sql="INSERT INTO Setup (NameStore,Emailstore,Fax) VALUES ('Bip','bapbgin\@usa.net' ,'375-232-50-45-71')";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="CREATE TABLE Passw(
            Id INT NOT NULL AUTO_INCREMENT,
            User CHAR(20),
            Password CHAR(20),
            Code CHAR(50),
            Super INT,
            PRIMARY KEY(Id)
          )";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";

$sql="INSERT INTO Passw (User,Password,Code,Super) VALUES ('SYSDBA','masterkey','abc',1)";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


}   ##dbcreate





############################################################################
sub download        #16.11.99 9:15
############################################################################

{


$sql="LOAD DATA INFILE 'e:\\2.txt' INTO TABLE Manufacturer";
#$sql="SELECT * INTO OUTFILE '/home/store/public_html/aoins.html/2.txt' from Manufacturer";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="LOAD DATA INFILE 'e:\\3.txt' INTO TABLE TypeOfBusiness";
#$sql="SELECT * INTO OUTFILE '/home/store/public_html/aoins.html/3.txt' from TypeOfBusiness";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="LOAD DATA INFILE 'e:\\4.txt' INTO TABLE Category";
#$sql="SELECT * INTO OUTFILE '/home/store/public_html/aoins.html/4.txt' from Category";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="LOAD DATA INFILE 'e:\\5.txt' INTO TABLE Subcategory";
#$sql="SELECT * INTO OUTFILE '/home/store/public_html/aoins.html/5.txt' from Subcategory";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="LOAD DATA INFILE 'e:\\6.txt' INTO TABLE Country";
#$sql="SELECT * INTO OUTFILE '/home/store/public_html/aoins.html/6.txt' from Country";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="LOAD DATA INFILE 'e:\\7.txt' INTO TABLE State";
#$sql="SELECT * INTO OUTFILE '/home/store/public_html/aoins.html/7.txt' from State";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="LOAD DATA INFILE 'e:\\8.txt' INTO TABLE Setup";
#$sql="SELECT * INTO OUTFILE '/home/store/public_html/aoins.html/8.txt' from Setup";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="LOAD DATA INFILE 'e:\\9.txt' INTO TABLE Product";
#$sql="SELECT * INTO OUTFILE '/home/store/public_html/aoins.html/9.txt' from Product";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="LOAD DATA INFILE 'e:\\10.txt' INTO TABLE Profile";
#$sql="SELECT * INTO OUTFILE '/home/store/public_html/aoins.html/10.txt' from Profile";
dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";



$sql="LOAD DATA INFILE 'e:\\11.txt' INTO TABLE Transactions";
#$sql="SELECT * INTO OUTFILE '/home/store/public_html/aoins.html/11.txt' from Transactions";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="LOAD DATA INFILE 'e:\\12.txt' INTO TABLE TransOrder";
#$sql="SELECT * INTO OUTFILE '/home/store/public_html/aoins.html/12.txt' from TransOrder";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="LOAD DATA INFILE 'e:\\13.txt' INTO TABLE OrderList";
#$sql="SELECT * INTO OUTFILE '/home/store/public_html/aoins.html/13.txt' from OrderList";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


$sql="LOAD DATA INFILE 'e:\\14.txt' INTO TABLE OrderListCheck";
#$sql="SELECT * INTO OUTFILE '/home/store/public_html/aoins.html/14.txt' from OrderListCheck";
#dbdo($sql) or $message.="Error - can not do SQL=$sql <P>";


}