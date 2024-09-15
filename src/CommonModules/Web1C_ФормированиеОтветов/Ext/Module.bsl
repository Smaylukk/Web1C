﻿
Функция ПолучитьСтраницу(ВидСтраницы)
	Результат = Справочники.Web1C_Страницы.ПустаяСсылка();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ первые 1
	|	Страницы.Ссылка КАК Страница
	|ИЗ
	|	Справочник.Web1C_Страницы КАК Страницы
	|ГДЕ
	|	Страницы.ПометкаУдаления = ЛОЖЬ
	|	И Страницы.ВидСтраницы = &ВидСтраницы";
	Запрос.УстановитьПараметр("ВидСтраницы", ВидСтраницы);
	РезультатЗапроса = Запрос.Выполнить();
	Если Не РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		Результат = Выборка.Страница;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

Процедура ПолучитьОтвет(ВариантСтраницы, Ответ, ДанныеПользователя) Экспорт
	КодСостояния = 200;
	
	Страница = ПолучитьСтраницу(ВариантСтраницы);
	
	Если Страница.Пустая() Тогда
		КодСостояния = 404;
	КонецЕсли;
	
	Ответ.КодСостояния = КодСостояния;
	
	Ответ.Заголовки.Вставить("Content-Type","text/html; charset=utf-8");
	
	//заполняем заголовки из структуры ответа
	//Ответ.Заголовки.Вставить(Ключ, Значение);
	
	
	Если КодСостояния  = 200 Тогда
		Ответ.УстановитьТелоИзСтроки(ПолучитьТекстСтраницы(Страница, ДанныеПользователя));
	Иначе
		Ответ.УстановитьТелоИзСтроки(Страница404(ДанныеПользователя));
	КонецЕсли;
КонецПроцедуры

Функция Страница404(ДанныеПользователя) Экспорт 
	Страница = ПолучитьСтраницу(ПредопределенноеЗначение("Перечисление.Web1C_ВидыСтраниц.Страница404"));
	Если Страница.Пустая() Тогда
		Возврат "404: Страница не найдена";
	Иначе
		Возврат ПолучитьТекстСтраницы(Страница, ДанныеПользователя);
	КонецЕсли;
КонецФункции

Функция ПолучитьПараметры(Тело)Экспорт
	
	Результат = Новый Структура;
	Тело = РаскодироватьСтроку(Тело, СпособКодированияСтроки.КодировкаURL, "UTF-8");
	Тело = СтрЗаменить(Тело, "+", " ");
	ПарметрыЗначения = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(Тело, "&");
	Для Каждого Пар Из ПарметрыЗначения Цикл
		
		мПар = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(Пар, "=");
		Если мПар.Количество() > 1 Тогда
			СущЗначениеПараметра = "";
			
			Попытка
				Результат.Свойство(мПар[0], СущЗначениеПараметра);
			Исключение
				Продолжить;	
			КонецПопытки;
			
			//Если в структуре нет такого параметра, просто его добавляем.
			Если ПустаяСтрока(СущЗначениеПараметра) Тогда 
				Результат.Вставить(мПар[0], мПар[1]);
			Иначе
				
				//Если такой параметр есть и значени его находится в массиве, то добавляем
				//текущий параметр в массив.
				Если ТипЗнч(СущЗначениеПараметра) = Тип("Массив") Тогда 
					СущЗначениеПараметра.Добавить(мПар[1]);
					Результат.Вставить(мПар[0], СущЗначениеПараметра);
					
					//Если это второе значение параметра, то добавляем уже существующее и текущее
					//значение в массив.	
				Иначе 
					МассивЗначЭтогоПараметра = Новый Массив();
					МассивЗначЭтогоПараметра.Добавить(СущЗначениеПараметра);
					МассивЗначЭтогоПараметра.Добавить(мПар[1]);
					Результат.Вставить(мПар[0], МассивЗначЭтогоПараметра);
				КонецЕсли;
			КонецЕсли;
			//Результат.Вставить(мПар[0], мПар[1]);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ПолучитьПараметрыКакСоответствие(Тело)Экспорт
	
	Результат = Новый Соответствие;
	Тело = РаскодироватьСтроку(Тело, СпособКодированияСтроки.КодировкаURL, "UTF-8");
	Тело = СтрЗаменить(Тело, "+", " ");
	ПарметрыЗначения = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(Тело, "&");
	Для Каждого Пар Из ПарметрыЗначения Цикл
		мПар = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(Пар, "=");
		Если мПар.Количество() > 1 Тогда
			СущЗначениеПараметра = Результат.Получить(мПар[0]);
			
			//Если в структуре нет такого параметра, просто его добавляем.
			Если СущЗначениеПараметра = Неопределено Тогда 
				Результат.Вставить(мПар[0], мПар[1]);
			Иначе
				//Если такой параметр есть и значени его находится в массиве, то добавляем
				//текущий параметр в массив.
				Если ТипЗнч(СущЗначениеПараметра) = Тип("Массив") Тогда 
					СущЗначениеПараметра.Добавить(мПар[1]);
					Результат.Вставить(мПар[0], СущЗначениеПараметра);
					
					//Если это второе значение параметра, то добавляем уже существующее и текущее
					//значение в массив.	
				Иначе 
					МассивЗначЭтогоПараметра = Новый Массив();
					МассивЗначЭтогоПараметра.Добавить(СущЗначениеПараметра);
					МассивЗначЭтогоПараметра.Добавить(мПар[1]);
					Результат.Вставить(мПар[0], МассивЗначЭтогоПараметра);
				КонецЕсли;
			КонецЕсли;
			
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ПолучитьТекстСтраницы(Страница, ДанныеПользователя)
	Если Ложь Тогда
		Страница = Справочники.Web1C_Страницы.СоздатьЭлемент()
	КонецЕсли;
	
	Результат = Страница.Шаблон;
	
	//подключение ресурсов в заголовок страницы - head
	Результат = СтрЗаменить(Результат, "</head>", Символы.ПС + ПолучитьСтрокуСтилей(Страница) + Символы.ПС + ПолучитьСтрокуСкриптов(Страница, Ложь) + Символы.ПС + "</head>");
	//подключение ресурсов в тело страницы - body
	Результат = СтрЗаменить(Результат, "</body>", Символы.ПС + ПолучитьСтрокуСкриптов(Страница, Истина) + Символы.ПС + "</body>");
	
	ОбработатьТекстСтраницы(Результат, ДанныеПользователя);
	
	Возврат Результат;	
	
