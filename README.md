# restful_api_examples
Some example scripts for use with the Koha API.

## Usage
### add_patron.sh:
```
[I]	add_patron RESTful script, Jake Deery @ PTFS-Europe, 2021
[E]	Usage: ./add_patron.sh --in <file>

[E]	Required flags:
[E]		--in <file>				What to send. File must be json.

[E]	Optional flags:
[E]		--config <file>			The json file used to configure this script. Will default to <script-dir>/config/config.json if unspecified.
```

### get_patron.sh:
```
[I]	get_patron RESTful script, Jake Deery @ PTFS-Europe, 2021
[E]	Usage: ./get_patron.sh --matchpoint <string> --value <string|int>

[E]	Required flags:
[E]		--matchpoint <string>	What to lookup against. Possible values are: cardnumber, userid, patron_id
[E]		--value <string|int>	What to lookup using. Max. length 8 chars.

[E]	Optional flags:
[E]		--config <file>			The json file used to configure this script. Will default to <script-dir>/config/config.json if unspecified.
```

### get_all_patron.sh:
```
[I]	get_all_patron RESTful script, Jake Deery @ PTFS-Europe, 2021
[E]	Usage: ./get_all_patron.sh

[E]	Optional flags:
[E]		--config <file>			The json file used to configure this script. Will default to <script-dir>/config/config.json if unspecified.
```

### update_patron.sh
```
[I]	update_patron RESTful script, Jake Deery @ PTFS-Europe, 2021
[E]	Usage: ./update_patron.sh --patron-id <int> --in <file>

[E]	Required flags:
[E]		--patron-id <int>		The internal Koha patron identifier to match against.
[E]		--in <file>				What to send. File must be json.

[E]	Optional flags:
[E]		--config <file>			The json file used to configure this script. Will default to <script-dir>/config/config.json if unspecified.
```
