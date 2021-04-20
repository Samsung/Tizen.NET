using System;
using System.Collections.Generic;
using System.Text;
using System.IO;


using Org.BouncyCastle.Pkcs;
using Org.BouncyCastle.Asn1;
using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Crypto.Parameters;
using Org.BouncyCastle.OpenSsl;
using Org.BouncyCastle.Security;
using Org.BouncyCastle.Utilities.Encoders;
using Org.BouncyCastle.X509;


namespace Samsung.Tizen.Build.Tasks.Signer
{
    public class SHA512WithRSA
    {
        public string Alias { get; private set; }
        public Pkcs12Store KeyStore { get; private set; }
        public string[] Base64KeyChain { get; private set; }

        public SHA512WithRSA(string pkcs12path, string password)
        {
            using (FileStream fs = new FileStream(pkcs12path, FileMode.Open, FileAccess.Read))
            {
                KeyStore = new Pkcs12StoreBuilder().Build();
                KeyStore.Load(fs, password.ToCharArray());

                List<string> keys = new List<string>();

                foreach (string alias in KeyStore.Aliases)
                {
                    if (string.IsNullOrEmpty(alias))
                    {
                        continue;
                    }

                    X509CertificateEntry[] chain = KeyStore.GetCertificateChain(alias);
                    if (chain == null)
                    {
                        continue;
                    }

                    foreach (X509CertificateEntry entry in chain)
                    {
                        X509Certificate cert = entry.Certificate;
                        byte[] encoded = cert.GetEncoded();
                        string base64cert = Convert.ToBase64String(encoded);
                        keys.Add(base64cert);
                    }

                    Alias = alias;
                    Base64KeyChain = keys.ToArray();

                }
            }
        }

        public byte[] Sign(byte[] data)
        {
            ISigner sign = SignerUtilities.GetSigner("SHA512withRSA");

            // Yes! Encrypt data with Private key becase this is "digital signing!!"
            // Asymmetric Encryption : encrypt with public key and decrypt with private key.
            // Digital Signing : encrypt with private key and decrypt with public key.
            ICipherParameters privateKey = KeyStore.GetKey(Alias).Key;
            sign.Init(true, privateKey);
            sign.BlockUpdate(data, 0, data.Length);
            byte[] signature = sign.GenerateSignature();
            return signature;
        }

        public byte[] Sign(string data)
        {
            byte[] bytes = Encoding.UTF8.GetBytes(data);
            return Sign(bytes);
        }
    }
}