КонецФункции

Функция ПолучитьТекстСтраницыДляПроверки(Страница) Экспорт
	Если Ложь Тогда
		Страница = Справочники.Web1C_Страницы.СоздатьЭлемент()
	КонецЕсли;
	
	Результат = Страница.Шаблон;
	
	//подключение ресурсов в заголовок страницы - head
	Результат = СтрЗаменить(Результат, "</head>", Символы.ПС + ПолучитьСтрокуСтилей(Страница) + Символы.ПС + ПолучитьСтрокуСкриптов(Страница, Ложь) + Символы.ПС + "</head>");
	//подключение ресурсов в тело страницы - body
	Результат = СтрЗаменить(Результат, "</body>", Символы.ПС + ПолучитьСтрокуСкриптов(Страница, Истина) + Символы.ПС + "</body>");
	
	ОбработатьТекстСтраницыДляПроверки(Результат);
	
	Возврат Результат;	
	
КонецФункции

Функция ПолучитьHTMLПредставлениеОшибки(ТекстОшибки) Экспорт 
	Результат = СтрШаблон("<h2 style='color:red'>Ошибка - %1</h2>", ТекстОшибки);
	
	Возврат Результат;
КонецФункции

Функция ПолучитьСтрокуСтилей(Страница)
	Результат = "";
	
	Для Каждого ТекСтиль Из Страница.Стили Цикл
		Если ТекСтиль.Стиль.ВнешнийФайл = 1 Тогда
			Результат = Результат + "
			|<link rel=""stylesheet"" href=""" + ТекСтиль.Стиль.URL + """/>";
		Иначе
			СетевойКаталог = "";
			ЛокальныйКаталог = "/" + Web1C_ОбщегоНазначения.ИмяПубликации() + "/res/";
			НастройкаЭкспорта = Web1C_УправлениеКонтентом.ПолучитьНастройкиЭкспортаОбъекта(ПредопределенноеЗначение("Перечисление.Web1C_HTMLОбъекты.Стили"));
			Если НастройкаЭкспорта <> Неопределено И Не ПустаяСтрока(НастройкаЭкспорта.ЧастичныйСетевойПуть) Тогда
				СетевойКаталог = НастройкаЭкспорта.ЧастичныйСетевойПуть;
				
				ПроверитьДобавитьСлеш(СетевойКаталог);
			КонецЕсли;
			
			Если ТекСтиль.Стиль.ВыгруженВСетевуюПапку И Не ПустаяСтрока(СетевойКаталог) Тогда
				Результат = Результат + "
				|<link rel=""stylesheet"" href=""" + СетевойКаталог + ТекСтиль.Стиль.Наименование + """/>";
			Иначе
				Результат = Результат + "
				|<link rel=""stylesheet"" href=""" + ЛокальныйКаталог + ТекСтиль.Стиль.ПутьВеб + """/>";
			КонецЕсли;
			
		КонецЕсли;
	КонецЦикла;
	
	
	Возврат Результат;
