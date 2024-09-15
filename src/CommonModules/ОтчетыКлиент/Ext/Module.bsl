﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Запускает процесс формирования отчета в форме отчета.
//  После завершения формирования вызывается ОбработчикЗавершения.
//
// Параметры:
//   ФормаОтчета - ФормаКлиентскогоПриложения - форма отчета.
//   ОбработчикЗавершения - ОбработчикОповещения - обработчик, который будет вызван после формирования отчета.
//     В 1-й параметр процедуры, указанной в ОбработчикЗавершения,
//     передается параметр: ОтчетСформирован (Булево) - признак того, что отчет был успешно сформирован.
//
Процедура СформироватьОтчет(ФормаОтчета, ОбработчикЗавершения = Неопределено) Экспорт
	Если ТипЗнч(ОбработчикЗавершения) = Тип("ОписаниеОповещения") Тогда
		ФормаОтчета.ОбработчикПослеФормированияНаКлиенте = ОбработчикЗавершения;
	КонецЕсли;
	ФормаОтчета.ПодключитьОбработчикОжидания("Сформировать", 0.1, Истина);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Методы работы с СКД из формы отчета.

Функция ТипЗначенияОграниченныйСвязьюПоТипу(Настройки, ПользовательскиеНастройки, ЭлементНастройки, ОписаниеЭлементаНастройки, ТипЗначения = Неопределено) Экспорт 
	Если ОписаниеЭлементаНастройки = Неопределено Тогда 
		Возврат ?(ТипЗначения = Неопределено, Новый ОписаниеТипов("Неопределено"), ТипЗначения);
	КонецЕсли;
	
	Если ТипЗначения = Неопределено Тогда 
		ТипЗначения = ОписаниеЭлементаНастройки.ТипЗначения;
	КонецЕсли;
	
	СвязьПоТипу = ОписаниеЭлементаНастройки.СвязьПоТипу;
	
	СвязанныйЭлементНастройки = ЭлементНастройкиПоПолю(Настройки, ПользовательскиеНастройки, СвязьПоТипу.Поле);
	Если СвязанныйЭлементНастройки = Неопределено Тогда 
		Возврат ТипЗначения;
	КонецЕсли;
	
	ДопустимыеВидыСравнения = Новый Массив;
	ДопустимыеВидыСравнения.Добавить(ВидСравненияКомпоновкиДанных.Равно);
	ДопустимыеВидыСравнения.Добавить(ВидСравненияКомпоновкиДанных.ВИерархии);
	
	Если ТипЗнч(СвязанныйЭлементНастройки) = Тип("ЭлементОтбораКомпоновкиДанных")
		И (Не СвязанныйЭлементНастройки.Использование
		Или ДопустимыеВидыСравнения.Найти(СвязанныйЭлементНастройки.ВидСравнения) = Неопределено) Тогда 
		Возврат ТипЗначения;
	КонецЕсли;
	
	ОписаниеСвязанногоЭлементаНастройки = ОтчетыКлиентСервер.НайтиДоступнуюНастройку(Настройки, СвязанныйЭлементНастройки);
	Если ОписаниеСвязанногоЭлементаНастройки = Неопределено Тогда 
		Возврат ТипЗначения;
	КонецЕсли;
	
	Если ТипЗнч(СвязанныйЭлементНастройки) = Тип("ЗначениеПараметраНастроекКомпоновкиДанных")
		И (ОписаниеСвязанногоЭлементаНастройки.Использование <> ИспользованиеПараметраКомпоновкиДанных.Всегда
		Или Не СвязанныйЭлементНастройки.Использование) Тогда 
		Возврат ТипЗначения;
	КонецЕсли;
	
	Если ТипЗнч(СвязанныйЭлементНастройки) = Тип("ЗначениеПараметраНастроекКомпоновкиДанных") Тогда 
		ЗначениеСвязанногоЭлементаНастройки = СвязанныйЭлементНастройки.Значение;
	ИначеЕсли ТипЗнч(СвязанныйЭлементНастройки) = Тип("ЭлементОтбораКомпоновкиДанных") Тогда 
		ЗначениеСвязанногоЭлементаНастройки = СвязанныйЭлементНастройки.ПравоеЗначение;
	КонецЕсли;
	
	ТипСубконто = ВариантыОтчетовВызовСервера.ТипСубконто(ЗначениеСвязанногоЭлементаНастройки, СвязьПоТипу.ЭлементСвязи);
	Если ТипЗнч(ТипСубконто) = Тип("ОписаниеТипов") Тогда
		СвязанныеТипы = ТипСубконто.Типы();
	Иначе
		СвязанныеТипы = ОписаниеСвязанногоЭлементаНастройки.ТипЗначения.Типы();
	КонецЕсли;
	
	ВычитаемыеТипы = ТипЗначения.Типы();
	Индекс = ВычитаемыеТипы.ВГраница();
	Пока Индекс >= 0 Цикл 
		Если СвязанныеТипы.Найти(ВычитаемыеТипы[Индекс]) <> Неопределено Тогда 
			ВычитаемыеТипы.Удалить(Индекс);
		КонецЕсли;
		Индекс = Индекс - 1;
	КонецЦикла;
	
	Возврат Новый ОписаниеТипов(ТипЗначения,, ВычитаемыеТипы);
