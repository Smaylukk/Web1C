﻿
&НаКлиенте
Процедура СоставПриАктивизацииСтроки(Элемент)
	СтрокаТЧ = Элементы.Состав.ТекущаяСтрока;
	Если СтрокаТЧ = Неопределено Или СтрокаТЧ = ИДСтрокиСостава Тогда
		Возврат;
	КонецЕсли;
	
	ИДСтрокиСостава = СтрокаТЧ;
	
	ОчиститьДанныеКонструктора();
	
	ПрочитатьСтрокуСоставаНаСервере(СтрокаТЧ);
	
	УстановитьВидимостьКонструктора();
	
	ОтметкаМодифицированностиЭлементаСостава(Ложь);
КонецПроцедуры

&НаСервере
Процедура ПрочитатьСтрокуСоставаНаСервере(ИДСтроки)
	ТекОб = РеквизитФормыВЗначение("Объект");
	СтрокаТЧ = ТекОб.Состав.Получить(ИДСтроки);
	
	НаименованиеЭлементаСостава = СтрокаТЧ.Наименование;
	Текст = СтрокаТЧ.Текст;
	ВидИсточникаДанных = СтрокаТЧ.ВидИсточникаДанных;
	ИсточникДанных = СтрокаТЧ.ИсточникДанных;
	
	Если Не ПустаяСтрока(СтрокаТЧ.Параметры) Тогда
		ПараметрыСТроки = ЗначениеИзСтрокиВнутр(СтрокаТЧ.Параметры);
		Если ПараметрыСТроки <> Неопределено Тогда
			ПараметрыИсточника.Загрузить(ПараметрыСТроки.ПараметрыИсточника);
		КонецЕсли;
	КонецЕсли;
	
	Элементы.ПараметрыИсточникаПараметр.СписокВыбора.ЗагрузитьЗначения(ПолучитьСписокПараметровИсточника().ВыгрузитьЗначения());
	
	Если ЗначениеЗаполнено(ИсточникДанных) Тогда
		СписокПолейИсточника = ПолучитьСписокПолейИсточника();
	КонецЕсли;
	
	ЗначениеВРеквизитФормы(ТекОб, "Объект");
КонецПроцедуры


&НаКлиенте
Процедура СохранитьЭлементСостава(Команда)
	СтрокаТЧ = Элементы.Состав.ТекущаяСтрока;
	Если СтрокаТЧ = Неопределено И СтрокаТЧ = ИДСтрокиСостава Тогда
		Возврат;
	КонецЕсли;
	
	СохранитьСтрокуСостава();
	
	ОтметкаМодифицированностиЭлементаСостава(Ложь);
	//СтрокаТЧ.Наименование = НаименованиеЭлементаСостава;
	//СтрокаТЧ.Текст = Текст;
	//СтрокаТЧ.ВидИсточникаДанных = ВидИсточникаДанных;
	//
	//ПараметрыСтроки = Новый Структура;
	////ПараметрыСтроки.Вставить("ПараметрыИсточника", ПараметрыИсточника.Выгрузить());
	//ПараметрыСтроки.Вставить("ПараметрыИсточника", ПараметрыИсточника);
	//СтрокаТЧ.Параметры = ПолучитьИзВременногоХранилища(ПолучитьХранилище(ПараметрыСтроки));
КонецПроцедуры

&НаСервере
Процедура СохранитьСтрокуСостава()
	ТекОб = РеквизитФормыВЗначение("Объект");
	СтрокаТЧ = ТекОб.Состав.Получить(ИДСтрокиСостава);
	
	СтрокаТЧ.Наименование = НаименованиеЭлементаСостава;
	СтрокаТЧ.Текст = Текст;
	СтрокаТЧ.ВидИсточникаДанных = ВидИсточникаДанных;
	СтрокаТЧ.ИсточникДанных = ИсточникДанных;
	
	ПараметрыСтроки = Новый Структура;
	ПараметрыСтроки.Вставить("ПараметрыИсточника", ПараметрыИсточника.Выгрузить());
	//ПараметрыСтроки.Вставить("ПараметрыИсточника", ПараметрыИсточника);
	СтрокаТЧ.Параметры = ЗначениеВСтрокуВнутр(ПараметрыСтроки);
	
	ЗначениеВРеквизитФормы(ТекОб, "Объект");
	Записать();
КонецПроцедуры


