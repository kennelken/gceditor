package ru.kennel32.editor.data.table
{
	import ru.kennel32.editor.data.table.ContainerTable;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.table.TableMeta;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.table.TableType;
	
	public class NewTableBuilder
	{
		public static function create():ContainerTable
		{
			var rootMeta:TableMeta = TableMeta.create(1, TableType.CONTAINER, "root", 0);
			rootMeta.name = "root";
			rootMeta.description = "Top level of tables";
			rootMeta.lock = true;
			
			var rootTable:ContainerTable = new ContainerTable(rootMeta);
			rootTable.index = 0;
			
			var countersTableMeta:TableMeta = TableMeta.create(2, TableType.BASIC, "counters", 2);
			countersTableMeta.name = "counters";
			countersTableMeta.description = "all counters";
			countersTableMeta.lock = true;
			
			var column:TableColumnDescription = TableColumnDescription.create(TableColumnDescriptionType.ID, "id", true, 0, false);
			column.name = "id";
			column.description = "id";
			countersTableMeta.addColumn(column, 0, true);
			
			column = TableColumnDescription.create(TableColumnDescriptionType.STRING_VALUE, "name", false, 0, false);
			column.name = "name";
			column.description = "name";
			column.useAsName = true;
			column.width = 150;
			countersTableMeta.addColumn(column, 1, true);
			
			column = TableColumnDescription.create(TableColumnDescriptionType.COUNTER, "value", true, 0, false);
			column.name = "value";
			column.description = "value";
			countersTableMeta.addColumn(column, 2, true);
			
			column = TableColumnDescription.create(TableColumnDescriptionType.LOCK, "lock", false, 0, false);
			column.name = "lock";
			column.description = "lock";
			countersTableMeta.addColumn(column, 3, true);
			
			var tableCounters:DataTable = new DataTable(countersTableMeta);
			tableCounters.index = 1;
			
			var tablesCounter:Counter = new Counter(tableCounters);
			tablesCounter.decode([
				"1", "tables", "4", "1"
			]);
			tablesCounter.index = 0;
			tableCounters.addRow(tablesCounter);
			
			var countersCounter:Counter = new Counter(tableCounters);
			countersCounter.decode([
				"2", "counters", "4", "1"
			]);
			countersCounter.index = 1;
			tableCounters.addRow(countersCounter);
			
			var localizationCounter:Counter = new Counter(tableCounters);
			localizationCounter.decode([
				"3", "localization", "0", "1"
			]);
			localizationCounter.index = 2;
			tableCounters.addRow(localizationCounter);
			
			var projectSettingsCounter:Counter = new Counter(tableCounters);
			projectSettingsCounter.decode([
				"4", "settings", "2", "1"
			]);
			projectSettingsCounter.index = 3;
			tableCounters.addRow(projectSettingsCounter);
			
			rootTable.addChild(tableCounters);
			
			//
			
			var localizationTableMeta:TableMeta = TableMeta.create(3, TableType.BASIC, "localization", 3);
			localizationTableMeta.name = "localization";
			localizationTableMeta.description = "Localization";
			localizationTableMeta.lock = true;
			
			column = TableColumnDescription.create(TableColumnDescriptionType.ID, "id", true, 0, false);
			column.name = "id";
			column.description = "id";
			localizationTableMeta.addColumn(column, 0, true);
			
			column = TableColumnDescription.create(TableColumnDescriptionType.STRING_VALUE, "tag", false, 0, false);
			column.name = "tag";
			column.description = "Tag can be used as a key to access translation";
			column.width = 150;
			column.useAsName = true;
			localizationTableMeta.addColumn(column, 1, true);
			
			column = TableColumnDescription.create(TableColumnDescriptionType.STRING_MULTILINE, "en", false, 0, false);
			column.name = "en";
			column.description = "English translation";
			column.width = 150;
			localizationTableMeta.addColumn(column, 2, true);
			
			var tableLocalization:DataTable = new DataTable(localizationTableMeta);
			tableLocalization.index = 2;
			rootTable.addChild(tableLocalization);
			
			//
			
			var projectSettingsTableMeta:TableMeta = TableMeta.create(4, TableType.BASIC, "settings", 4);
			projectSettingsTableMeta.name = "settings";
			projectSettingsTableMeta.description = "Project settings";
			projectSettingsTableMeta.lock = true;
			
			column = TableColumnDescription.create(TableColumnDescriptionType.ID, "id", true, 0, false);
			column.name = "id";
			column.description = "id";
			projectSettingsTableMeta.addColumn(column, 0, true);
			
			column = TableColumnDescription.create(TableColumnDescriptionType.STRING_VALUE, "name", true, 0, false);
			column.name = "name";
			column.description = "Setting name";
			column.width = 200;
			column.useAsName = true;
			projectSettingsTableMeta.addColumn(column, 1, true);
			
			column = TableColumnDescription.create(TableColumnDescriptionType.STRING_MULTILINE, "description", false, 0, false);
			column.name = "description";
			column.description = "Setting description";
			column.width = 600;
			projectSettingsTableMeta.addColumn(column, 2, true);
			
			column = TableColumnDescription.create(TableColumnDescriptionType.STRING_VALUE, "value", false, 0, false);
			column.name = "value";
			column.description = "Setting value";
			column.width = 300;
			projectSettingsTableMeta.addColumn(column, 3, true);
			
			var tableProjectSettings:DataTable = new DataTable(projectSettingsTableMeta);
			tableProjectSettings.index = 3;
			
			var settingFilesPath:TableRow = new TableRow(tableProjectSettings);
			settingFilesPath.decode(
				['1', 'files path', 'Assets files path in absolute or relative format\nUsed in columns of type "FILE_PATH"\nExample:\nC:/unity/myProject/Assets/Resources/\nor\n../Resources/', '']
			);
			settingFilesPath.index = 0;
			tableProjectSettings.addRow(settingFilesPath);
			
			var settingTimezone:TableRow = new TableRow(tableProjectSettings);
			settingTimezone.decode(
				['2', 'timezone', 'timezone for columns of type "Date"', '0']
			);
			settingTimezone.index = 1;
			tableProjectSettings.addRow(settingTimezone);
			
			rootTable.addChild(tableProjectSettings);
			
			return rootTable;
		}
	}
}