КонецФункции

Функция ЭлементНастройкиПоПолю(Настройки, ПользовательскиеНастройки, Поле)
	ЭлементНастройки = Неопределено;
	
	ЭлементыНастроек = Настройки.ПараметрыДанных.Элементы;
	Для Каждого Элемент Из ЭлементыНастроек Цикл 
		ЭлементПользовательский = ПользовательскиеНастройки.Найти(Элемент.ИдентификаторПользовательскойНастройки);
		ЭлементАнализируемый = ?(ЭлементПользовательский = Неопределено, Элемент, ЭлементПользовательский);
		
		Поля = Новый Массив;
		Поля.Добавить(Новый ПолеКомпоновкиДанных(Строка(Элемент.Параметр)));
		Поля.Добавить(Новый ПолеКомпоновкиДанных("ПараметрыДанных." + Строка(Элемент.Параметр)));
		
		Если ЭлементАнализируемый.Использование
			И (Поля[0] = Поле Или Поля[1] = Поле) Тогда 
			ЭлементНастройки = ЭлементАнализируемый;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если ЭлементНастройки <> Неопределено Тогда 
		Возврат ЭлементНастройки;
	КонецЕсли;
	
	НайтиЭлементОтбораПоПолю(Поле, Настройки.Отбор.Элементы, ПользовательскиеНастройки, ЭлементНастройки);
	
	Возврат ЭлементНастройки;
КонецФункции

Процедура НайтиЭлементОтбораПоПолю(Поле, ЭлементыОтбора, ПользовательскиеНастройки, ЭлементНастройки)
	Для Каждого Элемент Из ЭлементыОтбора Цикл 
		Если ТипЗнч(Элемент) = Тип("ГруппаЭлементовОтбораКомпоновкиДанных") Тогда 
			НайтиЭлементОтбораПоПолю(Поле, Элемент.Элементы, ПользовательскиеНастройки, ЭлементНастройки)
		Иначе
			ЭлементПользовательский = ПользовательскиеНастройки.Найти(Элемент.ИдентификаторПользовательскойНастройки);
			ЭлементАнализируемый = ?(ЭлементПользовательский = Неопределено, Элемент, ЭлементПользовательский);
			
			Если ЭлементАнализируемый.Использование И Элемент.ЛевоеЗначение = Поле Тогда 
				ЭлементНастройки = ЭлементАнализируемый;
				Прервать;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Функция СведенияОЭлементеНастройки(КомпоновщикНастроек, Идентификатор) Экспорт 
	Настройки = КомпоновщикНастроек.Настройки;
	ПользовательскиеНастройки = КомпоновщикНастроек.ПользовательскиеНастройки;
	
	Если ТипЗнч(Идентификатор) = Тип("Число") Тогда 
		Индекс = Идентификатор;
	Иначе
		Индекс = ОтчетыКлиентСервер.ИндексЭлементаНастройкиПоПути(Идентификатор);
	КонецЕсли;
	
	ЭлементПользовательскойНастройки = ПользовательскиеНастройки.Элементы[Индекс];
	
	ИерархияНастроек = Новый Массив;
	Элемент = ОтчетыКлиентСервер.ПолучитьОбъектПоПользовательскомуИдентификатору(
		Настройки,
		ЭлементПользовательскойНастройки.ИдентификаторПользовательскойНастройки,
		ИерархияНастроек,
		ПользовательскиеНастройки);
	
	Настройки = ?(ИерархияНастроек.Количество() > 0, ИерархияНастроек[ИерархияНастроек.ВГраница()], Настройки);
	Описание = ОтчетыКлиентСервер.НайтиДоступнуюНастройку(Настройки, Элемент);
	
	Сведения = Новый Структура;
	Сведения.Вставить("Настройки", Настройки);
	Сведения.Вставить("Индекс", Индекс);
	Сведения.Вставить("ЭлементПользовательскойНастройки", ЭлементПользовательскойНастройки);
	Сведения.Вставить("Элемент", Элемент);
	Сведения.Вставить("Описание", Описание);
	
	Возврат Сведения;
КонецФункции

