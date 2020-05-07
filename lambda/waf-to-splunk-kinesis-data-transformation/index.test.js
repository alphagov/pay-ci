const { handler } = require('./index');

test('expects the output to be in the correct format with the correct base64 encoding', async () => {
    const event = {
        records: [
            { recordId: "a record id", data: btoa("{\"content\": \"this is the log line\"}")}
        ]
    }
    const context = {"ctx": "hello"}
    const result = await handler(event, context)
    const expected = [{"data": "eyJ0aW1lIjpudWxsLCJob3N0IjoibGFtYmRhIiwic291cmNlIjoiYXdzLXdhZiIsInNvdXJjZXR5cGUiOiJhd3M6ZmlyZWhvc2U6anNvbiIsImluZGV4IjoicGF5X3Rlc3RpbmciLCJldmVudCI6eyJjb250ZW50IjoidGhpcyBpcyB0aGUgbG9nIGxpbmUifX0=", "recordId": "a record id", "result": "Ok"}]
    expect(result.records).toStrictEqual(expected);
});

