#Использовать v8runner
// #Использовать clientSSH

Перем мЖурналы;
Перем мКонфигуратор;
Перем мРепозиторий;
Перем мКаталогОбработок;
Перем мИмяОбработкиВыгрузкиЗагрузки;

Процедура УстановитьПараметры(Конфигуратор, Репозиторий, КаталогОбработок, Журналы) Экспорт

	мЖурналы 			= Журналы;
	мКонфигуратор 		= Конфигуратор;
	мРепозиторий 		= Репозиторий;
	мКаталогОбработок 	= КаталогОбработок;

	КаталогСкрипта = ТекущийСценарий().Каталог;
	мИмяОбработкиВыгрузкиЗагрузки = ОбъединитьПути(КаталогСкрипта, "..\tools\ВыгрузкаЗагрузкаДополнительныхОтчетовИОбработок.epf");

КонецПроцедуры

Процедура ВыполнитьРазборкуОбработок() Экспорт
	
	ШаблонКаталогаОбработки = ОбъединитьПути(мРепозиторий, "%1");
	КомандаРазборки = "/DumpExternalDataProcessorOrReportToFiles ""%1"" ""%2""";
	
	ТекстЖурнала = "";
	мКонфигуратор.УстановитьИмяФайлаСообщенийПлатформы(мЖурналы.ЖурналРазборкиОбработок);

	мЖурналы.ОсновнойЖурнал.Информация("Начало разборки обработок");

	Хеширование = Новый ХешированиеДанных(ХешФункция.SHA1);

	УспешноРазобрано = 0;
	ВнешниеОбработки = ТаблицаОбработокДляРазбора(); 
	Для Каждого Обработка Из ВнешниеОбработки Цикл
		КаталогОбработки = СтрШаблон(ШаблонКаталогаОбработки, Обработка.Идентификатор);
		СоздатьКаталог(КаталогОбработки);
		
		РезультатРазборки = Истина;

		ПараметрыЗапуска = мКонфигуратор.ПолучитьПараметрыЗапуска();
		ПараметрыЗапуска.Добавить(СтрШаблон(КомандаРазборки, КаталогОбработки, Обработка.Путь));
		Попытка
			мКонфигуратор.ВыполнитьКоманду(ПараметрыЗапуска);
		Исключение
			мЖурналы.ОсновнойЖурнал.Ошибка(СтрШаблон("Не удалось разобрать обработку: %1", Обработка.Путь));
			РезультатРазборки = Ложь;
		КонецПопытки;

		Если РезультатРазборки Тогда
			УспешноРазобрано = УспешноРазобрано + 1;
			ЗаписатьХешСуммуОбработки(Хеширование, КаталогОбработки, Обработка.Путь);
			// ЗаписьТекста = Новый ЗаписьТекста(ОбъединитьПути(КаталогОбработки, "hashfile.txt"), КодировкаТекста.UTF8, Ложь);
			// ЗаписьТекста.Записать(Обработка.ХешСумма);
			// ЗаписьТекста.Закрыть();
		КонецЕсли;

		мКонфигуратор.УстановитьИмяФайлаСообщенийПлатформы(мЖурналы.ЖурналРазборкиОбработок, Ложь);

	КонецЦикла;

	мЖурналы.ОсновнойЖурнал.Информация(СтрШаблон("Успешно разобрано %1 из %2 обработок", 
											УспешноРазобрано, ВнешниеОбработки.Количество()));
	
КонецПроцедуры