КонецФункции

Функция ПолучитьСтрокуСкриптов(Страница, ЗагрузкеВТелеСтраницы)
	Результат = "";
	
	Для Каждого ТекСкрипт Из Страница.Скрипты Цикл
		Если ТекСкрипт.ЗагрузкаВТеле = ЗагрузкеВТелеСтраницы Тогда
			Если ТекСкрипт.Скрипт.ВнешнийФайл = 1 Тогда
				Результат = Результат + "
				|<script src=""" + ТекСкрипт.Скрипт.URL + """></script>";
			Иначе
				СетевойКаталог = "";
				ЛокальныйКаталог = "/" + Web1C_ОбщегоНазначения.ИмяПубликации() + "/res/";
				НастройкаЭкспорта = Web1C_УправлениеКонтентом.ПолучитьНастройкиЭкспортаОбъекта(ПредопределенноеЗначение("Перечисление.Web1C_HTMLОбъекты.Скрипты"));
				Если НастройкаЭкспорта <> Неопределено И Не ПустаяСтрока(НастройкаЭкспорта.ЧастичныйСетевойПуть) Тогда
					СетевойКаталог = НастройкаЭкспорта.ЧастичныйСетевойПуть;
					
					ПроверитьДобавитьСлеш(СетевойКаталог);
				КонецЕсли;
				
				Если ТекСкрипт.Скрипт.ВыгруженВСетевуюПапку И Не ПустаяСтрока(СетевойКаталог) Тогда
					Результат = Результат + "
					|<script src=""" + СетевойКаталог + ТекСкрипт.Скрипт.Наименование + """></script>";
				Иначе
					Результат = Результат + "
					|<script src=""" + ЛокальныйКаталог + ТекСкрипт.Скрипт.ПутьВеб + """></script>";
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	
	Возврат Результат;
КонецФункции

Процедура ОбработатьТекстСтраницы(Текст, ДанныеПользователя) Экспорт
	//вставка блоков идет в первую очередь, т.к. они меняют текст страницы и его надо будет доработать
	ВставитьБлокиТекстов(Текст, ДанныеПользователя);
	
	Если ДанныеПользователя <> Неопределено И ТипЗнч(ДанныеПользователя) = Тип("Структура") Тогда
		Для каждого ТекКЗ Из ДанныеПользователя Цикл
			Если СтрНайти(Текст, "{#" + ТекКЗ.Ключ + "#}") > 0 Тогда
				Текст = СтрЗаменить(Текст, "{#" + ТекКЗ.Ключ + "#}", ТекКЗ.Значение);
			КонецЕсли;
		КонецЦикла;
		
		//ДанныеПВЗ = Неопределено;
		//Если ДанныеПользователя.Свойство("ДанныеПВЗ", ДанныеПВЗ) Тогда
		//	Если ДанныеПВЗ <> Неопределено И ТипЗнч(ДанныеПВЗ) = Тип("Структура") Тогда
		//		Для каждого ТекКЗ Из ДанныеПВЗ Цикл
		//			Если СтрНайти(Текст, "{#" + ТекКЗ.Ключ + "#}") > 0 Тогда
		//				Текст = СтрЗаменить(Текст, "{#" + ТекКЗ.Ключ + "#}", ТекКЗ.Значение);	
		//			КонецЕсли;
		//		КонецЦикла;
		//	КонецЕсли;
		//КонецЕсли;
		
		ПрочиеПараметры = Неопределено;
		Если ДанныеПользователя.Свойство("ПрочиеПараметры", ПрочиеПараметры) Тогда
			Если ПрочиеПараметры <> Неопределено И ТипЗнч(ПрочиеПараметры) = Тип("Структура") Тогда
				Для каждого ТекКЗ Из ПрочиеПараметры Цикл
					Если СтрНайти(Текст, "{#" + ТекКЗ.Ключ + "#}") > 0 Тогда
						Текст = СтрЗаменить(Текст, "{#" + ТекКЗ.Ключ + "#}", ТекКЗ.Значение);	
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	//замена изображений
	ВставитьСсылкиНаИзображения(Текст);
	
	//замена файлов http
	ВставитьСсылкиНаФайлы(Текст);
	
	//замена ресурсов
	ВставитьСсылкиНаРесурсы(Текст);
	
	Текст = СтрЗаменить(Текст, "{#Имя_Публикации#}", Web1C_ОбщегоНазначения.ИмяПубликации());
	
	УдалитьПеременные(Текст);
	
