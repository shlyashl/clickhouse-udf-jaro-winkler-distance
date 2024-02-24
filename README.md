User-Defined Function for ClickHouse

# jaroWinklerDistance

Calculate the [Jaro–Winkler](https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance) distance between two strings.
The SQL function has been rewritten from the Python version available at the link: [https://python.algorithmexamples.com/web/strings/jaro_winkler.html](https://python.algorithmexamples.com/web/strings/jaro_winkler.html)

### Syntax 

```
jaroWinklerDistance(string1, string2)
```

### Arguments:

- `string1` — The first input string to be compared. [String](https://clickhouse.com/docs/en/sql-reference/data-types/string).
- `string2` — The second input string to be compared. [String](https://clickhouse.com/docs/en/sql-reference/data-types/string).

### Returned value

- Jaro–Winkler value [Float32](https://clickhouse.com/docs/en/sql-reference/data-types/float)

### Example

```
SELECT jaroWinklerDistance('abc', 'cab');
```

Result:

```
┌─jaroWinklerDistance('abc', 'cba')─┐
│                             0.555 │
└───────────────────────────────────┘
```
