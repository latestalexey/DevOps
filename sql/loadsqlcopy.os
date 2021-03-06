#Использовать InternetMail
#Использовать logos

//----------------

//Для логирования
Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт

    Возврат СтрШаблон("%1: %2 - %3", ТекущаяДата(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);

КонецФункции

Процедура Оповестить(ТипОповещения = "Окончание", НазваниеБазы)

	СтруктураАдресов = Новый Структура;
	
	////
	
	ТекстСообщения = "";
	
	Если ТипОповещения = "Окончание" Тогда
	
		ТекстСообщения = "Загрузка последней копии базы " + НазваниеБазы + " завершена!"
	
	Иначе
	
		ТекстСообщения = "Началась загрузка последней копии базы " + НазваниеБазы + "!" + Символы.ПС +  "О завершении будет сообщено дополнительно."
	
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СтруктураАдресов[НазваниеБазы].Email) Тогда
		
		Попытка
			
			ОтправитьПочтовоеСообщение(СтруктураАдресов[НазваниеБазы].Email, ТекстСообщения);

		Исключение
			
			//Журнал.Информация("Ошибка отправки оповещения:" + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));

		КонецПопытки;

	
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СтруктураАдресов[НазваниеБазы].Telegram) Тогда
		
		Попытка	

		Зап = Новый HTTPЗапрос("/bot373923831:AAGqI4Fu4UogxTVaxaq7rb_dNE4BWorbjZs/sendMessage?chat_id=" + СтруктураАдресов[НазваниеБазы].Telegram + "&text=" + ТекстСообщения);
		
		Соед = Новый HTTPСоединение("api.telegram.org");
		Соед.Получить(Зап);
		
		Исключение
			
		//Журнал.Информация("Ошибка отправки оповещения:" + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));

		КонецПопытки;	

	КонецЕсли;	

КонецПроцедуры

Процедура ОтправитьПочтовоеСообщение(Адрес, ТекстСообщения)

	Профиль = Новый ИнтернетПочтовыйПрофиль;
	Профиль.АдресСервераSMTP = "mx.rtits.ru";
	
	Профиль.ПортSMTP = 587;
	
	Профиль.ПользовательSMTP = "Tasks-1C@rtits.ru";
	Профиль.ПарольSMTP = "k0D7vSTC";
	
	Почта = Новый ИнтернетПочта;
	Почта.Подключиться(Профиль);

	Сообщение = Новый ИнтернетПочтовоеСообщение;
	Сообщение.Отправитель = "Tasks-1C@rtits.ru";
	Сообщение.Тема = "Уведомление о загрузке SQL копии базы";
	Текст = Сообщение.Тексты.Добавить(ТекстСообщения);
	Текст.ТипТекста = ТипТекстаПочтовогоСообщения.ПростойТекст; 
	Адрес = Сообщение.Получатели.Добавить(Адрес);
	
	Почта.Послать(Сообщение, ,ПротоколИнтернетПочты.SMTP);
	Почта.Отключиться();

КонецПроцедуры

ИмяРодительскогоПлана = АргументыКоманднойСтроки[0];
РабочийКаталог = АргументыКоманднойСтроки[1];
//ЦелевойСервер = АргументыКоманднойСтроки[2];

МассивСтрок = СтрРазделить(ИмяРодительскогоПлана, "-");
МассивСтрок.Удалить(МассивСтрок.Количество() - 1);

