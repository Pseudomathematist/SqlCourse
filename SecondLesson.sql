Categories - связь с Products один-ко-многим
Conctacts - нет связей
CustomerDemographics - связь с Customers через CustomerCustomerDemo многим-ко-многим, так как в CustomerCustomerDemo есть вторичные ключи один из которых связан с Customer, а другой с CustomerDemographic, так же оба этих столбца образуют составной первичный ключ, а значит что первому столбцу может соответсвовать разные вторые, а второму разные первые, то есть отношение многие-к-многим.
Customers - связь с Orders один-ко-многим, связь с CustomerDemographics через CustomerCustomerDemo многим-ко-многим.
Employees - cвязь с Orders один-ко-многим, связь с Territories через EmployeeTerritories многим-ко-многим, та же причина, вдобавок понятно, что одной территории могут соответсвовать несколько рабочих, а один рабочий работать на нескольких территориях.
Territories - связь с Employees через EmployeeTerritories многим-ко-многим 
Orders - связь с Products через Order Details многим-ко-многим, та же причина, вдобавок понятно, что одному продукту могут соответсвовать несколько заказов, а один заказ содержать несколько продуктов.
Products -  связь с Orders через Order Details многим-ко-многим.
Region - связь с Territories один-ко-многим
Shippers - связь с Orders один-ко-многим
Suppliers - связь с Products один-ко-многим
