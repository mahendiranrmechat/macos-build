# Import the root certificate
$certificatePath = "E:\psglotto_v1_feat_game\certificate\psglotto.crt"
Import-Certificate -FilePath $certificatePath -CertStoreLocation Cert:\LocalMachine\Root
