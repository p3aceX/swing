package z0;

import java.util.Arrays;

/* JADX INFO: renamed from: z0.o, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class BinderC0784o extends AbstractBinderC0783n {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final byte[] f6978b;

    public BinderC0784o(byte[] bArr) {
        super(Arrays.copyOfRange(bArr, 0, 25));
        this.f6978b = bArr;
    }

    @Override // z0.AbstractBinderC0783n
    public final byte[] c() {
        return this.f6978b;
    }
}
