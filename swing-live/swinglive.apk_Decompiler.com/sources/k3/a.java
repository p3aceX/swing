package K3;

import java.util.Random;

/* JADX INFO: loaded from: classes.dex */
public abstract class a extends d {
    @Override // K3.d
    public final int a(int i4) {
        return ((-i4) >> 31) & (d().nextInt() >>> (32 - i4));
    }

    @Override // K3.d
    public final int b() {
        return d().nextInt();
    }

    public abstract Random d();
}