Процедура ВыполнитьСборкуОбработок() Экспорт
	
	КомандаСборки = "/LoadExternalDataProcessorOrReportFromFiles ""%1"" ""%2""";
	ШаблонИмениОбработки = ОбъединитьПути(мКаталогОбработок, "%1");
	
	ТекстЖурнала = "";
	мКонфигуратор.УстановитьИмяФайлаСообщенийПлатформы(мЖурналы.ЖурналСборкиОбработок);

	мЖурналы.ОсновнойЖурнал.Информация("Начало сборки обработок");

	Хеширование = Новый ХешированиеДанных(ХешФункция.SHA1);

	УспешноСобрано = 0;
	ВнешниеОбработки = ТаблицаОбработокДляСборки(); 
	Для Каждого Обработка Из ВнешниеОбработки Цикл
		ПутьКОбработке = СтрШаблон(ШаблонИмениОбработки, Обработка.Идентификатор);
		
		РезультатСборки = Истина;

		ПараметрыЗапуска = мКонфигуратор.ПолучитьПараметрыЗапуска();
		ПараметрыЗапуска.Добавить(СтрШаблон(КомандаСборки, Обработка.КорневойФайл, ПутьКОбработке));
		Попытка
			мКонфигуратор.ВыполнитьКоманду(ПараметрыЗапуска);
		Исключение
			мЖурналы.ОсновнойЖурнал.Ошибка(СтрШаблон("Не удалось собрать обработку: %1", Обработка.КорневойФайл));
			РезультатСборки = Ложь;
		КонецПопытки;

		Если РезультатСборки Тогда
			ЗаписатьХешСуммуОбработки(Хеширование, Обработка.КорневойФайл, ПутьКОбработке);
			УспешноСобрано = УспешноСобрано + 1;
		КонецЕсли;

		мКонфигуратор.УстановитьИмяФайлаСообщенийПлатформы(мЖурналы.ЖурналСборкиОбработок, Ложь);

	КонецЦикла;

	мЖурналы.ОсновнойЖурнал.Информация(СтрШаблон("Успешно собрано %1 из %2 обработок. Обновлены хеши в репозитории", 
													УспешноСобрано, ВнешниеОбработки.Количество()));

КонецПроцедуры

Процедура ВыполнитьЗагрузкуОбработокВИнформационнуюБазу() Экспорт
	
	мЖурналы.ОсновнойЖурнал.Информация("Начало загрузки обработок из ИБ");

	ПараметрыОбработки = ПараметрыЗапускаВнешнейОбработки();
	ПараметрыОбработки.РежимРаботы = "Загрузка";
	ПараметрыОбработки.КаталогОбработок = мКаталогОбработок;
	ПараметрыОбработки.ПутьКЛогам = мЖурналы.ЖурналЗагрузкиОбработок;
	КлючЗапуска = КлючЗапускаВнешнейОбработки(ПараметрыОбработки);
	
	ФайлЛога = ПолучитьИмяВременногоФайла(".log");
	мКонфигуратор.УстановитьИмяФайлаСообщенийПлатформы(ФайлЛога);

	ВыполнениеОбработки = СтрШаблон("/execute""%1""", мИмяОбработкиВыгрузкиЗагрузки);
	
	Попытка
		мКонфигуратор.ЗапуститьВРежимеПредприятия(КлючЗапуска, , ВыполнениеОбработки);
		ТекстСообщения = СтрШаблон("Завершена загрузка обработок из ИБ. Подробности: %1", мЖурналы.ЖурналЗагрузкиОбработок);
	Исключение
		ТекстСообщения = "Не удалось выполнить загрузку обработок из ИБ";
	КонецПопытки;

	СкопироватьЛогИзВременногоФайла(ФайлЛога, мЖурналы.ЖурналЗагрузкиОбработок);

	мЖурналы.ОсновнойЖурнал.Информация(ТекстСообщения);	

КонецПроцедуры

