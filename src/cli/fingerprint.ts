
import crypto from 'crypto';
import fs from 'fs/promises';
import https from 'https';
import yargs from 'yargs';
import { hideBin } from 'yargs/helpers';

type CertificateInfo = {
  domain: string;
  subject: {
    CN: string;
    [key: string]: string;
  };
  issuer: {
    CN: string;
    [key: string]: string;
  };
  validFrom: string;
  validTo: string;
  fingerprint: string;
};

async function getCertificate(domain: string): Promise<CertificateInfo> {
  return new Promise((resolve, reject) => {
    const options = {
      host: domain,
      port: 443,
      method: 'GET',
      rejectUnauthorized: false,
    };

    const req = https.request(options, (res) => {
      const cert = (res.socket as any).getPeerCertificate(true);
      const fingerprint = crypto
        .createHash('sha256')
        .update(cert.raw)
        .digest('hex')
        .match(/.{2}/g)!
        .join(':')
        .toUpperCase();

      resolve({
        domain,
        subject: cert.subject,
        issuer: cert.issuer,
        validFrom: cert.valid_from,
        validTo: cert.valid_to,
        fingerprint,
      });
    });

    req.on('error', (err) => {
      reject({
        domain,
        error: err.message,
      });
    });

    req.end();
  });
}

async function main() {
  const argv = await yargs(hideBin(process.argv))
    .usage('Usage: $0 <domains...> [options]')
    .option('out', {
      alias: 'o',
      type: 'string',
      description: 'Output file path',
    })
    .option('format', {
      alias: 'f',
      type: 'string',
      choices: ['json', 'fingerprints'],
      default: 'json',
      description: 'Output format',
    })
    .demandCommand(1, 'At least one domain is required')
    .help()
    .argv;

  const domains = argv._ as string[];
  const results: CertificateInfo[] = [];
  
  console.log('Fetching certificates...\n');

  for (const domain of domains) {
    try {
      const certInfo = await getCertificate(domain);
      results.push(certInfo);
      
      // Always print to console
      console.log(`Domain: ${certInfo.domain}`);
      console.log(`Subject: ${certInfo.subject.CN}`);
      console.log(`Issuer: ${certInfo.issuer.CN}`);
      console.log(`Valid From: ${certInfo.validFrom}`);
      console.log(`Valid To: ${certInfo.validTo}`);
      console.log(`SHA256 Fingerprint: ${certInfo.fingerprint}`);
      console.log('-------------------\n');
    } catch (err: any) {
      console.error(`Error fetching cert for ${domain}: ${err.message}`);
      console.log('-------------------\n');
    }
  }

  if (argv.out) {
    const output = argv.format === 'fingerprints' 
      ? `export const fingerprints = ${JSON.stringify(results.map(r => r.fingerprint), null, 2)};`
      : JSON.stringify(results, null, 2);
    
    await fs.writeFile(argv.out, output);
    console.log(`Results written to ${argv.out}`);
  }
  process.exit(0);
}

main().catch(console.error); 