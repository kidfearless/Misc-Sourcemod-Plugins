#if defined __more_adt_ext
	#endinput
#endif

#define __more_adt_ext

/**
 * An iterator for the StringMultiMap.
 * Call its Next() function before performing any retrievals to ensure that it is valid.
 */
methodmap StringMultiMapIterator < Handle {
	/**
	 * Advances the iterator to the next key / value.
	 * Returns false when the iterator has been exhausted.
	 */
	public native bool Next();
	
	/**
	 * Returns the key at the current position.
	 */
	public native void GetKey(char[] name, int maxlen);
	
	/** 
	 * Retrieves the string at the current iterator position, storing it in the specified
	 * buffer.
	 * Returns false if the current position contains a cell value or array.
	 */
	public native bool GetString(char[] value, int max_size, int& size = 0);
	
	/**
	 * Assigns the given string to the current iterator position, replacing any value
	 * previously set.
	 */
	public native void SetString(const char[] value);
	
	/**
	 * Retrieves the single cell value at the current iterator position, storing it in the
	 * specified cell reference.
	 * Returns false if the current position contains a string or a cell array.
	 */
	public native bool GetValue(any &value);
	
	/**
	 * Assigns the given cell value to the current iterator position, replacing any value
	 * previously set.
	 */
	public native void SetValue(any value);
	
	/**
	 * Retrieves the cell array at the current iterator position, storing it in the specified
	 * array.
	 * Returns false if the current position contains a string or a cell array.
	 */
	public native bool GetArray(any[] array, int max_size, int& size = 0);
	
	/**
	 * Assigns the cell array to the current iterator position, replacing any value
	 * previously set.
	 */
	public native void SetArray(const any[] array, int num_items);
	
	/**
	 * Removes the entry at the current iterator position.  The iterator is not advanced.
	 * Attempts to call getters / setters on a removed entry will throw an error.
	 * Subsequent calls to `Remove()` on the same entry will not throw any error.
	 */
	public native void Remove();
};

/**
 * Creates a multimap.  A multimap is a container that can map keys to arbitrary values.
 * 
 * There can be multiple entries in a multimap for a given key; however, only the first inserted
 * entry will be accessible through the Get*() methods.  To retrieve all the entries for a given
 * key, use the GetKeyIterator() method to get an iterator over the specified key.
 */
methodmap StringMultiMap < Handle {
	public native StringMultiMap();
	
	/**
	 * Removes all elements with the key equivalent to `key`.
	 */
	public native void Remove(const char[] key);
	
	/**
	 * Clears all entries from the multimap.
	 */
	public native void Clear();
	
	/**
	 * Adds a new value with the specified `key`.
	 */
	public native void AddValue(const char[] key, any value);
	
	/**
	 * Returns true iff the first entry associated with a key is a cell value, populating the
	 * passed-in by-ref `value` argument.
	 */
	public native bool GetValue(const char[] key, any &value);
	
	/**
	 * Adds a new string value with the specified key.
	 */
	public native void AddString(const char[] key, const char[] value);
	
	/**
	 * Returns true iff the first entry associated with a key is a string value, filling the
	 * passed-in `value` buffer.
	 */
	public native bool GetString(const char[] key, char[] value, int max_size, int& size = 0);
	
	/**
	 * Adds a new cell array with the specified key.
	 */
	public native void AddArray(const char[] key, const any[] array, int num_items);
	
	/**
	 * Returns true iff the first entry associated with a key is a cell value, filling the
	 * passed-in `value` buffer.
	 */
	public native bool GetArray(const char[] key, any[] array, int max_size, int& size = 0);
	
	/**
	 * Returns an interator over all keys.  Will still return a valid StringMultiMapIterator
	 * handle even if the StringMultiMap is empty.
	 */
	public native StringMultiMapIterator GetIterator();
	
	/**
	 * Returns an iterator for elements matching a specific key.
	 */
	public native StringMultiMapIterator GetKeyIterator(const char[] key);
	
	/**
	 * Returns the number of elements in the multimap.
	 */
	property int Size {
		public native get();
	}
};

public Extension __ext_madt = {
	name = "More ADTs",
	file = "madt.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_EXTENSIONS
public void __ext_madt_SetNTVOptional() {
}
#endif
