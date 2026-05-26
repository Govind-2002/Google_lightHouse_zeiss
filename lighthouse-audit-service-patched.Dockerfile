FROM aishjp/lighthouse-audit-service:20260309-aks1

# Patch the methods.js to add --ignore-certificate-errors flag to Chrome
RUN sed -i "s/args: \[\`--remote-debugging-port=\${chromePort}\`, '--no-sandbox'\]/args: [\`--remote-debugging-port=\${chromePort}\`, '--no-sandbox', '--ignore-certificate-errors', '--disable-web-security']/" /app/cjs/api/audits/methods.js

# Patch wait-on options to add User-Agent header (Wikipedia and some sites block requests without one)
RUN sed -i "s/const waitOnOpts = {/const waitOnOpts = { headers: { 'User-Agent': 'Mozilla\/5.0 (compatible; LighthouseAudit)' },/" /app/cjs/api/audits/methods.js