КонецПроцедуры

Функция ПолучитьСсылкиИзображений()
	Результат = Новый Соответствие;
	
	СетевойКаталог = "";
	ЛокальныйКаталог = "/" + Web1C_ОбщегоНазначения.ИмяПубликации() + "/res/";
	НастройкаЭкспорта = Web1C_УправлениеКонтентом.ПолучитьНастройкиЭкспортаОбъекта(ПредопределенноеЗначение("Перечисление.Web1C_HTMLОбъекты.Изображения"));
	Если НастройкаЭкспорта <> Неопределено И Не ПустаяСтрока(НастройкаЭкспорта.ЧастичныйСетевойПуть) Тогда
		СетевойКаталог = НастройкаЭкспорта.ЧастичныйСетевойПуть;
		
		ПроверитьДобавитьСлеш(СетевойКаталог);
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Изображения.Ссылка КАК Ссылка,
	|	Изображения.Наименование КАК Наименование,
	|	Изображения.ПутьВеб КАК ПутьВеб,
	|	Изображения.ВыгруженВСетевуюПапку КАК ВыгруженВСетевуюПапку
	|ИЗ
	|	Справочник.Web1C_Ресурсы КАК Изображения
	|ГДЕ
	|	Изображения.ПометкаУдаления = ЛОЖЬ
	|	И Изображения.ВидРесурса = &ВидРесурса";
	Запрос.УстановитьПараметр("ВидРесурса", ПредопределенноеЗначение("Перечисление.Web1C_ВидыРесурса.Изображение"));
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		Если Выборка.ВыгруженВСетевуюПапку И Не ПустаяСтрока(СетевойКаталог) Тогда
			Результат.Вставить(Выборка.Ссылка, СетевойКаталог + Выборка.Наименование);
		Иначе
			Результат.Вставить(Выборка.Ссылка, ЛокальныйКаталог + Выборка.ПутьВеб);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

Функция ПолучитьСсылкиФайлов()
	Результат = Новый Соответствие;
	
	СетевойКаталог = "";
	ЛокальныйКаталог = "/" + Web1C_ОбщегоНазначения.ИмяПубликации() + "/res/";
	НастройкаЭкспорта = Web1C_УправлениеКонтентом.ПолучитьНастройкиЭкспортаОбъекта(ПредопределенноеЗначение("Перечисление.Web1C_HTMLОбъекты.Файлы"));
	Если НастройкаЭкспорта <> Неопределено И Не ПустаяСтрока(НастройкаЭкспорта.ЧастичныйСетевойПуть) Тогда
		СетевойКаталог = НастройкаЭкспорта.ЧастичныйСетевойПуть;
		
		ПроверитьДобавитьСлеш(СетевойКаталог);
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ФайлыHTTP.Ссылка КАК Ссылка,
	|	ФайлыHTTP.Наименование КАК Наименование,
	|	ФайлыHTTP.ПутьВеб КАК ПутьВеб,
	|	ФайлыHTTP.ВыгруженВСетевуюПапку КАК ВыгруженВСетевуюПапку
	|ИЗ
	|	Справочник.Web1C_Ресурсы КАК ФайлыHTTP
	|ГДЕ
	|	ФайлыHTTP.ПометкаУдаления = ЛОЖЬ
	|	И ФайлыHTTP.ВидРесурса = &ВидРесурса";
	Запрос.УстановитьПараметр("ВидРесурса", ПредопределенноеЗначение("Перечисление.Web1C_ВидыРесурса.Файл"));
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		Если Выборка.ВыгруженВСетевуюПапку И Не ПустаяСтрока(СетевойКаталог) Тогда
			Результат.Вставить(Выборка.Ссылка, СетевойКаталог + Выборка.Наименование);
		Иначе
			Результат.Вставить(Выборка.Ссылка, ЛокальныйКаталог + Выборка.ПутьВеб);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

