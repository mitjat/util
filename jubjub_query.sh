JSON=$(cat <<EOF
{
  "tweets": [{
    "id": 373206795311120384,
    "authorId": 807095,
    "text": "$1",
    "locale": {"language": "en"}
  }],
  "options": {"modelKey": {"id": "NAIVE-JA-7"}}
}
EOF
)
echo "Querying with $JSON"
curl \
  -H 'Content-type: application/json' \
  -H 'Accept: application/json' \
  -d "$JSON" \
  http://jubjub_service_v2.devel.mtrampus.service.smf1.twitter.com/api/getTweetTopics
