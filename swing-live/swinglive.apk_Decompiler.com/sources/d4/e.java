package d4;

import java.lang.reflect.Method;
import java.util.concurrent.LinkedBlockingQueue;

/* JADX INFO: loaded from: classes.dex */
public final class e implements b4.b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public volatile b4.b f3963a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Boolean f3964b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Method f3965c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public c4.a f3966d;
    public final LinkedBlockingQueue e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final boolean f3967f;

    public e(LinkedBlockingQueue linkedBlockingQueue, boolean z4) {
        this.e = linkedBlockingQueue;
        this.f3967f = z4;
    }

    @Override // b4.b
    public final boolean a() {
        return d().a();
    }

    @Override // b4.b
    public final boolean b() {
        return d().b();
    }

    @Override // b4.b
    public final void c(String str) {
        d().c(str);
    }

    public final b4.b d() {
        if (this.f3963a != null) {
            return this.f3963a;
        }
        if (this.f3967f) {
            return b.f3958a;
        }
        if (this.f3966d == null) {
            c4.a aVar = new c4.a();
            aVar.f3307a = this;
            aVar.f3308b = this.e;
            this.f3966d = aVar;
        }
        return this.f3966d;
    }

    public final boolean e() {
        Boolean bool = this.f3964b;
        if (bool != null) {
            return bool.booleanValue();
        }
        try {
            this.f3965c = this.f3963a.getClass().getMethod("log", c4.b.class);
            this.f3964b = Boolean.TRUE;
        } catch (NoSuchMethodException unused) {
            this.f3964b = Boolean.FALSE;
        }
        return this.f3964b.booleanValue();
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || e.class != obj.getClass()) {
            return false;
        }
        return true;
    }

    public final int hashCode() {
        return 1170925077;
    }
}