Функция ПолучитьСсылкиРесурсов()
	Результат = Новый Соответствие;
	
	СетевойКаталог = "";
	ЛокальныйКаталог = "/" + Web1C_ОбщегоНазначения.ИмяПубликации() + "/res/";
	НастройкиЭкспортаОбъектов = Web1C_УправлениеКонтентом.ПолучитьВсеНастройкиЭкспортаОбъектов();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Ресурсы.Ссылка КАК Ссылка,
	|	Ресурсы.Наименование КАК Наименование,
	|	Ресурсы.ПутьВеб КАК ПутьВеб,
	|	Ресурсы.ВыгруженВСетевуюПапку КАК ВыгруженВСетевуюПапку,
	|	Ресурсы.ВидРесурса КАК ВидРесурса
	|ИЗ
	|	Справочник.Web1C_Ресурсы КАК Ресурсы
	|ГДЕ
	|	Ресурсы.ПометкаУдаления = ЛОЖЬ
	|	И Ресурсы.ЭтоГруппа = ЛОЖЬ";
	
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		Если Выборка.ВыгруженВСетевуюПапку И Не ПустаяСтрока(СетевойКаталог) Тогда
			СетевойКаталог = НастройкиЭкспортаОбъектов.Получить(Выборка.ВидРесурса).ЧастичныйСетевойПуть;
			ПроверитьДобавитьСлеш(СетевойКаталог);
			Результат.Вставить(Выборка.Ссылка, СетевойКаталог + Выборка.Наименование);
		Иначе
			Результат.Вставить(Выборка.Ссылка, ЛокальныйКаталог + Выборка.ПутьВеб);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