Процедура ВыполнитьВыгрузкуОбработокИзИнформационнойБазы() Экспорт
		
	мЖурналы.ОсновнойЖурнал.Информация("Начало выгрузки обработок из ИБ");

	ПараметрыОбработки = ПараметрыЗапускаВнешнейОбработки();
	ПараметрыОбработки.РежимРаботы = "Выгрузка";
	ПараметрыОбработки.КаталогОбработок = мКаталогОбработок;
	ПараметрыОбработки.ПутьКЛогам = мЖурналы.ЖурналВыгрузкиОбработок;
	КлючЗапуска = КлючЗапускаВнешнейОбработки(ПараметрыОбработки);

	ФайлЛога = ПолучитьИмяВременногоФайла(".log");
	мКонфигуратор.УстановитьИмяФайлаСообщенийПлатформы(ФайлЛога);

	ВыполнениеОбработки = СтрШаблон("/execute""%1""", мИмяОбработкиВыгрузкиЗагрузки);
	Попытка
		мКонфигуратор.ЗапуститьВРежимеПредприятия(КлючЗапуска, , ВыполнениеОбработки);
		ТекстСообщения = СтрШаблон("Завершена выгрузка обработок из ИБ. Подробности: %1", мЖурналы.ЖурналВыгрузкиОбработок);
	Исключение
		ТекстСообщения = "Не удалось выполнить выгрузку обработок из ИБ";
	КонецПопытки;

	СкопироватьЛогИзВременногоФайла(ФайлЛога, мЖурналы.ЖурналВыгрузкиОбработок);

	мЖурналы.ОсновнойЖурнал.Информация(ТекстСообщения);		

КонецПроцедуры

Процедура СкопироватьЛогИзВременногоФайла(Источник, Приемник)

	ЛогПлатформы = Новый ЧтениеТекста(Источник);
	ЛогОбработки = Новый ЗаписьТекста(Приемник, , , Истина);
	ЛогОбработки.ЗаписатьСтроку(ЛогПлатформы.Прочитать());

	ЛогПлатформы.Закрыть();
	ЛогОбработки.Закрыть();

	УдалитьФайлы(Источник);

КонецПроцедуры

Функция ПараметрыЗапускаВнешнейОбработки()
	
	Параметры = Новый Структура;
	
	Параметры.Вставить("РежимРаботы");
	Параметры.Вставить("КаталогОбработок");
	Параметры.Вставить("ПутьКЛогам");
	Параметры.Вставить("ЗавершитьРаботуСистемы");
	
	Возврат Параметры;
	
КонецФункции

Функция КлючЗапускаВнешнейОбработки(Параметры)
	
	КлючЗапуска = "";
	Для Каждого КлючИЗначение Из Параметры Цикл
		КлючЗапуска = КлючЗапуска
			+ ?(Не ПустаяСтрока(КлючЗапуска), ";", "")
			+ СтрШаблон("%1&%2", КлючИЗначение.Ключ, КлючИЗначение.Значение);
	КонецЦикла;
	
	Возврат КлючЗапуска;
	
КонецФункции

Функция ХешТаблицаОбработок()

	ХешТаблица = Новый ТаблицаЗначений();
	ХешТаблица.Колонки.Добавить("Идентификатор");
	ХешТаблица.Колонки.Добавить("ХешСумма");
	ХешТаблица.Колонки.Добавить("Путь");
	ХешТаблица.Колонки.Добавить("КорневойФайл");

	Возврат ХешТаблица;

КонецФункции

Функция ХешТаблицаОбработокРепозитория()

	мЖурналы.ОсновнойЖурнал.Информация("Получение списка обработок репозитория");

	ХешТаблица = ХешТаблицаОбработок();

	КаталогиОбработок = НайтиФайлы(мРепозиторий, ПолучитьМаскуВсеФайлы());
	Для Каждого Каталог Из КаталогиОбработок Цикл		
		Если Не Каталог.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;

		СодержимоеКаталога = НайтиФайлы(Каталог.ПолноеИмя, "*.xml");
		Если СодержимоеКаталога.Количество() Тогда
			КорневойФайл = СодержимоеКаталога[0].ПолноеИмя;
		Иначе
			Продолжить;
		КонецЕсли;

		ХешФайл = Новый Файл(ОбъединитьПути(Каталог.ПолноеИмя, "hashfile.txt"));
		Если ХешФайл.Существует() Тогда
			ЧтениеТекста = Новый ЧтениеТекста(ХешФайл.ПолноеИмя, КодировкаТекста.UTF8);
			ХешСумма = ЧтениеТекста.ПрочитатьСтроку();
			ЧтениеТекста.Закрыть();
		Иначе
			Продолжить;
		КонецЕсли;

		НоваяСтрока = ХешТаблица.Добавить();
		НоваяСтрока.Идентификатор 	= Каталог.Имя;
		НоваяСтрока.ХешСумма 		= ХешСумма;
		НоваяСтрока.Путь 			= Каталог.ПолноеИмя;
		НоваяСтрока.КорневойФайл	= КорневойФайл;

	КонецЦикла;

	Возврат ХешТаблица;

