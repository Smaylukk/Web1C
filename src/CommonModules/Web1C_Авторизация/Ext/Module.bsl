﻿
Процедура ЛогинЛогаут(Запрос, Ответ) Экспорт
	
	Действие = Запрос.ПараметрыURL["Действие"];
	
	Если Действие = "login" Тогда
		
		ПараметрыЗапроса = Web1C_ФормированиеОтветов.ПолучитьПараметры(Запрос.ПолучитьТелоКакСтроку());
		
		Логин = РаскодироватьСтроку(ПараметрыЗапроса["login"], СпособКодированияСтроки.КодировкаURL);
		Логин = СокрЛП(СтрЗаменить(Логин, "+", " "));
		Пароль = ПараметрыЗапроса["password"];
		Запоминать = ПараметрыЗапроса.Свойство("remember__checkbox") И ПараметрыЗапроса["remember__checkbox"] = "on";  
		
		//Если НЕ(ЗначениеЗаполнено(Логин) И ЗначениеЗаполнено(Пароль)) Тогда 
		//	Возврат;
		//КонецЕсли;
		
		Если НЕ(ЗначениеЗаполнено(Логин)) Тогда 
			Возврат;
		КонецЕсли;
		
		ДанныеАвторизации = АвторизоватьсяБазе(Логин, Пароль);
		
		Если ДанныеАвторизации.Успех Тогда
			//дополнительная проверка на отключенную учетку
			ДанныеАвторизации.Вставить("Сессия", Неопределено);
			ДанныеПользователя = Web1C_ВыборкаДанных.ПолучитьДанныеПользователя(ДанныеАвторизации);
			Если ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДанныеПользователя.ОбъектАвторизации, "Отключен") = Истина Тогда
				П = Новый Структура; 
				П.Вставить("ОшибкаАвторизации", "Ваш аккаунт отключен! Обратитесь к вашему менеджеру.");
				Web1C_ФормированиеОтветов.ПолучитьОтвет(ПредопределенноеЗначение("Перечисление.Web1C_ВидыСтраниц.СтраницаАвторизации"), Ответ, П);
			Иначе
				Попытка Браузер = Запрос.Заголовки.Получить("User-Agent"); Исключение Браузер = ""; КонецПопытки; 
				Попытка IPАдрес = Запрос.Заголовки.Получить("Client-IP"); Исключение IPАдрес = ""; КонецПопытки; 
				
				НоваяСессия = СоздатьСессию(ДанныеАвторизации.ОбъектАвторизации, Запоминать, Браузер, IPАдрес);
				
				Web1C_УправлениеКуки.CoockieВОтвет(Ответ, "hash_login", НоваяСессия.id, НоваяСессия.Истекает, "/");
				
				ИнфоОПользователе = Новый Структура;
				ИнфоОПользователе.Вставить("ОбъектАвторизации", ДанныеАвторизации.ОбъектАвторизации);
				ИнфоОПользователе.Вставить("Сессия", НоваяСессия.id);
				
				Web1C_Авторизация.ЗаписатьАктивность(Запрос, ДанныеАвторизации.ОбъектАвторизации, "Авторизация");
			КонецЕсли;
		Иначе
			П = Новый Структура; 
			П.Вставить("ОшибкаАвторизации", ДанныеАвторизации.ТекстОшибки);
			Web1C_ФормированиеОтветов.ПолучитьОтвет(ПредопределенноеЗначение("Перечисление.Web1C_ВидыСтраниц.СтраницаАвторизации"), Ответ, П);
		КонецЕсли;
		
	ИначеЕсли Действие = "logout" Тогда
		Куки = Web1C_УправлениеКуки.ПолучитьCoockie(Запрос);
		hash_login = Куки["hash_login"];
		ДеактивироватьСессию(hash_login);
		
		Web1C_ФормированиеОтветов.ПолучитьОтвет(ПредопределенноеЗначение("Перечисление.Web1C_ВидыСтраниц.СтраницаАвторизации"), Ответ, Неопределено);
	КонецЕсли;
	
		
КонецПроцедуры

