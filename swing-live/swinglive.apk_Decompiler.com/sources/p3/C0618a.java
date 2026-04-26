package p3;

import J3.i;
import Q3.C0152y;
import Q3.F;
import S3.l;
import Z3.h;
import a.AbstractC0184a;
import com.google.crypto.tink.shaded.protobuf.S;
import java.io.EOFException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import javax.crypto.Cipher;
import javax.crypto.Mac;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import o3.AbstractC0598f;
import o3.C0590F;
import o3.C0594b;
import o3.K;
import o3.M;
import s3.AbstractC0666b;
import s3.AbstractC0668d;
import s3.C0665a;
import u3.AbstractC0692a;
import x3.AbstractC0726f;

/* JADX INFO: renamed from: p3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0618a implements InterfaceC0623f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0594b f6198a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final byte[] f6199b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Cipher f6200c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final SecretKeySpec f6201d;
    public final Mac e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final Cipher f6202f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final SecretKeySpec f6203g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final Mac f6204h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public long f6205i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public long f6206j;

    public C0618a(C0594b c0594b, byte[] bArr) throws NoSuchPaddingException, NoSuchAlgorithmException {
        i.e(c0594b, "suite");
        this.f6198a = c0594b;
        this.f6199b = bArr;
        String str = c0594b.e;
        Cipher cipher = Cipher.getInstance(str);
        i.b(cipher);
        this.f6200c = cipher;
        this.f6201d = AbstractC0598f.a(c0594b, bArr);
        String str2 = c0594b.f6074j;
        Mac mac = Mac.getInstance(str2);
        i.b(mac);
        this.e = mac;
        Cipher cipher2 = Cipher.getInstance(str);
        i.b(cipher2);
        this.f6202f = cipher2;
        this.f6203g = AbstractC0598f.b(c0594b, bArr);
        Mac mac2 = Mac.getInstance(str2);
        i.b(mac2);
        this.f6204h = mac2;
    }

    @Override // p3.InterfaceC0623f
    public final K a(K k4) throws InvalidKeyException, EOFException, InvalidAlgorithmParameterException, C0590F {
        i.e(k4, "record");
        C0594b c0594b = this.f6198a;
        int i4 = c0594b.f6071g;
        h hVar = k4.f6019c;
        byte[] bArrD = Z3.i.d(hVar, i4);
        SecretKeySpec secretKeySpec = this.f6203g;
        IvParameterSpec ivParameterSpec = new IvParameterSpec(bArrD);
        Cipher cipher = this.f6202f;
        cipher.init(2, secretKeySpec, ivParameterSpec);
        byte[] bArrE = Z3.i.e(AbstractC0620c.a(hVar, cipher, new C0152y(3)), -1);
        int length = (bArrE.length - (bArrE[bArrE.length - 1] & 255)) - 1;
        int i5 = c0594b.f6080p;
        int i6 = length - i5;
        int i7 = bArrE[bArrE.length - 1] & 255;
        int length2 = bArrE.length;
        while (length < length2) {
            int i8 = bArrE[length] & 255;
            if (i7 != i8) {
                throw new C0590F(B1.a.k("Padding invalid: expected ", i7, i8, ", actual "), 0);
            }
            length++;
        }
        Mac mac = this.f6204h;
        mac.reset();
        byte[] bArr = AbstractC0598f.f6088a;
        mac.init(new SecretKeySpec(this.f6199b, i5, i5, c0594b.f6076l.f6275c));
        byte[] bArr2 = new byte[13];
        AbstractC0619b.a(bArr2, this.f6205i, 0);
        M m4 = k4.f6017a;
        bArr2[8] = (byte) m4.f6027a;
        bArr2[9] = 3;
        bArr2[10] = 3;
        AbstractC0619b.b(bArr2, (short) i6);
        this.f6205i++;
        mac.update(bArr2);
        mac.update(bArrE, 0, i6);
        byte[] bArrDoFinal = mac.doFinal();
        i.b(bArrDoFinal);
        if (!MessageDigest.isEqual(bArrDoFinal, AbstractC0726f.k0(bArrE, AbstractC0184a.Z(i6, i5 + i6)))) {
            throw new C0590F("Failed to verify MAC content", 0);
        }
        Z3.a aVar = new Z3.a();
        AbstractC0692a.c(aVar, bArrE, 0, i6);
        return new K(m4, k4.f6018b, aVar);
    }

    @Override // p3.InterfaceC0623f
    public final K b(K k4) throws InvalidKeyException, EOFException, InvalidAlgorithmParameterException {
        int i4;
        char cCharAt;
        int i5;
        byte b5;
        int i6;
        int i7 = 2;
        i.e(k4, "record");
        SecretKeySpec secretKeySpec = this.f6201d;
        C0594b c0594b = this.f6198a;
        int i8 = c0594b.f6071g;
        char[] cArr = AbstractC0666b.f6494a;
        Z3.a aVar = new Z3.a();
        while (((int) aVar.f2603c) < i8) {
            Object objA = AbstractC0668d.f6507b.A();
            if (objA instanceof l) {
                objA = null;
            }
            String str = (String) objA;
            if (str == null) {
                AbstractC0668d.f6508c.g();
                str = (String) F.w(new C0665a(i7, null));
            }
            int length = str.length();
            int i9 = 3;
            i.e(P3.a.f1492a, "charset");
            String string = str.toString();
            i.e(string, "string");
            byte b6 = 63;
            Z3.i.a(string.length(), 0, length);
            int i10 = 0;
            while (i10 < length) {
                char cCharAt2 = string.charAt(i10);
                char c5 = 128;
                if (cCharAt2 < 128) {
                    Z3.f fVarH = aVar.h(1);
                    int i11 = -i10;
                    int iMin = Math.min(length, fVarH.a() + i10);
                    int i12 = i10 + 1;
                    int i13 = fVarH.f2616c + i10 + i11;
                    byte[] bArr = fVarH.f2614a;
                    bArr[i13] = (byte) cCharAt2;
                    while (true) {
                        i4 = i12;
                        if (i4 >= iMin || (cCharAt = string.charAt(i4)) >= c5) {
                            break;
                        }
                        i12 = i4 + 1;
                        bArr[fVarH.f2616c + i4 + i11] = (byte) cCharAt;
                        c5 = 128;
                    }
                    int i14 = i11 + i4;
                    if (i14 == 1) {
                        fVarH.f2616c += i14;
                        aVar.f2603c += (long) i14;
                    } else {
                        if (i14 < 0 || i14 > fVarH.a()) {
                            StringBuilder sbI = S.i("Invalid number of bytes written: ", i14, ". Should be in 0..");
                            sbI.append(fVarH.a());
                            throw new IllegalStateException(sbI.toString().toString());
                        }
                        if (i14 != 0) {
                            fVarH.f2616c += i14;
                            aVar.f2603c += (long) i14;
                        } else if (Z3.i.b(fVarH)) {
                            aVar.d();
                        }
                    }
                    i10 = i4;
                } else if (cCharAt2 < 2048) {
                    Z3.f fVarH2 = aVar.h(2);
                    int i15 = fVarH2.f2616c;
                    byte[] bArr2 = fVarH2.f2614a;
                    bArr2[i15] = (byte) ((cCharAt2 >> 6) | 192);
                    bArr2[i15 + 1] = (byte) ((cCharAt2 & '?') | 128);
                    fVarH2.f2616c = i15 + 2;
                    aVar.f2603c += (long) 2;
                    i10++;
                } else {
                    if (cCharAt2 < 55296) {
                        i5 = i10;
                        b5 = b6;
                        i6 = i9;
                    } else if (cCharAt2 > 57343) {
                        i5 = i10;
                        i6 = i9;
                        b5 = b6;
                    } else {
                        int i16 = i10 + 1;
                        char cCharAt3 = i16 < length ? string.charAt(i16) : (char) 0;
                        if (cCharAt2 > 56319 || 56320 > cCharAt3 || cCharAt3 >= 57344) {
                            byte b7 = b6;
                            aVar.n(b7);
                            b6 = b7;
                            i10 = i16;
                        } else {
                            int i17 = (((cCharAt2 & 1023) << 10) | (cCharAt3 & 1023)) + 65536;
                            Z3.f fVarH3 = aVar.h(4);
                            int i18 = fVarH3.f2616c;
                            int i19 = i10;
                            byte[] bArr3 = fVarH3.f2614a;
                            bArr3[i18] = (byte) ((i17 >> 18) | 240);
                            bArr3[i18 + 1] = (byte) (((i17 >> 12) & 63) | 128);
                            bArr3[i18 + 2] = (byte) (((i17 >> 6) & 63) | 128);
                            bArr3[i18 + 3] = (byte) ((i17 & 63) | 128);
                            fVarH3.f2616c = i18 + 4;
                            aVar.f2603c += (long) 4;
                            i10 = i19 + 2;
                        }
                    }
                    Z3.f fVarH4 = aVar.h(i6);
                    byte b8 = (byte) ((cCharAt2 >> '\f') | 224);
                    b6 = b5;
                    byte b9 = (byte) (((cCharAt2 >> 6) & b5) | 128);
                    byte b10 = (byte) (128 | (cCharAt2 & '?'));
                    int i20 = fVarH4.f2616c;
                    byte[] bArr4 = fVarH4.f2614a;
                    bArr4[i20] = b8;
                    bArr4[i20 + 1] = b9;
                    bArr4[i20 + 2] = b10;
                    fVarH4.f2616c = i20 + 3;
                    aVar.f2603c += (long) 3;
                    i10 = i5 + 1;
                    i9 = 3;
                }
            }
            i7 = 2;
        }
        IvParameterSpec ivParameterSpec = new IvParameterSpec(Z3.i.d(aVar, i8));
        Cipher cipher = this.f6200c;
        cipher.init(1, secretKeySpec, ivParameterSpec);
        h hVar = k4.f6019c;
        i.e(hVar, "<this>");
        byte[] bArrE = Z3.i.e(hVar, -1);
        Mac mac = this.e;
        mac.reset();
        byte[] bArr5 = AbstractC0598f.f6088a;
        mac.init(new SecretKeySpec(this.f6199b, 0, c0594b.f6080p, c0594b.f6076l.f6275c));
        byte[] bArr6 = new byte[13];
        AbstractC0619b.a(bArr6, this.f6206j, 0);
        M m4 = k4.f6017a;
        bArr6[8] = (byte) m4.f6027a;
        bArr6[9] = 3;
        bArr6[10] = 3;
        AbstractC0619b.b(bArr6, (short) bArrE.length);
        this.f6206j++;
        mac.update(bArr6);
        byte[] bArrDoFinal = mac.doFinal(bArrE);
        i.d(bArrDoFinal, "doFinal(...)");
        Z3.a aVar2 = new Z3.a();
        AbstractC0692a.c(aVar2, bArrE, 0, bArrE.length);
        AbstractC0692a.c(aVar2, bArrDoFinal, 0, bArrDoFinal.length);
        byte blockSize = (byte) (cipher.getBlockSize() - ((((int) aVar2.f2603c) + 1) % cipher.getBlockSize()));
        int i21 = blockSize + 1;
        for (int i22 = 0; i22 < i21; i22++) {
            aVar2.n(blockSize);
        }
        return new K(m4, AbstractC0620c.a(aVar2, cipher, new M1.b(this, 5)));
    }
}
