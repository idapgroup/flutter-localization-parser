if command -v fvm > /dev/null 2>&1; then
    echo "fvm is installed. Using fvm."
    dart_cmd="fvm dart"
else
    echo "fvm is not installed. Using default flutter and dart."
    dart_cmd="dart"
fi

rm -rf localization_parser
rm -rf helper/lib
mkdir -p "./helper/lib/l10n"

cd localization-parser/

$dart_cmd pub get
$dart_cmd pub upgrade
$dart_cmd compile kernel ./bin/localization_parser.dart

cd ../

mv ./localization-parser/bin/localization_parser.dill ./localization_parser
