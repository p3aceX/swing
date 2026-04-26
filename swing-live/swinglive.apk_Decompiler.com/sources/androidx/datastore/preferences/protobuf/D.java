package androidx.datastore.preferences.protobuf;

import java.nio.charset.Charset;

/* JADX INFO: loaded from: classes.dex */
public final class D {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final r f2897b = new r(1);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Object f2898a;

    public D(C0200k c0200k) {
        AbstractC0211w.a(c0200k, "output");
        this.f2898a = c0200k;
        c0200k.f2999i = this;
    }

    public void a(int i4, Object obj, U u4) {
        C0200k c0200k = (C0200k) this.f2898a;
        c0200k.O0(i4, 3);
        u4.g((AbstractC0190a) obj, c0200k.f2999i);
        c0200k.O0(i4, 4);
    }

    public D() {
        Q q4 = Q.f2927c;
        J j4 = f2897b;
        try {
            j4 = (J) Class.forName("androidx.datastore.preferences.protobuf.DescriptorMessageInfoFactory").getDeclaredMethod("getInstance", new Class[0]).invoke(null, new Object[0]);
        } catch (Exception unused) {
        }
        J[] jArr = {r.f3031b, j4};
        C c5 = new C();
        c5.f2896a = jArr;
        Charset charset = AbstractC0211w.f3035a;
        this.f2898a = c5;
    }
}
