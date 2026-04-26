package e1;

import com.google.crypto.tink.shaded.protobuf.S;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.util.Arrays;

/* JADX INFO: renamed from: e1.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0368h implements R0.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final l f3995a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final R0.j f3996b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f3997c;

    public C0368h(l lVar, R0.j jVar, int i4) {
        this.f3995a = lVar;
        this.f3996b = jVar;
        this.f3997c = i4;
    }

    @Override // R0.a
    public final byte[] a(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        C0361a c0361a = (C0361a) this.f3995a;
        c0361a.getClass();
        int length = bArr.length;
        int i4 = c0361a.f3977b;
        int i5 = com.google.android.gms.common.api.f.API_PRIORITY_OTHER - i4;
        if (length > i5) {
            throw new GeneralSecurityException(S.d(i5, "plaintext length can not exceed "));
        }
        byte[] bArr3 = new byte[bArr.length + i4];
        byte[] bArrA = p.a(i4);
        System.arraycopy(bArrA, 0, bArr3, 0, i4);
        c0361a.a(bArr, 0, bArr.length, bArr3, c0361a.f3977b, bArrA, true);
        if (bArr2 == null) {
            bArr2 = new byte[0];
        }
        return AbstractC0367g.e(bArr3, this.f3996b.b(AbstractC0367g.e(bArr2, bArr3, Arrays.copyOf(ByteBuffer.allocate(8).putLong(((long) bArr2.length) * 8).array(), 8))));
    }

    @Override // R0.a
    public final byte[] b(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        int length = bArr.length;
        int i4 = this.f3997c;
        if (length < i4) {
            throw new GeneralSecurityException("ciphertext too short");
        }
        byte[] bArrCopyOfRange = Arrays.copyOfRange(bArr, 0, bArr.length - i4);
        byte[] bArrCopyOfRange2 = Arrays.copyOfRange(bArr, bArr.length - i4, bArr.length);
        if (bArr2 == null) {
            bArr2 = new byte[0];
        }
        this.f3996b.a(bArrCopyOfRange2, AbstractC0367g.e(bArr2, bArrCopyOfRange, Arrays.copyOf(ByteBuffer.allocate(8).putLong(((long) bArr2.length) * 8).array(), 8)));
        C0361a c0361a = (C0361a) this.f3995a;
        c0361a.getClass();
        int length2 = bArrCopyOfRange.length;
        int i5 = c0361a.f3977b;
        if (length2 < i5) {
            throw new GeneralSecurityException("ciphertext too short");
        }
        byte[] bArr3 = new byte[i5];
        System.arraycopy(bArrCopyOfRange, 0, bArr3, 0, i5);
        int length3 = bArrCopyOfRange.length;
        int i6 = c0361a.f3977b;
        byte[] bArr4 = new byte[length3 - i6];
        c0361a.a(bArrCopyOfRange, i6, bArrCopyOfRange.length - i6, bArr4, 0, bArr3, false);
        return bArr4;
    }
}