КонецФункции

Функция ХешТаблицаОбработокКаталога()

	мЖурналы.ОсновнойЖурнал.Информация("Получение списка обработок из каталога");

	ХешТаблица = ХешТаблицаОбработок();
	Хеширование = Новый ХешированиеДанных(ХешФункция.SHA1);

	Обработки = НайтиФайлы(мКаталогОбработок, ПолучитьМаскуВсеФайлы());
	Для Каждого Обработка Из Обработки Цикл
		Если Не СтрНайти("*.epf;*.erf", Обработка.Расширение) Тогда
			Продолжить;
		КонецЕсли;
		
		НоваяСтрока = ХешТаблица.Добавить();
		НоваяСтрока.Идентификатор 	= Обработка.ИмяБезРасширения;
		НоваяСтрока.ХешСумма 		= ХешСуммаФайла(Хеширование, Обработка.ПолноеИмя);
		НоваяСтрока.Путь 			= Обработка.ПолноеИмя;

	КонецЦикла;

	Возврат ХешТаблица;

КонецФункции

Функция ТаблицаОбработокДляРазбора()

	ОбработкиРепозитория = ХешТаблицаОбработокРепозитория();
	ОбработкиКаталога = ХешТаблицаОбработокКаталога();

	ОтборСтрок = Новый Структура("Идентификатор, ХешСумма");
	Для Каждого Обработка Из ОбработкиРепозитория Цикл

		ЗаполнитьЗначенияСвойств(ОтборСтрок, Обработка);
		
		НайденныеСтроки = ОбработкиКаталога.НайтиСтроки(ОтборСтрок);
		Для Каждого СтрокаТаблицы Из НайденныеСтроки Цикл
			ОбработкиКаталога.Удалить(СтрокаТаблицы);
		КонецЦикла;	

	КонецЦикла;

	Возврат ОбработкиКаталога;

КонецФункции

Функция ТаблицаОбработокДляСборки()

	// TODO: только измененные обработки / предварительно выгружать обработки из ИБ и сверять хеши
	ОбработкиРепозитория = ХешТаблицаОбработокРепозитория();
	ОбработкиКаталога = ХешТаблицаОбработокКаталога();

	ОтборСтрок = Новый Структура("Идентификатор, ХешСумма");
	Для Каждого Обработка Из ОбработкиКаталога Цикл
	
		ЗаполнитьЗначенияСвойств(ОтборСтрок, Обработка);
		
		НайденныеСтроки = ОбработкиРепозитория.НайтиСтроки(ОтборСтрок);
		Для Каждого СтрокаТаблицы Из НайденныеСтроки Цикл
			ОбработкиРепозитория.Удалить(СтрокаТаблицы);
		КонецЦикла;
		
	КонецЦикла;

	Возврат ОбработкиРепозитория;

КонецФункции

Процедура ЗаписатьХешСуммуОбработки(Хеширование, КаталогОбработки, ИмяФайла)

	ЗаписьТекста = Новый ЗаписьТекста(ОбъединитьПути(КаталогОбработки, "hashfile.txt"), КодировкаТекста.UTF8, Ложь);
	ЗаписьТекста.Записать(ХешСуммаФайла(Хеширование, ИмяФайла));
	ЗаписьТекста.Закрыть();

КонецПроцедуры

Функция ХешСуммаФайла(Хеширование, ИмяФайла)

	Перем Результат;

	Хеширование.ДобавитьФайл(ИмяФайла);
	Результат = Хеширование.ХешСуммаСтрокой;
	Хеширование.Очистить(); // Иначе файл не освобождается.

	Возврат Результат;
	
КонецФункции