Процедура ВставитьСсылкиНаИзображения(Текст)
	Если СтрНайти(Текст, "{#images_", НаправлениеПоиска.СНачала) = 0 Тогда
		Возврат;
	КонецЕсли;
	
	СсылкиИзображений = ПолучитьСсылкиИзображений();
	Пока Истина Цикл
		ПозНач = СтрНайти(Текст, "{#images_", НаправлениеПоиска.СНачала);
		Если ПозНач > 0 Тогда
			ПозКон = СтрНайти(Текст, "#}", НаправлениеПоиска.СНачала, ПозНач);
			СсылкаНаИзображение = "";
			УИД = Сред(Текст, ПозНач, ПозКон - ПозНач);
			УИД = СтрЗаменить(УИД, "{#images_", "");
			Изображение = Справочники.Web1C_Ресурсы.ПолучитьСсылку(Новый УникальныйИдентификатор(УИД));
			Если Не Изображение.Пустая() Тогда
				СсылкаНаИзображение = СсылкиИзображений.Получить(Изображение);
			КонецЕсли;
			
			Текст = СтрЗаменить(Текст, "{#images_" + Изображение.УникальныйИдентификатор() + "#}", СсылкаНаИзображение);
		Иначе
			Прервать;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Процедура ВставитьСсылкиНаФайлы(Текст)
	Если СтрНайти(Текст, "{#files_", НаправлениеПоиска.СНачала) = 0 Тогда
		Возврат;
	КонецЕсли;
	
	СсылкиФайлов = ПолучитьСсылкиФайлов();
	Пока Истина Цикл
		ПозНач = СтрНайти(Текст, "{#files_", НаправлениеПоиска.СНачала);
		Если ПозНач > 0 Тогда
			ПозКон = СтрНайти(Текст, "#}", НаправлениеПоиска.СНачала, ПозНач);
			СсылкаНаФайл = "";
			УИД = Сред(Текст, ПозНач, ПозКон - ПозНач);
			УИД = СтрЗаменить(УИД, "{#files_", "");
			Файл = Справочники.Web1C_Ресурсы.ПолучитьСсылку(Новый УникальныйИдентификатор(УИД));
			Если Не Файл.Пустая() Тогда
				СсылкаНаФайл = СсылкиФайлов.Получить(Файл);
			КонецЕсли;
			
			Текст = СтрЗаменить(Текст, "{#files_" + Файл.УникальныйИдентификатор() + "#}", СсылкаНаФайл);
		Иначе
			Прервать;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Процедура ВставитьСсылкиНаРесурсы(Текст)
	Если СтрНайти(Текст, "{#res_", НаправлениеПоиска.СНачала) = 0 Тогда
		Возврат;
	КонецЕсли;
	
	СсылкиРесурсов = ПолучитьСсылкиРесурсов();
	Пока Истина Цикл
		ПозНач = СтрНайти(Текст, "{#res_", НаправлениеПоиска.СНачала);
		Если ПозНач > 0 Тогда
			ПозКон = СтрНайти(Текст, "#}", НаправлениеПоиска.СНачала, ПозНач);
			СсылкаНаРесурс = "";
			УИД = Сред(Текст, ПозНач, ПозКон - ПозНач);
			УИД = СтрЗаменить(УИД, "{#res_", "");
			Ресурс = Справочники.Web1C_Ресурсы.ПолучитьСсылку(Новый УникальныйИдентификатор(УИД));
			Если Не Ресурс.Пустая() Тогда
				СсылкаНаРесурс = СсылкиРесурсов.Получить(Ресурс);
			КонецЕсли;
			
			Текст = СтрЗаменить(Текст, "{#res_" + Ресурс.УникальныйИдентификатор() + "#}", СсылкаНаРесурс);
		Иначе
			Прервать;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Процедура ВставитьБлокиТекстов(Текст, ДанныеПользователя)
	Пока Истина Цикл
		ПозНач = СтрНайти(Текст, "{#Блок_", НаправлениеПоиска.СНачала);
		Если ПозНач > 0 Тогда
			ПозКон = СтрНайти(Текст, "#}", НаправлениеПоиска.СНачала, ПозНач);
			ТекстМакета = "";
			УИД = Сред(Текст, ПозНач, ПозКон - ПозНач);
			УИД = СтрЗаменить(УИД, "{#Блок_", "");
			Макет = Справочники.Web1C_Компоненты.ПолучитьСсылку(Новый УникальныйИдентификатор(УИД));
			Если Не Макет.Пустая() Тогда
				вхПараметры = Новый Структура;
				//ФиксированныеПараметры
				вхПараметры.Вставить("ОбъектАвторизации", ДанныеПользователя.ОбъектАвторизации);
				вхПараметры.Вставить("КоличествоЗаказовНаСтранице", 10);
				//вхПараметры.Вставить("НомерСтраницы", ДанныеПользователя.НомерСтраницы);
				
				//переменные параметры
				Если ДанныеПользователя.Свойство("Параметры") Тогда
					Для каждого ТекПараметр Из ДанныеПользователя.Параметры Цикл
						вхПараметры.Вставить(ТекПараметр.Ключ, ТекПараметр.Значение);
					КонецЦикла;
				КонецЕсли;
				
				МакетОб = Макет.ПолучитьОбъект();
				ТекстМакета = МакетОб.ПолучитьТекстМакета(вхПараметры);
			КонецЕсли;
			
			Текст = СтрЗаменить(Текст, "{#Блок_" + Макет.УникальныйИдентификатор() + "#}", ТекстМакета);
		Иначе
			Прервать;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Процедура УдалитьПеременные(Текст)
	//удаление всех слов, которые начинаются с {# и заканчиваются на #}
	Пока Истина Цикл
		ПозНач = СтрНайти(Текст, "{#", НаправлениеПоиска.СНачала);
		Если ПозНач > 0 Тогда
			ПозКон = СтрНайти(Текст, "#}", НаправлениеПоиска.СНачала, ПозНач);
			ДлинаСлова = ПозКон + 2 - ПозНач;
			СловоДляЗамены = Сред(Текст, ПозНач, ДлинаСлова);
			Текст = СтрЗаменить(Текст, СловоДляЗамены, "");
		Иначе
			Прервать;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры



Процедура ОбработатьТекстСтраницыДляПроверки(Текст) Экспорт
	Текст = СтрЗаменить(Текст, "/{#Имя_Публикации#}", Константы.Web1C_ПолныйАдресПубликации.Получить());	
КонецПроцедуры

// Функция ПолучитьСписокПеременных
//
// Описание:
// возвращает список переменных, доступных для встраивание в код стиля, скрипта или страницы
//
// Параметры (название, тип, дифференцированное значение)
//  
// Возвращаемое значение: 
//  СписокЗначений
Функция ПолучитьСписокПеременных() Экспорт
	СписокПеременных = Новый СписокЗначений;
	
	//глобальные переменные
	СписокПеременных.Добавить("{#Имя_Публикации#}", "Имя публикации");
	СписокПеременных.Добавить("{#ИмяПользователя#}", "Имя пользователя");
	СписокПеременных.Добавить("{#ОшибкаАвторизации#}", "Ошибка авторизации");
	
	Web1C_ВыборкаДанных.ДополнитьСписокПеременных(СписокПеременных);
	
	Возврат СписокПеременных;
