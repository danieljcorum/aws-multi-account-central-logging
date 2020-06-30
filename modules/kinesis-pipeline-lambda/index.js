'use strict';
const zlib = require('zlib');
function transformLogEvent(logEvent) {
       return Promise.resolve(`${logEvent.message}
`);
}
exports.handler = (event, context, callback) => {
    Promise.all(event.records.map(r => {
        const buffer = new Buffer(r.data, 'base64');
        const decompressed = zlib.gunzipSync(buffer);
        const data = JSON.parse(decompressed);
        if (data.messageType !== 'DATA_MESSAGE') {
            return Promise.resolve({
                recordId: r.recordId,
                result: 'ProcessingFailed',
            });
         } else {
            const promises = data.logEvents.map(transformLogEvent);
            return Promise.all(promises).then(transformed => {
                const payload = transformed.reduce((a, v) => a + v, '');
                const encoded = new Buffer(payload).toString('base64');
                console.log('---------------payloadv2:'+JSON.stringify(payload, null, 2));
                return {
                    recordId: r.recordId,
                    result: 'Ok',
                    data: encoded,
                };
           });
        }
    })).then(recs => callback(null, { records: recs }));
};