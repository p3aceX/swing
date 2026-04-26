package N2;

import O2.r;
import java.util.HashMap;
import y0.C0747k;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f1169a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public byte[] f1170b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0747k f1171c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public j f1172d;
    public boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public boolean f1173f;

    public k(F2.b bVar, boolean z4) {
        C0747k c0747k = new C0747k(bVar, "flutter/restoration", r.f1458a, 11);
        this.e = false;
        this.f1173f = false;
        C0779j c0779j = new C0779j(this, 11);
        this.f1171c = c0747k;
        this.f1169a = z4;
        c0747k.Y(c0779j);
    }

    public static HashMap a(byte[] bArr) {
        HashMap map = new HashMap();
        map.put("enabled", Boolean.TRUE);
        map.put("data", bArr);
        return map;
    }
}
