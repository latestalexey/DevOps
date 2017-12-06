#Использовать cmdline
#Использовать logos
#Использовать v8runner

Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт

    Возврат СтрШаблон("%1: %2 - %3", ТекущаяДата(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);

КонецФункции

//ИмяРодительскогоПлана = АргументыКоманднойСтроки[0];
//РабочийКаталог = АргументыКоманднойСтроки[1];

АргументыКС = Новый ПарсерАргументовКоманднойСтроки();
//АргументыКС.ДобавитьИменованныйПараметр("-ibname");
//АргументыКС.ДобавитьИменованныйПараметр("-srvname");
АргументыКС.ДобавитьИменованныйПараметр("-usr");
АргументыКС.ДобавитьИменованныйПараметр("-pwd");
АргументыКС.ДобавитьИменованныйПараметр("-planname");
АргументыКС.ДобавитьИменованныйПараметр("-catname");
АргументыКС.ДобавитьИменованныйПараметр("-dourl");


Параметры = АргументыКС.Разобрать(АргументыКоманднойСтроки);

ИмяРодительскогоПлана = Параметры["-planname"];
РабочийКаталог = Параметры["-catname"];
ПутьКПубликацииДО = Параметры["-dourl"];

МассивСтрок = СтрРазделить(ИмяРодительскогоПлана, "-");
МассивСтрок.Удалить(МассивСтрок.Количество() - 1);
//БазаИсточник = МассивСтрок[0] + "_Production";
ИмяБазы = СтрСоединить(МассивСтрок,"_");


//ИмяСервера = Параметры["-srvname"];
ИмяСервера = "RTITS-1C-04";
//ИмяБазы = Параметры["-ibname"];
Пользователь = Параметры["-usr"];
Пароль = Параметры["-pwd"];



ИмяФайлаЖурнала = ОбъединитьПути(РабочийКаталог, "Logs", ИмяБазы + ".log");
Файл = Новый Файл(ИмяФайлаЖурнала);
СоздатьКаталог(Файл.Путь);
КаталогЖурналов = Файл.Путь;

Журнал = Логирование.ПолучитьЛог("doconfig.app");
Журнал.УстановитьУровень(УровниЛога.Информация);
Журнал.УстановитьРаскладку(ЭтотОбъект);

КонсольЖурн = Новый ВыводЛогаВКонсоль;
ФайлЖурнала = Новый ВыводЛогаВФайл;
ФайлЖурнала.ОткрытьФайл(ИмяФайлаЖурнала, "windows-1251");

Журнал.ДобавитьСпособВывода(ФайлЖурнала);
Журнал.ДобавитьСпособВывода(КонсольЖурн);

УправлениеКонфигуратором = Новый УправлениеКонфигуратором();
ПутьКПлатформе1С = УправлениеКонфигуратором.ПолучитьПутьКВерсииПлатформы("8.3.10");

ЖурналЗагрузкиИзменений = ОбъединитьПути(КаталогЖурналов, "DoConfig_" + ИмяБазы + ".log");

Журнал.Информация("Начало настройки интеграции с ДО.");
Журнал.Информация("Запуск: """ + ПутьКПлатформе1С + """ ENTERPRISE /UC 456654 /S """ + ИмяСервера + "\" +
					ИмяБазы + """ /N """ + Пользователь + """ /P ""******"" /DisableStartupMessages /DisableStartupDialogs /C""ExecuteADP -name Обработка настройки интеграции с ДО -command ВыполнитьНаСервере -doref " + ПутьКПубликацииДО + " -sjoff true -sjlist ИнтеграцияС1СДокументооборотВыполнитьОбменДанными -docat D:\Users\Common\Обмен -logoff true"" /out """ + ЖурналЗагрузкиИзменений + """");
ПроцессПредприятия = Создатьпроцесс("""" + ПутьКПлатформе1С + """ ENTERPRISE /UC 456654 /S """ + ИмяСервера + "\" + ИмяБазы + """ /N """ + Пользователь +""" /P """ + Пароль + """ /DisableStartupMessages /DisableStartupDialogs /C""ExecuteADP -name Обработка настройки интеграции с ДО -command ВыполнитьНаСервере -doref " + ПутьКПубликацииДО + " -sjoff true -sjlist ИнтеграцияС1СДокументооборотВыполнитьОбменДанными -docat D:\Users\Common\Обмен -logoff true"" /out """ + ЖурналЗагрузкиИзменений + """"
											,РабочийКаталог
											,Истина
											,Ложь
											,КодировкаТекста.UTF8);
ПроцессПредприятия.Запустить();										
ПроцессПредприятия.ОжидатьЗавершения();

Журнал.Информация("Настройка интеграции базы " + ИмяБазы + " с ДО завершена");

ФайлЖурнала.Закрыть();

ЗавершитьРаботу(0);