ПутьКХранилищу = ОбъединитьПути("D:\Users\",МассивСтрок[1],"GIT","ERP");
Ветка = МассивСтрок[1];

БазаИсточник = МассивСтрок[0] + "_Production";
НазваниеБазы = СтрСоединить(МассивСтрок,"_");

Если СтрНайти(НазваниеБазы, "0")>0 Тогда
	ЦелевойСервер = Сред(НазваниеБазы, СтрНайти(НазваниеБазы, "0"));
Иначе
	ЦелевойСервер = "04";
КонецЕсли;

НазваниеБазы = Сред(НазваниеБазы, 1, СтрНайти(НазваниеБазы, "0") - 1);




ПапкаХранилища = Новый Файл(ПутьКХранилищу);

//------------ Log
ИмяФайлаЖурнала = ОбъединитьПути(РабочийКаталог, "Logs", НазваниеБазы, Ветка + "_lsql.log");
Файл = Новый Файл(ИмяФайлаЖурнала);
СоздатьКаталог(Файл.Путь);
КаталогЖурналов = Файл.Путь;

Журнал = Логирование.ПолучитьЛог("load_sql_copy.app.loading");
Журнал.УстановитьУровень(УровниЛога.Информация);
Журнал.УстановитьРаскладку(ЭтотОбъект);

КонсольЖурн = Новый ВыводЛогаВКонсоль;
ФайлЖурнала = Новый ВыводЛогаВФайл;
ФайлЖурнала.ОткрытьФайл(ИмяФайлаЖурнала, "windows-1251");

Журнал.ДобавитьСпособВывода(ФайлЖурнала);
Журнал.ДобавитьСпособВывода(КонсольЖурн);

Оповестить("Начало", НазваниеБазы);

Журнал.Информация("запуск загрузки копии из SQL для " + БазаИсточник + " в " + НазваниеБазы);

Журнал.Информация("Комманда: ""C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\110\Tools\Binn\SQLCMD.EXE"" -S tcp:RTITS-1C-" + ЦелевойСервер + " -v sourcedb=""" + БазаИсточник + """ db=""" + НазваниеБазы + """ bakfile=""\\RTITS-1C-04\DBBACKUP$\" + БазаИсточник + "_Copy.bak"" -i D:\Users\MAV\GIT\devops\sql\LoadBackupFileToDB.sql -o " + РабочийКаталог + "\Logs\sql.log");
ПроцессSqlCMD = СоздатьПроцесс("""C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\110\Tools\Binn\SQLCMD.EXE"" -S tcp:RTITS-1C-" + ЦелевойСервер + " -v sourcedb=""" + БазаИсточник + """ db=""" + НазваниеБазы + """ bakfile=""\\RTITS-1C-04\DBBACKUP$\" + БазаИсточник + "_Copy.bak"" -i D:\Users\MAV\GIT\devops\sql\LoadBackupFileToDB.sql -o " + РабочийКаталог + "\Logs\sql.log"
							,РабочийКаталог
							,Истина
							,Ложь
							,КодировкаТекста.ANSI);
ПроцессSqlCMD.Запустить();										
ПроцессSqlCMD.ОжидатьЗавершения();

Вывод  = СокрЛП(ПроцессSqlCMD.ПотокВывода.Прочитать());
Ошибки = СокрЛП(ПроцессSqlCMD.ПотокОшибок.Прочитать());

Журнал.Информация("Загрузка копии закончена. Вывод команды (" + Вывод + Символы.ПС + Ошибки + ")");

Если ПапкаХранилища.Существует() и 1=2 Тогда

	ПервыйХеш = "origin/master";
	ВторойХеш = Ветка;

	Журнал.Информация("загрузка разницы между " + ПервыйХеш + " и " + ВторойХеш + " в " + НазваниеБазы);

	Журнал.Информация("Запуск oscript D:\Users\MAV\GIT\DevOps\deploy\load_changes.os -repo " + ПутьКХранилищу + " -branch " + Ветка + " -srvname RTITS-1C-04 -ibname " + НазваниеБазы + " -usr defuser -pwd ****** -fastupdate true -fromHash " + ПервыйХеш + " -toHash " + ВторойХеш + " -loadchanges true -loadextension true -updatecfgdump true -syntaxctrl false -updatedb true -deploycfg false -deployext false -dpath " + РабочийКаталог);
	ПроцессСкрипта = СоздатьПроцесс("oscript D:\Users\MAV\GIT\DevOps\deploy\load_changes.os -repo " + ПутьКХранилищу + " -branch " + Ветка + " -srvname RTITS-1C-04 -ibname " + НазваниеБазы + " -usr defuser -pwd defuser -fastupdate true -fromHash " + ПервыйХеш + " -toHash " + ВторойХеш + " -loadchanges true -loadextension true -updatecfgdump true -syntaxctrl false -updatedb true -deploycfg false -deployext false -dpath " + РабочийКаталог
								,РабочийКаталог
								,Истина
								,Ложь
								,КодировкаТекста.UTF8);

	ПроцессСкрипта.Запустить();										
	ПроцессСкрипта.ОжидатьЗавершения();

	Вывод  = СокрЛП(ПроцессСкрипта.ПотокВывода.Прочитать());

	Журнал.Информация("Загрузка разницы закончена. Вывод команды (" + Вывод + ")");

КонецЕсли;

Оповестить("Окончание", НазваниеБазы);