// Определяет значения типа ИспользованиеГруппИЭлементов в зависимости от вида сравнения (приоритетно) или исходного значения.
//
// Параметры:
//  Условие - ВидСравненияКомпоновкиДанных, Неопределено - текущее значение вида сравнения.
//  ИсходноеЗначение - ИспользованиеГруппИЭлементов, ГруппыИЭлементы - текущее значение свойства
//                     ВыборГруппИЭлементов.
//
// Возвращаемое значение:
//   ИспользованиеГруппИЭлементов - значение перечисления ИспользованиеГруппИЭлементов.
//
Функция ЗначениеТипаИспользованиеГруппИЭлементов(ИсходноеЗначение, Условие = Неопределено) Экспорт
	Если Условие <> Неопределено Тогда 
		Если Условие = ВидСравненияКомпоновкиДанных.ВСпискеПоИерархии
			Или Условие = ВидСравненияКомпоновкиДанных.НеВСпискеПоИерархии Тогда 
			Если ИсходноеЗначение = ГруппыИЭлементы.Группы
				Или ИсходноеЗначение = ИспользованиеГруппИЭлементов.Группы Тогда 
				Возврат ИспользованиеГруппИЭлементов.Группы;
			Иначе
				Возврат ИспользованиеГруппИЭлементов.ГруппыИЭлементы;
			КонецЕсли;
		ИначеЕсли Условие = ВидСравненияКомпоновкиДанных.ВИерархии
			Или Условие = ВидСравненияКомпоновкиДанных.НеВИерархии Тогда 
			Возврат ИспользованиеГруппИЭлементов.Группы;
		КонецЕсли;
	КонецЕсли;
	
	Если ТипЗнч(ИсходноеЗначение) = Тип("ИспользованиеГруппИЭлементов") Тогда 
		Возврат ИсходноеЗначение;
	ИначеЕсли ИсходноеЗначение = ГруппыИЭлементы.Элементы Тогда
		Возврат ИспользованиеГруппИЭлементов.Элементы;
	ИначеЕсли ИсходноеЗначение = ГруппыИЭлементы.ГруппыИЭлементы Тогда
		Возврат ИспользованиеГруппИЭлементов.ГруппыИЭлементы;
	ИначеЕсли ИсходноеЗначение = ГруппыИЭлементы.Группы Тогда
		Возврат ИспользованиеГруппИЭлементов.Группы;
	КонецЕсли;
	
	Возврат Неопределено;
КонецФункции

#Область ПериодОтчета

// Вызывает диалог редактирования стандартного периода.
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения - форма отчета или форма настроек отчета.
//  ИмяКоманды - Строка - имя команды выбора периода, содержащее путь к значению периода.
//
Процедура ВыбратьПериод(Форма, ИмяКоманды) Экспорт
	Путь = СтрЗаменить(ИмяКоманды, "ВыбратьПериод", "Период");
	Контекст = Новый Структура("Форма, Путь", Форма, Путь);
	
	Диалог = Новый ДиалогРедактированияСтандартногоПериода;
	Диалог.Период = Форма[Путь];
	Диалог.Показать(Новый ОписаниеОповещения("ВыбратьПериодЗавершение", ЭтотОбъект, Контекст));
КонецПроцедуры

// Обработчик редактирования стандартного периода.
//
// Параметры:
//  ВыбранныйПериод - СтандартныйПериод - значение, возвращенное диалогом.
//  Контекст - Структура - содержит форму отчета (настроек) и путь к значению периода.
//
Процедура ВыбратьПериодЗавершение(ВыбранныйПериод, Контекст) Экспорт 
	Если ВыбранныйПериод = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	Контекст.Форма[Контекст.Путь] = ВыбранныйПериод;
	УстановитьПериод(Контекст.Форма, Контекст.Путь);
КонецПроцедуры

// Инициализирует значение элемента настройки периода.
//
Процедура УстановитьПериод(Форма, Знач Путь) Экспорт 
	КомпоновщикНастроек = Форма.Отчет.КомпоновщикНастроек;
	
	Свойства = СтрРазделить("ДатаНачала, ДатаОкончания", ", ", Ложь);
	Для Каждого Свойство Из Свойства Цикл 
		Путь = СтрЗаменить(Путь, Свойство, "");
	КонецЦикла;
	
	Индекс = Форма.ПутьКДаннымЭлементов.ПоИмени[Путь];
	ЭлементПользовательскойНастройки = КомпоновщикНастроек.ПользовательскиеНастройки.Элементы[Индекс];
	ЭлементПользовательскойНастройки.Использование = Истина;
	
	Если ТипЗнч(ЭлементПользовательскойНастройки) = Тип("ЗначениеПараметраНастроекКомпоновкиДанных") Тогда 
		ЭлементПользовательскойНастройки.Значение = Форма[Путь];
	Иначе // Элемент отбора.
		ЭлементПользовательскойНастройки.ПравоеЗначение = Форма[Путь];
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область Прочее

Функция ПриДобавленииВКоллекциюНужноУказыватьТипЭлемента(ТипКоллекции) Экспорт
	Если ТипКоллекции = Тип("КоллекцияЭлементовСтруктурыТаблицыКомпоновкиДанных")
		Или ТипКоллекции = Тип("КоллекцияЭлементовСтруктурыДиаграммыКомпоновкиДанных")
		Или ТипКоллекции = Тип("КоллекцияЭлементовУсловногоОформленияКомпоновкиДанных") Тогда
		Возврат Ложь;
	Иначе
		Возврат Истина;
	КонецЕсли;
КонецФункции

#КонецОбласти

#КонецОбласти