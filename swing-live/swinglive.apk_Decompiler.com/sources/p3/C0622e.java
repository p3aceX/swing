package p3;

import I3.l;
import J3.i;
import Q3.C0152y;
import Z3.h;
import com.google.crypto.tink.shaded.protobuf.S;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import javax.crypto.Cipher;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import o3.AbstractC0598f;
import o3.C0594b;
import o3.K;
import o3.M;
import u3.AbstractC0692a;
import x3.AbstractC0726f;

/* JADX INFO: renamed from: p3.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0622e implements InterfaceC0623f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0594b f6210a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final byte[] f6211b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public long f6212c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public long f6213d;

    public C0622e(C0594b c0594b, byte[] bArr) {
        i.e(c0594b, "suite");
        this.f6210a = c0594b;
        this.f6211b = bArr;
    }

    @Override // p3.InterfaceC0623f
    public final K a(K k4) throws NoSuchPaddingException, NoSuchAlgorithmException, InvalidKeyException, InvalidAlgorithmParameterException {
        i.e(k4, "record");
        h hVar = k4.f6019c;
        long jA = AbstractC0692a.a(hVar);
        long j4 = hVar.readLong();
        long j5 = this.f6212c;
        this.f6212c = 1 + j5;
        C0594b c0594b = this.f6210a;
        Cipher cipher = Cipher.getInstance(c0594b.e);
        i.b(cipher);
        byte[] bArr = this.f6211b;
        SecretKeySpec secretKeySpecB = AbstractC0598f.b(c0594b, bArr);
        int i4 = (c0594b.f6079o * 2) + (c0594b.f6080p * 2);
        int i5 = c0594b.f6071g;
        byte[] bArrF0 = AbstractC0726f.f0(bArr, i4 + i5, (i5 * 2) + i4);
        int i6 = c0594b.f6072h;
        byte[] bArrCopyOf = Arrays.copyOf(bArrF0, i6);
        i.d(bArrCopyOf, "copyOf(...)");
        AbstractC0619b.a(bArrCopyOf, j4, i5);
        int i7 = c0594b.f6073i;
        cipher.init(2, secretKeySpecB, new GCMParameterSpec(i7 * 8, bArrCopyOf));
        int i8 = (((int) jA) - (i6 - i5)) - i7;
        if (i8 >= 65536) {
            throw new IllegalStateException(S.d(i8, "Content size should fit in 2 bytes, actual: ").toString());
        }
        byte[] bArr2 = new byte[13];
        AbstractC0619b.a(bArr2, j5, 0);
        M m4 = k4.f6017a;
        bArr2[8] = (byte) m4.f6027a;
        bArr2[9] = 3;
        bArr2[10] = 3;
        AbstractC0619b.b(bArr2, (short) i8);
        cipher.updateAAD(bArr2);
        return new K(m4, k4.f6018b, AbstractC0620c.a(hVar, cipher, new C0152y(3)));
    }

    @Override // p3.InterfaceC0623f
    public final K b(K k4) throws NoSuchPaddingException, NoSuchAlgorithmException, InvalidKeyException, InvalidAlgorithmParameterException {
        i.e(k4, "record");
        h hVar = k4.f6019c;
        int iA = (int) AbstractC0692a.a(hVar);
        long j4 = this.f6213d;
        C0594b c0594b = this.f6210a;
        Cipher cipher = Cipher.getInstance(c0594b.e);
        i.b(cipher);
        byte[] bArr = this.f6211b;
        SecretKeySpec secretKeySpecA = AbstractC0598f.a(c0594b, bArr);
        int i4 = (c0594b.f6079o * 2) + (c0594b.f6080p * 2);
        int i5 = c0594b.f6071g;
        byte[] bArrCopyOf = Arrays.copyOf(AbstractC0726f.f0(bArr, i4, i4 + i5), c0594b.f6072h);
        i.d(bArrCopyOf, "copyOf(...)");
        AbstractC0619b.a(bArrCopyOf, j4, i5);
        cipher.init(1, secretKeySpecA, new GCMParameterSpec(c0594b.f6073i * 8, bArrCopyOf));
        byte[] bArr2 = new byte[13];
        AbstractC0619b.a(bArr2, j4, 0);
        M m4 = k4.f6017a;
        bArr2[8] = (byte) m4.f6027a;
        bArr2[9] = 3;
        bArr2[10] = 3;
        AbstractC0619b.b(bArr2, (short) iA);
        cipher.updateAAD(bArr2);
        final long j5 = this.f6213d;
        Z3.a aVarA = AbstractC0620c.a(hVar, cipher, new l() { // from class: p3.d
            @Override // I3.l
            public final Object invoke(Object obj) {
                Z3.a aVar = (Z3.a) obj;
                i.e(aVar, "$this$cipherLoop");
                Z3.f fVarH = aVar.h(8);
                int i6 = fVarH.f2616c;
                long j6 = j5;
                byte[] bArr3 = fVarH.f2614a;
                bArr3[i6] = (byte) ((j6 >>> 56) & 255);
                bArr3[i6 + 1] = (byte) ((j6 >>> 48) & 255);
                bArr3[i6 + 2] = (byte) ((j6 >>> 40) & 255);
                bArr3[i6 + 3] = (byte) ((j6 >>> 32) & 255);
                bArr3[i6 + 4] = (byte) ((j6 >>> 24) & 255);
                bArr3[i6 + 5] = (byte) ((j6 >>> 16) & 255);
                bArr3[i6 + 6] = (byte) ((j6 >>> 8) & 255);
                bArr3[i6 + 7] = (byte) (j6 & 255);
                fVarH.f2616c = i6 + 8;
                aVar.f2603c += 8;
                return w3.i.f6729a;
            }
        });
        this.f6213d++;
        return new K(m4, aVarA);
    }
}
