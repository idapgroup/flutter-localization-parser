languages=("en" "uk")
SHEET_ID={SHEET_ID}
        
rm -rf localization.csv

for lang in "${languages[@]}"; do
  comma_separated_languages+="${lang},"
done

comma_separated_languages=${comma_separated_languages%,}

mkdir -p "./lib/l10n"

if [ -e "./credentials.json" ]; then
    if command -v gcloud > /dev/null 2>&1; then
        echo "gcloud is installed."
    else
        curl https://sdk.cloud.google.com | bash
        exec -l $SHELL
    fi

    gcloud auth activate-service-account --key-file=credentials.json

    ACCESS_TOKEN=$(gcloud auth print-access-token --scopes=https://www.googleapis.com/auth/drive.readonly)

    curl -L -H "Authorization: Bearer $ACCESS_TOKEN" "https://www.googleapis.com/drive/v3/files/$SHEET_ID/export?mimeType=text/csv" > localization.csv
else
    curl -L https://docs.google.com/spreadsheets/d/$SHEET_ID/export?exportFormat=csv > localization.csv
fi

if command -v fvm > /dev/null 2>&1; then
    echo "fvm is installed. Using fvm."
    flutter_cmd="fvm flutter"
    dart_cmd="fvm dart"
else
    echo "fvm is not installed. Using default flutter and dart."
    flutter_cmd="flutter"
    dart_cmd="dart"
fi

sh compile.sh
$dart_cmd run ./localization_parser  --locales ${comma_separated_languages} --csv ./localization.csv

$flutter_cmd pub add flutter_localizations --sdk=flutter 
$flutter_cmd gen-l10n


printf "Done.\n"
