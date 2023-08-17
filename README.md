# MouseTime

How much time do you spend on your mouse? How far from 0?

```bash
make dev
```

```bash
cat ~/activity.json | jq .
```

output will look like this:

```json
{
  "mouseTime": 310.7856379490113,
  "keyboardTime": 6.557707041269168,
  "totalKeyPresses": 623
}
```

> you will need to add the terminal to the Accessibility list in System Preferences > Security & Privacy > Privacy > Accessibility