&НаСервере
Функция ПолучитьХранилище(Данные)
	Результат = Новый ХранилищеЗначения(Данные);
	
	Возврат ПоместитьВоВременноеХранилище(Результат);
КонецФункции

&НаКлиенте
Процедура ПараметрыИсточникаПриАктивизацииСтроки(Элемент)
	НастроитьСтрокуПараметраИсточника();
КонецПроцедуры

&НаКлиенте
Процедура НастроитьСтрокуПараметраИсточника()
	ТекСтрока = Элементы.ПараметрыИсточника.ТекущиеДанные;
	Если ТекСтрока = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ТекСтрока.ИсточникЗначения = 0 Тогда
		Элементы.ПараметрыИсточникаЗначение.РежимВыбораИзСписка = Ложь;
		Элементы.ПараметрыИсточникаЗначение.РедактированиеТекста = Истина;
		
		ПривестиТипПоля(ТекСтрока.Параметр);
	Иначе
		Элементы.ПараметрыИсточникаЗначение.РежимВыбораИзСписка = Истина;
		Элементы.ПараметрыИсточникаЗначение.РедактированиеТекста = Ложь;
		//Элементы.ПараметрыИсточникаЗначение.СписокВыбора = ПолучитьСписокВходящихПараметров();
		Элементы.ПараметрыИсточникаЗначение.СписокВыбора.ЗагрузитьЗначения(ПолучитьСписокВходящихПараметров().ВыгрузитьЗначения());
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПривестиТипПоля(Параметр)
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВидимостьКонструктора(ПриводитьТип = Ложь)
	Если ВидИсточникаДанных = ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.Запрос") Тогда
		Элементы.ПараметрыИсточника.Видимость = Истина;
		Элементы.ИсточникДанных.Видимость = Истина;
		Элементы.ПодсказкаКод.Видимость = Ложь;
		Если ПриводитьТип Тогда
			ИсточникДанных = ПредопределенноеЗначение("Справочник.Web1C_ИсточникДанных.ПустаяСсылка");
		КонецЕсли;
	ИначеЕсли ВидИсточникаДанных = ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.ПростойТекст") Тогда
		Элементы.ПараметрыИсточника.Видимость = Ложь;
		Элементы.ИсточникДанных.Видимость = Ложь;
		Элементы.ПодсказкаКод.Видимость = Ложь;
		Если ПриводитьТип Тогда
			ИсточникДанных = Неопределено;
		КонецЕсли;
	ИначеЕсли ВидИсточникаДанных = ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.Значение") Тогда
	    Элементы.ПараметрыИсточника.Видимость = Ложь;
		Элементы.ИсточникДанных.Видимость = Ложь;
		Элементы.ПодсказкаКод.Видимость = Ложь;
		Если ПриводитьТип Тогда
			ИсточникДанных = Неопределено;
		КонецЕсли;
	ИначеЕсли ВидИсточникаДанных = ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.Объект") Тогда
		Элементы.ПараметрыИсточника.Видимость = Ложь;
		Элементы.ИсточникДанных.Видимость = Истина;
		Элементы.ПодсказкаКод.Видимость = Ложь;
		Если ПриводитьТип Тогда
			ИсточникДанных = Неопределено;
		КонецЕсли;
	ИначеЕсли ВидИсточникаДанных = ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.Список") Тогда
		Элементы.ПараметрыИсточника.Видимость = Ложь;
		Элементы.ИсточникДанных.Видимость = Ложь;
		Элементы.ПодсказкаКод.Видимость = Ложь;
		Если ПриводитьТип Тогда
			ИсточникДанных = Новый СписокЗначений;
		КонецЕсли;
	ИначеЕсли ВидИсточникаДанных = ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.ЗапросСОбработкойРезультата") Тогда
		Элементы.ПараметрыИсточника.Видимость = Истина;
		Элементы.ИсточникДанных.Видимость = Истина;
		Элементы.ПодсказкаКод.Видимость = Истина;
		Если ПриводитьТип Тогда
			ИсточникДанных = ПредопределенноеЗначение("Справочник.Web1C_ИсточникДанных.ПустаяСсылка");
		КонецЕсли;
	ИначеЕсли ВидИсточникаДанных = ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.ПроизвольныйКод") Тогда
		Элементы.ПараметрыИсточника.Видимость = Ложь;
		Элементы.ИсточникДанных.Видимость = Ложь;
		Элементы.ПодсказкаКод.Видимость = Истина;
		Если ПриводитьТип Тогда
			ИсточникДанных = Неопределено;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Функция ПолучитьСписокВходящихПараметров()
	Результат = Новый  СписокЗначений;
	
	Для каждого вхПараметр Из Объект.ВходящиеПараметры Цикл
		Результат.Добавить(вхПараметр.ИмяПараметра);
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

