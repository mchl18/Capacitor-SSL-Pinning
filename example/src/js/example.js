import { SSLCertificateChecker } from 'certificate-checker';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    SSLCertificateChecker.echo({ value: inputValue })
}
