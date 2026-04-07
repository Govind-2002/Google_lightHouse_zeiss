FROM aishjp/lighthouse-audit-service:20260309-aks1

# Patch the methods.js to add --ignore-certificate-errors flag to Chrome
RUN sed -i "s/args: \[\`--remote-debugging-port=\${chromePort}\`, '--no-sandbox'\]/args: [\`--remote-debugging-port=\${chromePort}\`, '--no-sandbox', '--ignore-certificate-errors', '--disable-web-security']/" /app/cjs/api/audits/methods.js