КонецФункции //ПолучитьСписокПеременных

// Функция ПолучитьСписокСсылок
//
// Описание:
//	описывает все ссылки на странички из вашего http-сервиса
//	чтобы их можно было быстро вставлять на страничке в тег "href" к примеру
// Параметры (название, тип, дифференцированное значение)
//
// Возвращаемое значение: 
//	Список значений
Функция ПолучитьСписокСсылок() Экспорт
	СписокСсылок = Новый СписокЗначений;
	СписокСсылок.Добавить("/{#Имя_Публикации#}/index", "Стартовая страница");
	СписокСсылок.Добавить("/{#Имя_Публикации#}/index/login", "Страница авторизации");
	СписокСсылок.Добавить("/{#Имя_Публикации#}/index/logout", "Страница завершения сеанса");
	Web1C_ВыборкаДанных.ДополнитьСписокСсылок(СписокСсылок);
	
	Возврат СписокСсылок;
КонецФункции //ПолучитьСписокСсылок

Процедура ПолучитьОтветПоURL(URL, Ответ, ДанныеПользователя) Экспорт
	КодСостояния = 200;
	
	//обработка
	URL = СтрЗаменить(URL, "http://", "");
	URL = СтрЗаменить(URL, "https://", "");
	
	HTTPСоединение = Новый HTTPСоединение("");
	Попытка
		ОтветHTTP = HTTPСоединение.Получить(Новый HTTPЗапрос(URL));
	Исключение
		КодСостояния = 404;
		ОШибка = ОписаниеОшибки();
	КонецПопытки;
	
	Ответ.КодСостояния = КодСостояния;
	
	Ответ.Заголовки.Вставить("Content-Type","text/html; charset=utf-8");
	//Ответ.Заголовки.Вставить("Access-Control-Allow-Origin","localhost");
	
	//заполняем заголовки из структуры ответа
	//Ответ.Заголовки.Вставить(Ключ, Значение);
	
	
	Если КодСостояния  = 200 Тогда
		Ответ.УстановитьТелоИзСтроки(ОтветHTTP.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8));
		//Ответ.УстановитьТелоИзСтроки("Привет. Проверка загрузки контента");
	Иначе
		Ответ.УстановитьТелоИзСтроки(Страница404(ДанныеПользователя));
	КонецЕсли;
КонецПроцедуры

Функция СериализоватьВJSON(Данные, ЭкранированиеСимволов = истина) Экспорт 
	Результат = "";
	
	Запись = Новый ЗаписьJSON;
	Запись.УстановитьСтроку(Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Авто, , Истина, ?(ЭкранированиеСимволов, ЭкранированиеСимволовJSON.СимволыВнеASCII, ЭкранированиеСимволовJSON.СимволыВнеBMP))); 
	ЗаписатьJSON(ЗАпись, Данные);
	Результат = ЗАпись.Закрыть();
	
	Возврат Результат;
КонецФункции

