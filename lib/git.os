		
Функция ПолучитьНазваниеТекущейВетки(КаталогРепозитария) Экспорт

	ПроцессГит = Создатьпроцесс("git rev-parse --abbrev-ref HEAD"
								,КаталогРепозитария
								,Истина
								,Ложь
								,КодировкаТекста.UTF8);
	ПроцессГит.Запустить();										
	ПроцессГит.ОжидатьЗавершения();
	
	НазваниеТекущейВетки  = СокрЛП(ПроцессГит.ПотокВывода.Прочитать());

	Возврат НазваниеТекущейВетки;

КонецФункции

Функция ПолучитьНазваниеВеткиСлияния() Экспорт

	ПроцессГит = Создатьпроцесс("git cherry -v HEAD MERGE_HEAD"
								,ТекущийКаталог()
								,Истина
								,Ложь
								,КодировкаТекста.UTF8);
	ПроцессГит.Запустить();										
	ПроцессГит.ОжидатьЗавершения();

	ТекстСообщения  = ПроцессГит.ПотокВывода.Прочитать();

	Возврат СокрЛП(ТекстСообщения);
	//Возврат "origin1c";
	
КонецФункции

Функция ОбработатьФайлИзменений(ПутьКРепозитарию, ИмяФайлаСпискаФайлов, Журнал) Экспорт
	
	ИмяВрФайла = ПолучитьИмяВременногоФайла ();

	// Добавить путь к репозитарию
	ЧТ = Новый ЧтениеТекста(ИмяФайлаСпискаФайлов, КодировкаТекста.UTF8);
	ЗТ = Новый ЗаписьТекста(ИмяВрФайла, КодировкаТекста.UTF8);

	Стр = ЧТ.ПрочитатьСтроку();
	СтрЗТ = "";

	ТЗ = Новый ТаблицаЗначений;
	ТЗ.Колонки.Добавить("Новый");
	ТЗ.Колонки.Добавить("Путь");
	ТЗ.Колонки.Добавить("Уровень");

	Пока не Стр = неопределено Цикл
		
		Журнал.Отладка("Обрабатываю " + Стр);
		
		Если Не СокрЛП(Стр) = "" Тогда

			Стр = СтрРазделить(Стр, Символы.Таб);
		
			СтрЗТ = "" + ПутьКРепозитарию + "\" + СтрЗаменить(Стр[1],"/","\");
			
		Иначе

			СтрЗТ = "";
		
		КонецЕсли;
		
		Если Стр[0] = "R088" ИЛИ Стр[0] = "D" ИЛИ СтрНайти(Стр[1], "Config/") = 0 ИЛИ СтрНайти(Стр[1], "Config/ConfigDumpInfo.xml") <> 0 Тогда
		
			Журнал.Информация("Пропускаю  " + Стр[0] + "	" + Стр[1]);
			Стр = ЧТ.ПрочитатьСтроку();
			Продолжить;
		
		КонецЕсли;
		
		БылоПреобразование = Ложь;
		
		ПозФормы = СтрНайти(СтрЗТ, "\Ext\Form");
		Если ПозФормы > 0 Тогда
		
			СтрЗТ = Сред(СтрЗТ, 1, ПозФормы - 1) + ".xml";
			БылоПреобразование = Истина;
			
		КонецЕсли;	

		ПозМакета = СтрНайти(СтрЗТ, "\Ext\Template");

		Если ПозМакета > 0 Тогда
		
			СтрЗТ = Сред(СтрЗТ, 1, ПозМакета - 1) + ".xml";
			БылоПреобразование = Истина;
			
		КонецЕсли;	
		
		ПозПрава = СтрНайти(СтрЗТ, "\Ext\Rights");
		
		Если ПозПрава > 0 Тогда
		
			СтрЗТ = Сред(СтрЗТ, 1, ПозПрава - 1) + ".xml";
			БылоПреобразование = Истина;
			
		КонецЕсли;	
		
		ПозСправка = СтрНайти(СтрЗТ, "\Ext\Help");

		Если ПозСправка > 0 Тогда
		
			СтрЗТ = Сред(СтрЗТ, 1, ПозСправка - 1) + ".xml";
			БылоПреобразование = Истина;
			
		КонецЕсли;	
		
		Если БылоПреобразование Тогда
		
			Журнал.Информация("Преобразовано: " + ПутьКРепозитарию + "\" + СтрЗаменить(Стр[1],"/","\") + " -> " + СтрЗТ);
			
		КонецЕсли;

		Если СтрНайти(СтрЗТ, "Configuration.xml")>0 Тогда
		
			Возврат -1;
		
		КонецЕсли;
		
		
		Если СтрНайти(СтрЗТ, "\Config") > 0 НЕ СокрЛП(СтрЗТ) = "" Тогда
		
			Если (Стр[0] = "A" или Стр[0] = "D") и СтрЗаканчиваетсяНа(СтрЗТ, "xml") Тогда
		
				МасСтр = СтрРазделить(СтрЗТ, "\");
				МасСтр.Удалить(МасСтр.Количество() - 1);
				МасСтр.Удалить(МасСтр.Количество() - 1);
				
				СтрРодитель = СтрСоединить(МасСтр, "\") + ".xml";
				
				Если СтрНайти(СтрРодитель, "Config.xml") > 0 Тогда
				
					Возврат -1;
				
				КонецЕсли;
				//СтрРодитель = СтрЗаменить(СтрРодитель, "Config.xml","Config\Configuration.xml");
	
				СтрТз= ТЗ.Добавить();
				СтрТз.Путь = СтрРодитель;
				СтрТз.Уровень = СтрЧислоВхождений(СтрРодитель, "\");
			
				Журнал.Информация(СтрЗТ + " -> " + СтрРодитель);
			
			КонецЕсли;
		
			СтрТз= ТЗ.Добавить();
			СтрТз.Путь = СтрЗТ;
			СтрТз.Уровень = СтрЧислоВхождений(СтрЗТ, "\");
		
		КонецЕсли;
		
		Стр = ЧТ.ПрочитатьСтроку();
		
	КонецЦикла; 

	ТЗ.Сортировать("Уровень, Путь");
	ТЗ.Свернуть("Путь");

	Для каждого СтрТз из ТЗ Цикл
		
		ЗТ.ЗаписатьСтроку(СтрТз.Путь);

	КонецЦикла;

	ЗТ.Закрыть();
	ЧТ.Закрыть();

	УдалитьФайлы(ИмяФайлаСпискаФайлов);
	ПереместитьФайл(ИмяВрФайла, ИмяФайлаСпискаФайлов);

	Возврат ТЗ.Количество();
	
КонецФункции

Процедура ПерейтиНаВетку(ПутьКРепозитарию, ИмяВетки, Журнал = неопределено) Экспорт

	ТекущаяВетка = ПолучитьНазваниеТекущейВетки(ПутьКРепозитарию);

	// Проверить текущую ветку и если она не соответствует, перейти на нее
	Если Не ТекущаяВетка = ИмяВетки Тогда
	
		ЗапуститьПриложение("git checkout " + ИмяВетки, ПутьКРепозитарию, Истина);
		
	ИначеЕсли Не Журнал = неопределено Тогда
		
		Журнал.Информация("переход на ветку " + ИмяВетки + " так как текущая ветка и так " + ТекущаяВетка);
		
	КонецЕсли;

КонецПроцедуры

Процедура ПолучитьСписокИзмененийВФайл(Знач ПутьКРепозитарию, Знач ИмяФайлаСпискаФайлов, Журнал, СравниваемыеКомиты = Неопределено) Экспорт
	
	Если не СравниваемыеКомиты = Неопределено Тогда
		Сообщить("Запускаю: cmd /C git diff " + СравниваемыеКомиты[0] + " " + СравниваемыеКомиты[1] + " --name-status > " + ИмяФайлаСпискаФайлов);
		ЗапуститьПриложение("cmd /C git diff " + СравниваемыеКомиты[0] + " " + СравниваемыеКомиты[1] + " --name-status > " + ИмяФайлаСпискаФайлов, ПутьКРепозитарию, Истина);
	
	Иначе
		
		ЗапуститьПриложение("cmd /C git diff @{1}.. --name-status > " + ИмяФайлаСпискаФайлов, ПутьКРепозитарию, Истина);
		//ЗапуститьПриложение("cmd /C git diff d1315564988df781c8d8e88245564284cc82e7bf f43dc75005c330be4c8f88b9df87593da94e07eb --name-status > " + ИмяФайлаСпискаФайлов, ПутьКРепозитарию, Истина);
		
	КонецЕсли;	
	
	
КонецПроцедуры
