# Script for generating and installing the Deepsafer development certificates on Windows.

$params = @{
    'KeyAlgorithm' = 'RSA';
    'KeyLength' = 4096;
    'NotAfter' = (Get-Date).AddDays(3650);
    'CertStoreLocation' = 'Cert:\CurrentUser\My';
};

$params['Subject'] = 'CN=Deepsafer Identity Server Dev';
New-SelfSignedCertificate @params;
