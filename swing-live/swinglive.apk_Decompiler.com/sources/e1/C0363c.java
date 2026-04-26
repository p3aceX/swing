package e1;

import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.security.spec.AlgorithmParameterSpec;
import java.util.Arrays;
import javax.crypto.Cipher;

/* JADX INFO: renamed from: e1.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0363c implements R0.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3984a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f3985b;

    public C0363c(byte[] bArr, int i4) throws GeneralSecurityException {
        this.f3984a = i4;
        switch (i4) {
            case 1:
                this.f3985b = new T0.e(bArr, 0);
                return;
            case 2:
                this.f3985b = new T0.e(bArr, 1);
                return;
            default:
                if (!B1.a.g(2)) {
                    throw new GeneralSecurityException("Can not use AES-GCM in FIPS-mode, as BoringCrypto module is not available.");
                }
                this.f3985b = new T0.b(bArr);
                return;
        }
    }

    @Override // R0.a
    public final byte[] a(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        switch (this.f3984a) {
            case 0:
                byte[] bArrA = p.a(12);
                T0.b bVar = (T0.b) this.f3985b;
                bVar.getClass();
                if (bArrA.length != 12) {
                    throw new GeneralSecurityException("iv is wrong size");
                }
                if (bArr.length > 2147483619) {
                    throw new GeneralSecurityException("plaintext too long");
                }
                boolean z4 = bVar.f1870b;
                byte[] bArr3 = new byte[z4 ? bArr.length + 28 : bArr.length + 16];
                if (z4) {
                    System.arraycopy(bArrA, 0, bArr3, 0, 12);
                }
                AlgorithmParameterSpec algorithmParameterSpecA = T0.b.a(bArrA);
                J0.b bVar2 = T0.b.f1868c;
                ((Cipher) bVar2.get()).init(1, bVar.f1869a, algorithmParameterSpecA);
                if (bArr2 != null && bArr2.length != 0) {
                    ((Cipher) bVar2.get()).updateAAD(bArr2);
                }
                int iDoFinal = ((Cipher) bVar2.get()).doFinal(bArr, 0, bArr.length, bArr3, z4 ? 12 : 0);
                if (iDoFinal == bArr.length + 16) {
                    return bArr3;
                }
                throw new GeneralSecurityException(B1.a.l("encryption failed; GCM tag must be 16 bytes, but got only ", iDoFinal - bArr.length, " bytes"));
            case 1:
                ByteBuffer byteBufferAllocate = ByteBuffer.allocate(bArr.length + 28);
                byte[] bArrA2 = p.a(12);
                byteBufferAllocate.put(bArrA2);
                ((T0.e) this.f3985b).b(byteBufferAllocate, bArrA2, bArr, bArr2);
                return byteBufferAllocate.array();
            default:
                ByteBuffer byteBufferAllocate2 = ByteBuffer.allocate(bArr.length + 40);
                byte[] bArrA3 = p.a(24);
                byteBufferAllocate2.put(bArrA3);
                ((T0.e) this.f3985b).b(byteBufferAllocate2, bArrA3, bArr, bArr2);
                return byteBufferAllocate2.array();
        }
    }

    @Override // R0.a
    public final byte[] b(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        switch (this.f3984a) {
            case 0:
                byte[] bArrCopyOf = Arrays.copyOf(bArr, 12);
                T0.b bVar = (T0.b) this.f3985b;
                bVar.getClass();
                if (bArrCopyOf.length != 12) {
                    throw new GeneralSecurityException("iv is wrong size");
                }
                boolean z4 = bVar.f1870b;
                if (bArr.length < (z4 ? 28 : 16)) {
                    throw new GeneralSecurityException("ciphertext too short");
                }
                if (z4 && !ByteBuffer.wrap(bArrCopyOf).equals(ByteBuffer.wrap(bArr, 0, 12))) {
                    throw new GeneralSecurityException("iv does not match prepended iv");
                }
                AlgorithmParameterSpec algorithmParameterSpecA = T0.b.a(bArrCopyOf);
                J0.b bVar2 = T0.b.f1868c;
                ((Cipher) bVar2.get()).init(2, bVar.f1869a, algorithmParameterSpecA);
                if (bArr2 != null && bArr2.length != 0) {
                    ((Cipher) bVar2.get()).updateAAD(bArr2);
                }
                int i4 = z4 ? 12 : 0;
                int length = bArr.length;
                if (z4) {
                    length -= 12;
                }
                return ((Cipher) bVar2.get()).doFinal(bArr, i4, length);
            case 1:
                if (bArr.length < 28) {
                    throw new GeneralSecurityException("ciphertext too short");
                }
                return ((T0.e) this.f3985b).a(ByteBuffer.wrap(bArr, 12, bArr.length - 12), Arrays.copyOf(bArr, 12), bArr2);
            default:
                if (bArr.length < 40) {
                    throw new GeneralSecurityException("ciphertext too short");
                }
                return ((T0.e) this.f3985b).a(ByteBuffer.wrap(bArr, 24, bArr.length - 24), Arrays.copyOf(bArr, 24), bArr2);
        }
    }
}