&НаСервере
Функция ПолучитьСписокПараметровИсточника()
	Результат = Новый СписокЗначений;
	
	Если ВидИсточникаДанных <> ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.Запрос") И ВидИсточникаДанных <> ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.ЗапросСОбработкойРезультата") Тогда
		Возврат Результат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ИсточникДанныхПараметры.Параметр КАК Параметр
	|ИЗ
	|	Справочник.Web1C_ИсточникДанных.Параметры КАК ИсточникДанныхПараметры
	|ГДЕ
	|	ИсточникДанныхПараметры.Ссылка = &Ссылка";
	Запрос.УстановитьПараметр("Ссылка", ИсточникДанных);
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		Результат.Добавить(Выборка.Параметр);
	КонецЦикла; 
	
	
	Возврат Результат;
КонецФункции

&НаСервере
Функция ПолучитьСписокПолейИсточника()
	Результат = Новый СписокЗначений;
	
	Если ВидИсточникаДанных <> ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.Запрос") И ВидИсточникаДанных <> ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.ЗапросСОбработкойРезультата") Тогда
		Возврат Результат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ИсточникДанныхПоля.ИмяПоля КАК ИмяПоля,
	|	ИсточникДанныхПоля.Формат КАК Формат
	|ИЗ
	|	Справочник.Web1C_ИсточникДанных.Поля КАК ИсточникДанныхПоля
	|ГДЕ
	|	ИсточникДанныхПоля.Ссылка = &Ссылка";
	Запрос.УстановитьПараметр("Ссылка", ИсточникДанных);
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		Если ВидИсточникаДанных = ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.Запрос") Тогда
			Результат.Добавить("{#Поле_" + Выборка.ИмяПоля + "#}", Выборка.ИмяПоля);
		ИначеЕсли ВидИсточникаДанных = ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.ЗапросСОбработкойРезультата") Тогда
			Результат.Добавить("ВыборкаДанных." + Выборка.ИмяПоля, Выборка.ИмяПоля);
			Если Не ПустаяСтрока(Выборка.Формат) Тогда
				Результат.Добавить("Формат(ВыборкаДанных." + Выборка.ИмяПоля + ", """ + Выборка.Формат + """)", Выборка.ИмяПоля + " - формат поля");
			КонецЕсли;			
		КонецЕсли;
	КонецЦикла; 
	
	
	Возврат Результат;
КонецФункции

&НаКлиенте
Процедура ПараметрыИсточникаИсточникЗначенияПриИзменении(Элемент)
	НастроитьСтрокуПараметраИсточника();
КонецПроцедуры

&НаКлиенте
Процедура ВидИсточникаДанныхПриИзменении(Элемент)
	УстановитьВидимостьКонструктора(Истина);
	
	ОтметкаМодифицированностиЭлементаСостава();
КонецПроцедуры

&НаКлиенте
Процедура ИсточникДанныхПриИзменении(Элемент)
	Элементы.ПараметрыИсточникаПараметр.СписокВыбора.ЗагрузитьЗначения(ПолучитьСписокПараметровИсточника().ВыгрузитьЗначения());	
	
	СписокПолейИсточника = ПолучитьСписокПолейИсточника();
	
	ОтметкаМодифицированностиЭлементаСостава();
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьДанныеКонструктора()
	НаименованиеЭлементаСостава = "";
	ВидИсточникаДанных = Неопределено;
	ИсточникДанных = Неопределено;
	ПараметрыИсточника.Очистить();
	Текст = "";
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ИДСтрокиСостава = -1;
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьПолеИсточника(Команда)
	ОО = Новый ОписаниеОповещения("ПослеВыбораПоляИсточника", ЭтотОбъект);
	СписокПолейИсточника.ПоказатьВыборЭлемента(ОО, "Выберите поле", Элементы.ДобавитьПолеИсточника);
КонецПроцедуры

&НаКлиенте
Процедура ПослеВыбораПоляИсточника(РезультатВыбора, ДопПараметры) Экспорт 
	Если РезультатВыбора <> Неопределено Тогда
		//Если ВидИсточникаДанных = ПредопределенноеЗначение("Перечисление.ВидыИсточниковДанных.Запрос") Тогда
		//	Элементы.Текст.ВыделенныйТекст = "{#Поле_" + РезультатВыбора.Значение + "#}";
		//ИначеЕсли ВидИсточникаДанных = ПредопределенноеЗначение("Перечисление.ВидыИсточниковДанных.ЗапросСОбработкойРезультата") Тогда
		//	Элементы.Текст.ВыделенныйТекст = "ВыборкаДанных." + РезультатВыбора.Значение;
		//КонецЕсли;
		Элементы.Текст.ВыделенныйТекст = РезультатВыбора.Значение;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ВставитьПерменную(Команда)
	СписокПеременных = ПолучитьСписокПеременных();
	
	ОО = Новый ОписаниеОповещения("ПослеВыбораПеременной", ЭтотОбъект);
	СписокПеременных.ПоказатьВыборЭлемента(ОО, "Выберите переменную");
КонецПроцедуры

&НаКлиенте
Процедура ПослеВыбораПеременной(РезультатВыбора, ДопПараметры) Экспорт 
	Если РезультатВыбора <> Неопределено Тогда
		Если ВидИсточникаДанных = ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.ЗапросСОбработкойРезультата") Или ВидИсточникаДанных = ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.ПроизвольныйКод") Тогда
			Элементы.Текст.ВыделенныйТекст = РезультатВыбора.Значение;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Функция ПолучитьСписокПеременных()
	Результат = Новый СписокЗначений;
	
	Результат.Добавить("ВыходнаяСтрока");
	Результат.Добавить("НомерСтроки");
	
	Возврат Результат;
КонецФункции

&НаКлиенте
Процедура ОтметкаМодифицированностиЭлементаСостава(Изменено = Истина)
	Если Изменено Тогда
		Элементы.СохранитьЭлементСостава.ЦветФона = WebЦвета.БледноЗеленый;
	иначе
		Элементы.СохранитьЭлементСостава.ЦветФона = WebЦвета.Белый;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТекстПриИзменении(Элемент)
	ОтметкаМодифицированностиЭлементаСостава();
КонецПроцедуры

&НаКлиенте
Процедура НаименованиеЭлементаСоставаПриИзменении(Элемент)
	ОтметкаМодифицированностиЭлементаСостава();
КонецПроцедуры

&НаКлиенте
Процедура ПараметрыИсточникаПриИзменении(Элемент)
	ОтметкаМодифицированностиЭлементаСостава();
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	УстановитьВидимостьКонструктора();
КонецПроцедуры

&НаСервере
Процедура СкопироватьСтрокуСоставаНаСервере(ИДСтроки)
	ТекОб = РеквизитФормыВЗначение("Объект");
	СтрокаТЧ = ТекОб.Состав.Получить(ИДСтроки);
	
	НоваяСтрока = ТекОб.Состав.Добавить();
	
	ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаТЧ);
	
	ИДСтроки = ТекОб.Состав.Индекс(НоваяСтрока);
	
	ЗначениеВРеквизитФормы(ТекОб, "Объект");
КонецПроцедуры

&НаКлиенте
Процедура СкопироватьСтрокуСостава(Команда)
	СтрокаТЧ = Элементы.Состав.ТекущаяСтрока;
	Если СтрокаТЧ = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	СкопироватьСтрокуСоставаНаСервере(СтрокаТЧ);
	
	Элементы.Состав.ТекущаяСтрока = СтрокаТЧ
КонецПроцедуры

&НаКлиенте
Процедура ВставитьВходящийПараметр(Команда)
	СписокПараметров = ПолучитьСписокВходящиеПараметров();
	
	ОО = Новый ОписаниеОповещения("ПослеВыбораПараметра", ЭтотОбъект);
	СписокПараметров.ПоказатьВыборЭлемента(ОО, "Выберите входящий параметр");

КонецПроцедуры

&НаКлиенте
Процедура ПослеВыбораПараметра(РезультатВыбора, ДопПараметры) Экспорт 
	Если РезультатВыбора <> Неопределено Тогда
		Если ВидИсточникаДанных = ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.ЗапросСОбработкойРезультата") Или ВидИсточникаДанных = ПредопределенноеЗначение("Перечисление.Web1C_ВидыИсточниковДанных.ПроизвольныйКод") Тогда
			Элементы.Текст.ВыделенныйТекст = "ВходящиеПараметры." + РезультатВыбора.Значение;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Функция ПолучитьСписокВходящиеПараметров()
	Результат = Новый СписокЗначений;
	
	Для каждого ТекСтрока Из Объект.ВходящиеПараметры Цикл
		Результат.Добавить(ТекСтрока.ИмяПараметра);
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

&НаСервере
Функция ПроверитьМакетНаСервере()
	Записать();
	ВходящиеПараметры = Новый Структура;
	
	Для каждого ТекСтрока Из Объект.ВходящиеПараметры Цикл
		ВходящиеПараметры.Вставить(ТекСтрока.ИмяПараметра, ТекСтрока.ЗначениеДляПроверки);
	КонецЦикла;
	
	Возврат РеквизитФормыВЗначение("Объект").ПолучитьТекстМакета(ВходящиеПараметры);
КонецФункции

&НаКлиенте
Процедура ПроверитьМакет(Команда)
	ПоказатьЗначение(, ПроверитьМакетНаСервере());
КонецПроцедуры

&НаКлиенте
Процедура ПослеВыбораСсылки(ВыбранныйЭлемент, ДопПараметры) Экспорт
	Если ВыбранныйЭлемент <> Неопределено Тогда
		Элементы.Текст.ВыделенныйТекст = ВыбранныйЭлемент.Значение;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ВставитьСсылку(Команда)
	СписокПеременных = Web1C_ФормированиеОтветов.ПолучитьСписокСсылок();
	
	ОО = Новый ОписаниеОповещения("ПослеВыбораСсылки", ЭтотОбъект);
	ПоказатьВыборИзМеню(ОО, СписокПеременных, Элементы.ВставитьСсылку); 
КонецПроцедуры

&НаКлиенте
Процедура Изображение(Команда)
	ОО = Новый ОписаниеОповещения("ПослеВыбораИзображения", ЭтотОбъект);
	П = Новый Структура;
	П.Вставить("Отбор", Новый Структура("ВидРесурса", ПредопределенноеЗначение("Перечисление.Web1C_ВидыРесурса.Изображение")));
	
	ОткрытьФорму("Справочник.Ресурсы.ФормаВыбора", П, ЭтаФорма, , , , ОО, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры

&НаКлиенте
Функция ПослеВыбораИзображения(РезультатВыбора, ДополнительныеПараметры) экспорт
	Если РезультатВыбора <> Неопределено Тогда
		Элементы.Текст.ВыделенныйТекст = Web1C_УправлениеКонтентом.ПолучитьПредставлениеРесурсаНаСервере(РезультатВыбора);
	КонецЕсли;
КонецФункции

&НаКлиенте
Процедура ВставитьФайл(Команда)
	ОО = Новый ОписаниеОповещения("ПослеВыбораФайла", ЭтотОбъект);
	П = Новый Структура;
	
	ОткрытьФорму("Справочник.Ресурсы.ФормаВыбора", П, ЭтаФорма, , , , ОО, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры

&НаКлиенте
Функция ПослеВыбораФайла(РезультатВыбора, ДополнительныеПараметры) экспорт
	Если РезультатВыбора <> Неопределено Тогда
		Элементы.Текст.ВыделенныйТекст = Web1C_УправлениеКонтентом.ПолучитьПредставлениеРесурсаНаСервере(РезультатВыбора);
	КонецЕсли;
КонецФункции

&НаКлиенте
Процедура ВставитьОбщуюПеременную(Команда)
	СписокПеременных = Web1C_ФормированиеОтветов.ПолучитьСписокПеременных();
	
	ОО = Новый ОписаниеОповещения("ПослеВыбораОбщейПеременной", ЭтотОбъект);
	ПоказатьВыборИзМеню(ОО, СписокПеременных, Элементы.ВставитьОбщуюПеременную);
КонецПроцедуры

&НаКлиенте
Процедура ПослеВыбораОбщейПеременной(ВыбранныйЭлемент, ДопПараметры) Экспорт
	Если ВыбранныйЭлемент <> Неопределено Тогда
		Элементы.Текст.ВыделенныйТекст = ВыбранныйЭлемент.Значение;
	КонецЕсли;
КонецПроцедуры
