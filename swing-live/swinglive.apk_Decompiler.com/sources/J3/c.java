package J3;

import java.io.Serializable;

/* JADX INFO: loaded from: classes.dex */
public abstract class c implements N3.a, Serializable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public transient N3.a f817a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f818b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Class f819c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f820d;
    public final String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final boolean f821f;

    public c(Object obj, Class cls, String str, String str2, boolean z4) {
        this.f818b = obj;
        this.f819c = cls;
        this.f820d = str;
        this.e = str2;
        this.f821f = z4;
    }

    public abstract N3.a c();

    public final d e() {
        Class cls = this.f819c;
        if (!this.f821f) {
            return s.a(cls);
        }
        s.f833a.getClass();
        return new l(cls);
    }
}
