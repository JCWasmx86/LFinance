## LFinance Documentation

### JSON Format (Version 1)

This is the first storage format of LFinance. It is deprecated. No support for writing is implemented. If such a file
is loaded, it will be converted to version 2 as soon as possible.

```
{
	"version": 1,
	"sorting": 1,
	"data": [
		{
			"purpose": "Some purpose",
			"amount": 500,
			"date": {
				"year": 121,
				"month": 2,
				"day": 5
			}
		}
	]
}
```
`version` is an integer describing the format. Here it is `1`. `sorting` describes how to the expenses are to be sorted.

| Value | Explanation                  |
|-------|------------------------------|
| 1     | Sort by amount               |
| 2     | Sort by purpose              |
| 3     | Sort by date                 |
| 4     | Sort by amount (Descending)  |
| 5     | Sort by purpose (Descending) |
| 6     | Sort by date (Descending)    |

The amount is the amount of cents in order to avoid floating point inaccuracies.

A date (`Y/M/D`) is transformed like this:

| Type  | Transformation |
|-------|----------------|
| Year  | `Y - 1900`     |
| Month | `M - 1`        |
| Day   | `D`            |

### JSON Format (Version 2)

This is the current storage format used by LFinance.

```
{
	"version": 2,
	"tags": [
		{"name": "TagName", "color": [200, 100, 100, 200]}
	],
	"locations": [
		{"name": "SomeName", "city": Berlin, "info": "Some further info"},
	],
	"accounts": [
		{
			"name": "AccountName",
			"sorting": 1,
			"expenses": [
				{
					"purpose": "Some purpose",
					"amount": 5000,
					"currency": "€",
					"date": {
						"year": 2021,
						"month": 12,
						"day": 31
					},
					"location": "SomeName or null",
					"tags": ["TagName", "TagName2"],
				}
			]
		}
	]
}
```

`sorting` follows the format of version 1.
New are `tags` and `locations`: These allow the user to classify every expense.