Функция СоздатьСессию(ОбъектАвторизации, Запомнинать, Браузер, IPАдрес) Экспорт 
	Результат = Новый Структура;
	
	Сессия = Строка(Новый УникальныйИдентификатор());
	МЗ = РегистрыСведений.Web1C_Сессии.СоздатьМенеджерЗаписи();
	МЗ.id = Сессия;
	МЗ.ОбъектАвторизации = ОбъектАвторизации;
	
	СрокДействия = ТекущаяДата() + 86400 * ?(Запомнинать, 30, 15);
	МЗ.Истекает = СрокДействия;
	МЗ.ДатаУстановки = ТекущаяДата();
	МЗ.Браузер = Браузер; 
	МЗ.IPАдрес = IPАдрес; 
	МЗ.Записать();
	
	Результат.Вставить("id", Сессия);
	Результат.Вставить("Истекает", СрокДействия);
	
	Возврат Результат;
КонецФункции

Процедура ДеактивироватьСессию(hash_login) Экспорт 
	Если ЗначениеЗаполнено(hash_login) Тогда
		МЗ = РегистрыСведений.Web1C_Сессии.СоздатьМенеджерЗаписи();
		МЗ.id = hash_login;
		МЗ.Прочитать();
		Если МЗ.Выбран() Тогда
			МЗ.Неактивная = Истина;
			Мз.Записать();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Функция СессияАктивна(Запрос, Операция)Экспорт
	Результат = Новый Структура("Успех, ОбъектАвторизации, Сессия", Ложь, "", "");
	
	Куки = Web1C_УправлениеКуки.ПолучитьCoockie(Запрос); 
	hash_login = Куки.Получить("hash_login");
	Если ЗначениеЗаполнено(hash_login) Тогда
		ЗапросКБазе = Новый Запрос;
		ЗапросКБазе.Текст = 
		"ВЫБРАТЬ
		|	Сессии.ОбъектАвторизации КАК ОбъектАвторизации,
		|	Сессии.id КАК Сессия
		|ИЗ
		|	РегистрСведений.Web1C_Сессии КАК Сессии
		|ГДЕ
		|	Сессии.id = &id
		|	И Сессии.Истекает >= &ТекущаяДата
		|	И Сессии.Неактивная = ЛОЖЬ";
		ЗапросКБазе.УстановитьПараметр("id", hash_login);
		ЗапросКБазе.УстановитьПараметр("ТекущаяДата", УниверсальноеВремя(ТекущаяДата()));
		Выборка = ЗапросКБазе.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			Результат.Вставить("Успех", Истина);
			Результат.Вставить("ОбъектАвторизации", Выборка.ОбъектАвторизации);
			Результат.Вставить("Сессия", Выборка.Сессия);
			
			Если Не ПустаяСтрока(Операция) Тогда
				Web1C_Авторизация.ЗаписатьАктивность(Запрос, Выборка.ОбъектАвторизации, Операция);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции


