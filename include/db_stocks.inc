#if defined _db_stocks_included
	#endinput
#endif
#define _db_stocks_included

stock void DB_Query(char[] dbname, SQLQueryCallback callback, const char[] query, any data = 0, DBPriority prio = DBPrio_Normal)
{
	char error;
	Database db_temp = SQLite_UseDatabase(dbname, error, 1);

	db_temp.Query(callback, query, data, prio);
	delete db_temp;
}

