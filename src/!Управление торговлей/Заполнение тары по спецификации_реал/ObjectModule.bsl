﻿Процедура Инициализировать(Объект, ИмяТабличнойЧасти, ТабличноеПоле) Экспорт;

	НачатьТранзакцию();
	РежимПроведения=?(НачалоДня(Объект.Дата)=НачалоДня(ТекущаяДата()),РежимПроведенияДокумента.Оперативный,РежимПроведенияДокумента.Неоперативный);	
	Если Объект.Модифицированность() ИЛИ НЕ Объект.Проведен Тогда
		Ответ=Вопрос("Необходимо записать и провести документ. Продолжить?",РежимДиалогаВопрос.ДаНет,15,КодВозвратаДиалога.Нет);
		Если Ответ<>КодВозвратаДиалога.Да Тогда
			Возврат;
		КонецЕсли;
		Объект.Записать(РежимЗаписиДокумента.Проведение,РежимПроведения);
	КонецЕсли;
	
	
	//Для реализации сделаем документ копию но с тарой. Но сначала проверим есть он или нет
	Док=Документы.РеализацияТоваровУслуг.НайтиПоРеквизиту("ДокументОснование",Объект.Ссылка);
	Если НЕ Док.Пустая() Тогда
		Ответ=Вопрос("Есть документ с тарой. Перезаполнить его?",РежимДиалогаВопрос.ДаНет,30,КодВозвратаДиалога.Нет);
		Если Ответ=КодВозвратаДиалога.Нет Тогда
			Возврат;
		КонецЕсли;
		ДокОбъект=Док.ПолучитьОбъект();
		ДокОбъект.ВозвратнаяТара.Очистить();
		ДокОбъект.Товары.Очистить();
	Иначе
		ДокОбъект=Объект.Скопировать();
		ДокОбъект.Дата=Объект.Дата;
		ДокОбъект.ОтражатьВУправленческомУчете=Истина;
		ДокОбъект.ОтражатьВБухгалтерскомУчете=Ложь;
		ДокОбъект.ОтражатьВНалоговомУчете=Ложь;
		ДокОбъект.Склад=Справочники.ИТИКонстанты.БИсток.Указатель;
		ДокОбъект.Организация=Справочники.ИТИКонстанты.ПЗЛогистика.Указатель;
		ДокОбъект.ДоговорКонтрагента=ЗаполнениеДокументов.ПолучитьДоговорПоОрганизацииИКонтрагенту(ДокОбъект.Организация,ДокОбъект.Контрагент,ЗаполнениеДокументов.ПолучитьСтруктуруПараметровДляПолученияДоговораПродажи());
		ДокОбъект.ДокументОснование=Объект.Ссылка;
		ДокОбъект.Сделка=Неопределено;
		ДокОбъект.Тара=Истина;
		ДокОбъект.Номер="";
		//ДокОбъект.Записать();
		ДокОбъект.ВозвратнаяТара.Очистить();
		ДокОбъект.Товары.Очистить();
	КонецЕсли;
	
	
	Запрос = Новый Запрос;
	ТекстЗапроса = "ВЫБРАТЬ
	               |	Товары.Номенклатура,
	               |	Товары.Количество
	               |ПОМЕСТИТЬ ВТ_Номенклатура
	               |ИЗ
	               |	&Товары КАК Товары
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ТараНоменклатуры.Тара КАК Номенклатура,
	               |	СУММА(ВТ_Номенклатура.Количество * ЕСТЬNULL(ТараНоменклатуры.Количество, 0) / ЕСТЬNULL(ТараНоменклатуры.Кратность, 1)) КАК Количество,
	               |	ЗНАЧЕНИЕ(Перечисление.СпособыСписанияОстаткаТоваров.СоСклада) КАК СпособСписанияОстаткаТоваров
	               |ИЗ
	               |	ВТ_Номенклатура КАК ВТ_Номенклатура
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.StrТараНоменклатуры КАК ТараНоменклатуры
	               |		ПО ВТ_Номенклатура.Номенклатура = ТараНоменклатуры.Номенклатура
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ТараНоменклатуры.Тара";
	Запрос.Текст = ТекстЗапроса;
	Запрос.УстановитьПараметр("Товары", Объект["Товары"].Выгрузить(,"Номенклатура,Количество"));

	
	ТаблицаТары=Запрос.Выполнить().Выгрузить();
	ДокОбъект.ВозвратнаяТара.Загрузить(ТаблицаТары);	
	
	
	ДокОбъект.Записать(РежимЗаписиДокумента.Проведение,РежимПроведения);
	ЗафиксироватьТранзакцию();

КонецПроцедуры 