Функция АвторизоватьсяБазе(Логин, Пароль)
	Результат = Новый Структура("Успех, ОбъектАвторизации, ТекстОшибки", Ложь, "", "");
	
	// АВТОРИЗАЦИЯ ПО ОБЪЕКТА МАВТОРИЗАЦИИ
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ОбъектыАвторизации.Ссылка КАК Ссылка,
	|	ОбъектыАвторизации.Пароль КАК Пароль
	|ИЗ
	|	Справочник.Web1C_ОбъектыАвторизации КАК ОбъектыАвторизации
	|ГДЕ
	|	ОбъектыАвторизации.Логин = &Логин
	|	И ОбъектыАвторизации.Отключен = ЛОЖЬ
	|	И ОбъектыАвторизации.ПометкаУдаления = ЛОЖЬ";
	Запрос.УстановитьПараметр("Логин", СокрЛП(Логин));
	РезультатЗапроса = Запрос.Выполнить();
	
	Если Не РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		Если Выборка.Пароль = Пароль Тогда
			//надо прописать авторизацию по паролю
			Результат.Вставить("Успех", Истина);
			Результат.Вставить("ОбъектАвторизации", Выборка.Ссылка);
		Иначе
			Результат.Вставить("ТекстОшибки", "Не правильно введен пароль");
		КонецЕсли;
	Иначе
		Результат.Вставить("ТекстОшибки", "Не найден объект авторизации");
	КонецЕсли;
	
	
	// АВТОРИЗАЦИЯ ПО ПОЛЬЗОВАТЕЛЮ ИБ
	
	//Пользователь = Неопределено;
	//Если Пользователи.ПользовательИБЗанят(Логин, Пользователь) Тогда
	//	Свойства = Неопределено;
	//	Свойства = Пользователи.СвойстваПользователяИБ(Пользователь.УникальныйИдентификатор);
	//	ХешПароля = Обработки.Web1C_Хеширование.Создать()._SHA1_BASE64(Пароль);
	//	СохраняемоеЗначениеПароля = Свойства.СохраняемоеЗначениеПароля;
	//	Если СтрНайти(СохраняемоеЗначениеПароля, ХешПароля) > 0 Тогда
	//		//надо прописать авторизацию по паролю
	//		Результат.Вставить("Успех", Истина);
	//		Результат.Вставить("Пользователь", НайтиПользователяВСправочникеПоИдентификатору(Пользователь.УникальныйИдентификатор));
	//	Иначе
	//		Результат.Вставить("ТекстОшибки", "Не правильно введен пароль");
	//	КонецЕсли;
	//Иначе
	//	Результат.Вставить("ТекстОшибки", "Не найден пользователь ИБ");
	//КонецЕсли;
	
	// ДОМЕННАЯ АВТОРИЗАЦИЯ
	
	//	Если ПроверитьПользователяДомена(Логин, Пароль) Тогда
	//		ИмяПользователя = Логин;
	//		Если СтрНайти(ИмяПользователя, "@") > 0 Тогда
	//			ИмяПользователя = Лев(ИмяПользователя, СтрНайти(ИмяПользователя, "@") - 1);
	//		КонецЕсли;
	//		Для каждого ПользовательИБ Из ПользователиИнформационнойБазы.ПолучитьПользователей() Цикл
	//			Если Врег(ПользовательИБ.ПользовательОС) = Врег(ИмяПользователя) Или СтрНайти(Врег(ПользовательИБ.ПользовательОС), Врег(ИмяПользователя)) Тогда
	//				Пользователь = Справочники.Пользователи.НайтиПоРеквизиту("ИдентификаторПользователяИБ", ПользовательИБ.УникальныйИдентификатор);
	//				Если ЗначениеЗаполнено(Пользователь) Тогда
	//					Результат.Вставить("Успех", Истина);
	//					Результат.Вставить("Пользователь", Пользователь);
	//				Иначе
	//					Результат.Вставить("ТекстОшибки", "Не правильно введен пользователь");
	//				КонецЕсли;
	//				
	//				Прервать;
	//			Иначе
	//				Результат.Вставить("ТекстОшибки", "Не правильно введен пользователь");
	//			КонецЕсли;
	//		КонецЦикла;
	//	Иначе
	//		Результат.Вставить("ТекстОшибки", "Не правильно введен пользователь");
	//	КонецЕсли;
	//КонецЕсли;
	
	Возврат Результат;
КонецФункции

Процедура ЗаписатьАктивность(Запрос, ОбъектАвторизации, Операция) Экспорт
	Куки = Web1C_УправлениеКуки.ПолучитьCoockie(Запрос); 
	hash_login = Куки["hash_login"];
	
	МЗ = РегистрыСведений.Web1C_АктивностьПользователей.СоздатьМенеджерЗаписи();
	МЗ.id = hash_login;
	МЗ.ДатаАктивности = ТекущаяДата();
	МЗ.ОбъектАвторизации = ОбъектАвторизации;
	МЗ.Операция = Операция;
	
	Попытка МЗ.Браузер = Запрос.Заголовки.Получить("User-Agent"); Исключение КонецПопытки;
	Попытка МЗ.IPАдрес = Запрос.Заголовки.Получить("Client-IP"); Исключение КонецПопытки;
	
	МЗ.Записать();
	