// Функция ПолучитьРесурсВОтвет
//
// Описание: вовзращает HTTPСервисОтвет с данными ресурса,
//	найденный по относиетльному URL
// Параметры (название, тип, дифференцированное значение)
//	ОтносительныйURL, Строка, свойство из http-запроса
// Возвращаемое значение: 
//  HTTPСервисОтвет
Функция ПолучитьРесурсВОтвет(ОтносительныйURL) Экспорт 
	Ответ = Новый HTTPСервисОтвет(200);
	
	мЗапрос = Новый Запрос;
	мЗапрос.Текст = 
	"ВЫБРАТЬ первые 1
	|	Ресурсы.Ссылка КАК Ссылка,
	|	Ресурсы.ВидРесурса КАК ВидРесурса,
	|	Ресурсы.Текст КАК Текст,
	|	Ресурсы.ТекстовыйФайл КАК ТекстовыйФайл,
	|	Ресурсы.Файл КАК Файл
	|ИЗ
	|	Справочник.Web1C_Ресурсы КАК Ресурсы
	|ГДЕ
	|	Ресурсы.ПутьВеб = &ПутьВеб";
	мЗапрос.УстановитьПараметр("ПутьВеб", ОтносительныйURL);
	РезультатЗапроса = мЗапрос.Выполнить();
	
	
	Если РезультатЗапроса.Пустой() Тогда
		Ответ.КодСостояния = 404;
	Иначе
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		Ответ.КодСостояния = 200;
		
		Если Выборка.ВидРесурса = ПредопределенноеЗначение("Перечисление.Web1C_ВидыРесурса.Изображение") Тогда
			Ответ.УстановитьТелоИзДвоичныхДанных(Выборка.Файл.Получить());
			
			Ответ.Заголовки.Вставить("accept-ranges", "bytes");
		ИначеЕсли Выборка.ВидРесурса = ПредопределенноеЗначение("Перечисление.Web1C_ВидыРесурса.Стиль") Тогда
			Ответ.Заголовки.Вставить("Content-Type","text/css");
			Если Выборка.ТекстовыйФайл Тогда
				Текст = Выборка.Текст;
				Web1C_ФормированиеОтветов.ОбработатьТекстСтраницы(Текст, Неопределено);
				Ответ.УстановитьТелоИзСтроки(Текст);
			Иначе
				ДД_Файла = Выборка.Файл.Получить();
				Ответ.УстановитьТелоИзДвоичныхДанных(ДД_Файла);
			КонецЕсли;
		ИначеЕсли Выборка.ВидРесурса = ПредопределенноеЗначение("Перечисление.Web1C_ВидыРесурса.Скрипт") Тогда
			Ответ.Заголовки.Вставить("Content-Type","text/javascript");
			Если Выборка.ТекстовыйФайл Тогда
				Текст = Выборка.Текст;
				Web1C_ФормированиеОтветов.ОбработатьТекстСтраницы(Текст, Неопределено);
				Ответ.УстановитьТелоИзСтроки(Текст);
			Иначе
				ДД_Файла = Выборка.Файл.Получить();
				Ответ.УстановитьТелоИзДвоичныхДанных(ДД_Файла);
			КонецЕсли;
		ИначеЕсли Выборка.ВидРесурса = ПредопределенноеЗначение("Перечисление.Web1C_ВидыРесурса.Файл") Тогда
			Если Выборка.ТекстовыйФайл Тогда
				Текст = Выборка.Текст;
				Ответ.УстановитьТелоИзСтроки(Текст);
			Иначе
				ДД_Файла = Выборка.Файл.Получить();
				Ответ.УстановитьТелоИзДвоичныхДанных(ДД_Файла);
			КонецЕсли;
			Ответ.Заголовки.Вставить("accept-ranges", "bytes");
		КонецЕсли;
	КонецЕсли;
	
	Возврат Ответ;
КонецФункции

// Процедура проверяет есть в конце строки слеш(или обратный)
//  и если его нет, то добавляет
// Параметры (название, тип, дифференцированное значение)
//  Значение - тип Строка
//  Обратный - тип Булево
Функция ПроверитьДобавитьСлеш(Значение, Обратный = Ложь)
	Если Обратный Тогда
		Слеш = "\";
	Иначе
		Слеш = "/";
	КонецЕсли;
	
	Если Прав(Значение, 1) <> Слеш Тогда
		Значение = Значение + Слеш;
	КонецЕсли;
КонецФункции

// Функция формирует значение NextURL из параметров http-запроса
//  поскольку в БазовыйURL не приходит порт, а в щаголовке Host порт присутствует
// Параметры (название, тип, дифференцированное значение)
//  БазовыйURL - Строка
//  ОтносительныйURL - Строка
//  Хост - Строка
// Возвращаемое значение: 
//  Строка
Функция СформироватьNextURL(БазовыйURL, ОтносительныйURL, Хост) Экспорт 
	Результат = "";
	
	СтруктураURL = КоннекторHTTP.РазобратьURL(БазовыйURL);
	
	Если ЗначениеЗаполнено(Хост) И СтруктураURL.Сервер + ?(СтруктураURL.Порт = 0,"", ":" + Формат(СтруктураURL.Порт, "ЧГ=0")) <> Хост Тогда
		//Результат = СтрШаблон("%1://%2%3", СтруктураURL.Схема, Хост, СтруктураURL.Путь);
		Результат = СтруктураURL.Путь;
	Иначе
		Результат = БазовыйURL + ОтносительныйURL;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции
