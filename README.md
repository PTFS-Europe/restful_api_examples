# restful_api_examples
Some example scripts for use with the Koha API. Specifically focused on patron loading, updating or deleting.

## Before use
* Make sure you populate the config/config.json file with the required attributes, otherwise the script won't be able to get a token.
* Also, make sure the Koha syspref *RESTOAuth2ClientCredentials*  is enabled, and an API key has been created under a Librarian patron
* Also, make sure CPAN module *Net::OAuth2::AuthorizationServer* is installed. Restart plack if required.
* Lastly, make sure *CGIPassAuth On* is set under the */api* alias in Apache httpd, otherwise you will get a 401 Unauthorised response.

## Usage
### add_patron.sh:
```
[I]	add_patron RESTful script, Jake Deery @ PTFS-Europe, 2021
[E]	Usage: ./add_patron.sh --in <file>

[E]	Required flags:
[E]		--in <file>             What to send. File must be json.

[E]	Optional flags:
[E]		--config <file>         The json file used to configure this script. Will default to <script-dir>/config/config.json if unspecified.
```

### delete_patron.sh:
```
[I]	delete_patron RESTful script, Jake Deery @ PTFS-Europe, 2021
[E]	Usage: ./delete_patron.sh --patron-id <int>

[E]	Required flags:
[E]		--patron-id <int>       The internal Koha patron identifier to match against.

[E]	Optional flags:
[E]		--config <file>         The json file used to configure this script. Will default to <script-dir>/config/config.json if unspecified.
```

### get_patron.sh:
```
[I]	get_patron RESTful script, Jake Deery @ PTFS-Europe, 2021
[E]	Usage: ./get_patron.sh --matchpoint <string> --value <string|int>

[E]	Required flags:
[E]		--matchpoint <string>   What to lookup against. Possible values are: cardnumber, userid, patron_id
[E]		--value <string|int>    What to lookup using. Max. length 8 chars.

[E]	Optional flags:
[E]		--config <file>         The json file used to configure this script. Will default to <script-dir>/config/config.json if unspecified.
```

### get_all_patron.sh:
```
[I]	get_all_patron RESTful script, Jake Deery @ PTFS-Europe, 2021
[E]	Usage: ./get_all_patron.sh

[E]	Optional flags:
[E]		--config <file>         The json file used to configure this script. Will default to <script-dir>/config/config.json if unspecified.
```

### update_patron.sh
```
[I]	update_patron RESTful script, Jake Deery @ PTFS-Europe, 2021
[E]	Usage: ./update_patron.sh --patron-id <int> --in <file>

[E]	Required flags:
[E]		--patron-id <int>       The internal Koha patron identifier to match against.
[E]		--in <file>             What to send. File must be json.

[E]	Optional flags:
[E]		--config <file>         The json file used to configure this script. Will default to <script-dir>/config/config.json if unspecified.
```
