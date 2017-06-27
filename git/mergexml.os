БазовыйФайл = АргументыКоманднойСтроки[0];
ЛевыйФайл = АргументыКоманднойСтроки[1];
ПравыйФайл = АргументыКоманднойСтроки[2];
ИтоговыйФайл = АргументыКоманднойСтроки[3];

ПутьКПравомуФайлу = ОбъединитьПути(ТекущийКаталог(), ИтоговыйФайл);
ПутьКИтоговомуФайлу = ОбъединитьПути(ТекущийКаталог(), ИтоговыйФайл);

ИтоговыйФайл = Новый Файл(ПутьКИтоговомуФайлу);

Если ИтоговыйФайл.Имя = "Rights.xml" ИЛИ
		ИтоговыйФайл.Имя = "Form.xml" ИЛИ
		ИтоговыйФайл.Имя = "Template.xml" ИЛИ
		ИтоговыйФайл.Имя = "ru.html" 
		
		Тогда
		
		Сообщить("Выбираю ""их"" файл: " + ПутьКИтоговомуФайлу);
		
		КопироватьФайл(ПравыйФайл, ЛевыйФайл);
		
		ЗавершитьРаботу(0);
		
КонецЕсли;		

Сообщить("Запуск ""oso xml"" для: " + ПутьКИтоговомуФайлу);

ПроцессДрайвера = Создатьпроцесс("""C:\Program Files\Oso\XMLMerge\2\OsoXMLMerge.exe"" -merge -silent -checkconflicts -base " + БазовыйФайл + " -left " + ЛевыйФайл + " -right " + ПравыйФайл + " -result " + ЛевыйФайл
								,ТекущийКаталог()
								,Истина
								,Ложь
								,КодировкаТекста.UTF8);
ПроцессДрайвера.Запустить();										
ПроцессДрайвера.ОжидатьЗавершения();
Если ПроцессДрайвера.ПотокВывода.ЕстьДанные Тогда

	Сообщить(ПроцессДрайвера.ПотокВывода.Прочитать());

КонецЕсли;

Если ПроцессДрайвера.КодВозврата < 0 Тогда
	
	Сообщить("Обнаружен конфликт в файле " + ПутьКИтоговомуФайлу);
	ЗТ = Новый ЗаписьТекста(ЛевыйФайл, КодировкаТекста.UTF8, Истина);
	ЗТ.ЗаписатьСтроку(">>>>>>>>>>>>>> conflicted");
	ЗТ.Закрыть();

	ЗавершитьРаботу(1);
	
КонецЕсли;

ЗавершитьРаботу(0);