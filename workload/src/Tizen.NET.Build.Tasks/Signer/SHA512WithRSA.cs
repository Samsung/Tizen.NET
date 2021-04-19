/*
 * Copyright 2017 (c) Samsung Electronics Co., Ltd  All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * 	http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

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


namespace Tizen.NET.Build.Tasks.Signer
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
