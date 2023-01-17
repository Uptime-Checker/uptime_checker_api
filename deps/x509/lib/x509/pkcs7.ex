defmodule X509.PKCS7 do
  require Record

  Record.defrecord(
    :content_info,
    :ContentInfo,
    Record.extract(:ContentInfo, from_lib: "public_key/include/OTP-PUB-KEY.hrl")
  )

  Record.defrecord(
    :signed_data,
    :SignedData,
    Record.extract(:SignedData, from_lib: "public_key/include/OTP-PUB-KEY.hrl")
  )

  Record.defrecord(
    :enveloped_data,
    :EnvelopedData,
    Record.extract(:EnvelopedData, from_lib: "public_key/include/OTP-PUB-KEY.hrl")
  )

  Record.defrecord(
    :signer_info,
    :SignerInfo,
    Record.extract(:SignerInfo, from_lib: "public_key/include/OTP-PUB-KEY.hrl")
  )

  Record.defrecord(
    :recipient_info,
    :RecipientInfo,
    Record.extract(:RecipientInfo, from_lib: "public_key/include/OTP-PUB-KEY.hrl")
  )

  Record.defrecord(
    :encrypted_content_info,
    :EncryptedContentInfo,
    Record.extract(:EncryptedContentInfo, from_lib: "public_key/include/OTP-PUB-KEY.hrl")
  )

  Record.defrecord(
    :issuer_and_serial_number,
    :IssuerAndSerialNumber,
    Record.extract(:IssuerAndSerialNumber, from_lib: "public_key/include/OTP-PUB-KEY.hrl")
  )

  Record.defrecord(
    :attribute_pkcs7,
    :"AttributePKCS-7",
    Record.extract(:"AttributePKCS-7", from_lib: "public_key/include/OTP-PUB-KEY.hrl")
  )

  Record.defrecord(
    :digest_algorithm_identifier,
    :DigestAlgorithmIdentifier,
    Record.extract(:DigestAlgorithmIdentifier, from_lib: "public_key/include/OTP-PUB-KEY.hrl")
  )

  Record.defrecord(
    :digest_encryption_algorithm_identifier,
    :DigestEncryptionAlgorithmIdentifier,
    Record.extract(:DigestEncryptionAlgorithmIdentifier,
      from_lib: "public_key/include/OTP-PUB-KEY.hrl"
    )
  )

  Record.defrecord(
    :content_encryption_algorithm_identifier,
    :ContentEncryptionAlgorithmIdentifier,
    Record.extract(:ContentEncryptionAlgorithmIdentifier,
      from_lib: "public_key/include/OTP-PUB-KEY.hrl"
    )
  )

  @idData {1, 2, 840, 113_549, 1, 7, 1}
  @idSignedData {1, 2, 840, 113_549, 1, 7, 2}
  @idEnvelopedData {1, 2, 840, 113_549, 1, 7, 3}

  @idContentType {1, 2, 840, 113_549, 1, 9, 3}
  @idMessageDigest {1, 2, 840, 113_549, 1, 9, 4}
  @idSigningTime {1, 2, 840, 113_549, 1, 9, 5}

  @idSha1 {1, 3, 14, 3, 2, 26}
  @idRsaEncryption {1, 2, 840, 113_549, 1, 1, 1}
  @idAes256Cbc {2, 16, 840, 1, 101, 3, 4, 1, 42}

  def sign(input, cert, key) do
    attributes =
      {:aaSet,
       [
         attribute_pkcs7(type: @idContentType, values: [@idData]),
         attribute_pkcs7(type: @idSigningTime, values: [X509.DateTime.new()]),
         attribute_pkcs7(type: @idMessageDigest, values: [:crypto.hash(:sha, input)])
       ]}

    signature = :public_key.sign(aa_tbs(attributes), :sha, key)

    content_info(
      contentType: @idSignedData,
      content:
        signed_data(
          version: :sdVer1,
          digestAlgorithms: {:daSet, [alg_sha1()]},
          contentInfo: {:ContentInfo, @idData, input},
          certificates: {:certSet, [certificate: cert]},
          # crls: asn1_NOVALUE,
          signerInfos:
            {:siSet,
             [
               signer_info(
                 version: :siVer1,
                 issuerAndSerialNumber:
                   issuer_and_serial_number(
                     issuer: X509.Certificate.issuer(cert),
                     serialNumber: X509.Certificate.serial(cert)
                   ),
                 digestAlgorithm: alg_sha1(),
                 authenticatedAttributes: attributes,
                 digestEncryptionAlgorithm: alg_rsa(),
                 encryptedDigest: signature
                 # unauthenticatedAttributes: :asn1_NOVALUE
               )
             ]}
        )
    )
  end

  def encrypt(input, cert) do
    key = :crypto.strong_rand_bytes(32)
    iv = :crypto.strong_rand_bytes(16)

    padded_input = with_padding(input)
    ciphertext = :crypto.crypto_one_time(:aes_256_cbc, key, iv, padded_input, true)

    IO.inspect(Base.encode16(ciphertext))

    recipient_public_key = X509.Certificate.public_key(cert)
    encrypted_key = :public_key.encrypt_public(key, recipient_public_key)

    content_info(
      contentType: @idEnvelopedData,
      content:
        enveloped_data(
          version: :edVer0,
          recipientInfos:
            {:riSet,
             [
               recipient_info(
                 version: :riVer0,
                 issuerAndSerialNumber:
                   issuer_and_serial_number(
                     issuer: X509.Certificate.issuer(cert),
                     serialNumber: X509.Certificate.serial(cert)
                   ),
                 keyEncryptionAlgorithm: alg_rsa(),
                 encryptedKey: encrypted_key
               )
             ]},
          encryptedContentInfo:
            encrypted_content_info(
              contentType: @idData,
              contentEncryptionAlgorithm: alg_aes256cbc(iv),
              encryptedContent: ciphertext
            )
        )
    )
  end

  # rfc2630#section-5.4:
  # A separate encoding of the
  # signedAttributes field is performed for message digest calculation.
  # The IMPLICIT [0] tag in the signedAttributes field is not used for
  # the DER encoding, rather an EXPLICIT SET OF tag is used.  That is,
  # the DER encoding of the SET OF tag, rather than of the IMPLICIT [0]
  # tag, is to be included in the message digest calculation along with
  # the length and content octets of the SignedAttributes value.
  defp aa_tbs(aa) do
    <<0xA0, value::binary>> = :public_key.der_encode(:SignerInfoAuthenticatedAttributes, aa)
    <<0x31, value::binary>>
  end

  defp with_padding(input) do
    case rem(byte_size(input), 16) do
      0 ->
        input

      n ->
        pad_len = 16 - n
        input <> String.duplicate(<<pad_len>>, pad_len)
    end
  end

  defp alg_sha1 do
    digest_algorithm_identifier(algorithm: @idSha1, parameters: {:asn1_OPENTYPE, <<5, 0>>})
  end

  defp alg_rsa do
    digest_encryption_algorithm_identifier(
      algorithm: @idRsaEncryption,
      parameters: {:asn1_OPENTYPE, <<5, 0>>}
    )
  end

  defp alg_aes256cbc(iv) do
    content_encryption_algorithm_identifier(
      algorithm: @idAes256Cbc,
      parameters: {:asn1_OPENTYPE, <<4, 16, iv::binary>>}
    )
  end
end
