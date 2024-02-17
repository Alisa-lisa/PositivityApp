# PositivityApp
small app for optimism and positivity learning

1. Ask for scenario from 3 classes of seriousness and from one life area.
2. Think of N bad consequences resulting from the scenario
3. Think of N+1 good consequences resulting from scenario

App will utilize spaced repetition to train positive outlook on life more efficiently =)


## Development
app runs on dotenv file, generating internal Env class for usage. So before running app with `flutter run` do:
1. make sure there is a `.env` in the root of the project
```
AUTH="SOME_TOKEN"
BASE_URL="SOME_URL"
```
2. to generate all needed data classes, run following commands:
- `flutter pub add build_runner` (you can try using `--dev` flag, but there is an ongoing bug)
- `flutter pub add envied_generator`
- `dart run build_runner clean`
- `dart run build_runner --delete-conflicting-outputs`

It should create a file `lib/env/env.g.dart`

3. run app in debug mode: `flutter run`

4. for building released package see [flutter release](!https://docs.flutter.dev/deployment/android)


