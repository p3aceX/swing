package o3;

import javax.net.ssl.SSLException;

/* JADX INFO: renamed from: o3.F, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0590F extends SSLException {
    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0590F(String str, int i4) {
        super(str, null);
        J3.i.e(str, "message");
    }
}
