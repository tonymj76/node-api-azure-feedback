const fs = require('fs');

module.exports = {
    get: function getSecret(name) {
        const secretFile = process.env[name + "_FILE"];

        if (secretFile) {
            return fs.readFileSync(secretFile, 'utf8');
        } else {
            return process.env[name];
        }
    }
};
