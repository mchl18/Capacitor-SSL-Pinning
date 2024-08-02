import { SSLCertificateCheckerOptions, SSLCertificateCheckerResult } from "./types";

export interface SSLCertificateCheckerPlugin {
  checkCertificate(options: SSLCertificateCheckerOptions): Promise<SSLCertificateCheckerResult>;
}