КонецПроцедуры

Функция ПроверитьПользователяДомена(ИмяПользователя, Пароль)
	
	dso = ПолучитьCOMОбъект("LDAP:");
	
	Попытка
		obj = dso.OpenDSObject("LDAP://" + Константы.Web1C_Домен.Получить(), ИмяПользователя, Пароль, 1);
		
		Возврат Истина;
		
	Исключение
		Описание = ОписаниеОшибки();
		
		Если Найти(Описание, "имя пользователя или пароль не опознаны.") > 0 Тогда
			Сообщить("Неверный пароль");
			
		Иначе
			Сообщить(Описание);
			
		КонецЕсли;
		
		Возврат Ложь;
		
	КонецПопытки;
	
КонецФункции 

Функция СоздатьТокенДляВхода(ОбъектАвторизации) Экспорт 
	Результат = Неопределено;
	
	МЗ = РегистрыСведений.Web1C_ТокеныДляВхода.СоздатьМенеджерЗаписи();
	МЗ.Токен = Строка(Новый УникальныйИдентификатор());
	МЗ.ДатаВыдачи = ТекущаяДата();
	МЗ.СрокДействия = ТекущаяДата() + 3600;
	МЗ.ОбъектАвторизации = ОбъектАвторизации;
	МЗ.Ответственный = ПараметрыСеанса.ТекущийПользователь;
	МЗ.АдресДляВхода = Web1C_ОбщегоНазначения.ПолныйАдресПубликации() + "/index/token?id=" + МЗ.Токен ;
	
	Попытка
		МЗ.Записать();
		Результат = МЗ.Токен;
	Исключение
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Ошибка создания токена для входа - " + ОписаниеОшибки());
	КонецПопытки;
	
	Возврат Результат;
КонецФункции

Функция ПолучитьОписаниеТокена(Токен) Экспорт 
	Результат = Новый Структура("Токен, ДатаВыдачы, СрокДействия, ОбъектАвторизации, Использован, ОбъектАвторизацииОтключен");
	
	МЗ = РегистрыСведений.Web1C_ТокеныДляВхода.СоздатьМенеджерЗаписи();
	Мз.Токен = Токен;
	МЗ.Прочитать();
	Если Мз.Выбран() Тогда
		ЗаполнитьЗначенияСвойств(Результат, МЗ);
		
		Результат.Вставить("ОбъектАвторизацииОтключен", ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Результат.ОбъектАвторизации, "Отключен"));
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

Процедура ДеактивироватьТокен(Токен, Сессия) Экспорт 
	МЗ = РегистрыСведений.Web1C_ТокеныДляВхода.СоздатьМенеджерЗаписи();
	Мз.Токен = Токен;
	МЗ.Прочитать();
	Если Мз.Выбран() Тогда
		МЗ.Сессия = Сессия;
		МЗ.Использован = Истина;
		
		МЗ.Записать();
	КонецЕсли;
КонецПроцедуры

Функция НайтиПользователяВСправочникеПоИдентификатору(ИдентификаторПользователяИБ)  
	Результат = Неопределено;
	ТекущийПользовательИБ = ПользователиИнформационнойБазы.ТекущийПользователь();
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("ИдентификаторПользователяИБ", ИдентификаторПользователяИБ);
	
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ВнешниеПользователи.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ВнешниеПользователи КАК ВнешниеПользователи
	|ГДЕ
	|	ВнешниеПользователи.ИдентификаторПользователяИБ = &ИдентификаторПользователяИБ";
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		
		Если Не ВнешниеПользователи.ИспользоватьВнешнихПользователей() Тогда
			Возврат НСтр("ru = 'Внешние пользователи отключены.'");
		КонецЕсли;
		
		Результат = Выборка.Ссылка;
		
		Возврат Результат;
	КонецЕсли;

	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Пользователи.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|ГДЕ
	|	Пользователи.ИдентификаторПользователяИБ = &ИдентификаторПользователяИБ";
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Результат = Выборка.Ссылка;
		Возврат Результат;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции